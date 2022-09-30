require "test_helper"

class LoginControllerTest < ActionDispatch::IntegrationTest
  test "should get base" do
    get login_base_url
    assert_response :success
  end
end
