class ApplicationController < ActionController::Base

  private

  def create_twillio_call_log
    TwilioCallLog.create!(
      call_sid: params['CallSid'],
      from: params['From'],
      to: params['To'],
      direction: params['Direction'],
      status: params['CallStatus'],
      parameters: params.to_unsafe_h  # Store all parameters as JSON
    )
  end
end
