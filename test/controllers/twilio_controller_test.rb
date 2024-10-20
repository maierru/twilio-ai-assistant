require "test_helper"

class TwilioControllerTest < ActionDispatch::IntegrationTest
  test "should get voice" do
    get twilio_voice_url
    assert_response :success
  end
end
