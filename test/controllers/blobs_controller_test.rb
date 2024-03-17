require "test_helper"

class BlobsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get blobs_create_url
    assert_response :success
  end

  test "should get show" do
    get blobs_show_url
    assert_response :success
  end
end
