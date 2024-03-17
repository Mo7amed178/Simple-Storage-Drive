class BlobsController < ApplicationController
  before_action :authenticate_request!
  UPLOAD_DIR = Rails.root.join('uploads')

  def create
    id = params[:id]
    data = params[:data]

    upload_to_local_storage(id, data)

    render json: { message: 'Blob stored successfully' }, status: :created
  end

  def show
    id = params[:id]

    data, created_at = download_from_local_storage(id)

    if data
      render json: { id: id, data: data, size: data.length, created_at: created_at }
    else
      render json: { error: 'Blob not found' }, status: :not_found
    end
  end

  private

  def authenticate_request!
    token = extract_token_from_header(request.headers['Authorization'])
    unless valid_token?(token)
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  def valid_token?(token)
    # Logic to validate the token (e.g., check against a database)
    # For simplicity, let's assume a hardcoded token here
    token == 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c'
  end

  def extract_token_from_header(header)
    header.to_s.split(' ').last
  end

  def upload_to_local_storage(filename, data)
    FileUtils.mkdir_p(UPLOAD_DIR) unless File.directory?(UPLOAD_DIR)

    File.open(File.join(UPLOAD_DIR, filename), 'wb') do |file|
      file.write(Base64.decode64(data))
    end
  end

  def download_from_local_storage(filename)
    file_path = File.join(UPLOAD_DIR, filename)

    return nil unless File.exist?(file_path)

    encoded_data = Base64.strict_encode64(File.read(file_path))
    created_at = File.ctime(file_path).iso8601
    [encoded_data, created_at]
  end
end
