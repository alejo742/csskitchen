require "test_helper"

class ChallengeViewControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get challenge_view_index_url
    assert_response :success
  end
end
