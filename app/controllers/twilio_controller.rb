require 'typhoeus'

class TwilioController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :create_twillio_call_log, only: [:voice]

  def voice
    if true
      response = Twilio::TwiML::VoiceResponse.new do |r|
        r.redirect(twilio_play_ai_voice_url, method: 'GET')
      end
    else
      response = Twilio::TwiML::VoiceResponse.new do |r|
        r.say(message: 'Hello, thank you for calling. This is a test response from your Rails application.')
        r.pause(length: 1)
        r.say(message: 'Goodbye!')
      end
    end

    render xml: response.to_s
  end

  def play_ai_voice
    service = ElevenLabsService.new
    welcome_message = "Hello, thank you for calling."
    question = "What would you like to know?"

    welcome_filename = service.text_to_speech(welcome_message)
    question_filename = service.text_to_speech(question)

    response = Twilio::TwiML::VoiceResponse.new do |r|
      r.play(url: audio_file_url(filename: File.basename(welcome_filename)))
      r.pause(length: 1)

      r.play(url: audio_file_url(filename: File.basename(question_filename)))
      r.record(
        action: twilio_loopback_callback_url,
        method: 'POST',
        maxLength: 10,
        playBeep: true,
        trim: 'trim-silence'
      )
    end

    render xml: response.to_s
  end

  def loopback_callback
    #recording_sid = params['RecordingSid']
    call_sid = params['CallSid']
    # Construct the Twilio API URL for the recording
    # recording_url = "https://api.twilio.com/2010-04-01/Accounts/#{ENV['TWILIO_ACCOUNT_SID']}/Recordings/#{recording_sid}"
    recording_url = params['RecordingUrl']

    messages = TwilioRecording.where(call_sid: call_sid).order(created_at: :asc).pluck(:transcription)

    if recording_url && call_sid
      max_retries = 5
      retry_count = 0
      success = false

      begin
        while retry_count < max_retries && !success
          # Configure Typhoeus request with timeout
          request = Typhoeus::Request.new(
            "#{recording_url}.mp3",
            method: :get,
            userpwd: "#{ENV['TWILIO_ACCOUNT_SID']}:#{ENV['TWILIO_AUTH_TOKEN']}",
            headers: { 'Content-Type' => 'audio/mpeg' },
            timeout: 500 # 500ms timeout
          )

          # Execute the request
          response = request.run

          if response.success?
            success = true
            recording_content = response.body
            
            # Save the recording to local storage
            filename = "#{call_sid}_#{Time.now.to_i}.mp3"
            path = Rails.root.join('storage', 'recordings', filename)
            File.open(path, 'wb') do |file|
              file.write(recording_content)
            end

            # Save the recording information to the database
            twilio_call_log = TwilioCallLog.find_or_create_by(call_sid: call_sid)
            twilio_recording = TwilioRecording.create(
              twilio_call_log: twilio_call_log,
              recording_path: path.to_s,
              call_sid: call_sid
            )
          else
            retry_count += 1
            Rails.logger.warn "Failed to download Twilio recording: HTTP #{response.code}. Retry #{retry_count} of #{max_retries}."
            sleep(0.5) # Wait for 500ms before retrying
          end
        end

        unless success
          Rails.logger.error "Failed to download Twilio recording after #{max_retries} retries: HTTP #{response.code}"
          # Handle the error appropriately
        end
      rescue StandardError => e
        Rails.logger.error "Error processing Twilio recording: #{e.message}"
        # Handle the error appropriately
      end
    end

    response = if success

      speech_to_text_service = SpeechToTextService.new
      transcription = speech_to_text_service.transcribe_and_process(path).downcase

      if transcription.include?('yes') || transcription.include?('no')
        # close the call
        # Schedule a call back with backgroud task sidekiq
        # CallBackJob.perform_later(call_sid)
        Rails.logger.info "Closing the call"
        response = Twilio::TwiML::VoiceResponse.new do |r|
          r.say(message: "We've got your response. Our best AI assistant is working on your request. I'll cool you back in a minute.")
        end
        render xml: response.to_s and return
      end

      twilio_recording.update(transcription: transcription)

      service = ElevenLabsService.new
      goodbye_message = "You said '#{transcription}'"
      goodbye_filename = service.text_to_speech(goodbye_message)

      confirm_message = "We got your response. Please confirm your response by saying 'yes' or 'no'."
      confirm_filename = service.text_to_speech(confirm_message)

      Twilio::TwiML::VoiceResponse.new do |r|
        r.play(url: audio_file_url(filename: File.basename(goodbye_filename)))

        r.play(url: audio_file_url(filename: File.basename(confirm_filename)))

        r.record(
          action: twilio_loopback_callback_url,
          method: 'POST',
          maxLength: 10,
          playBeep: true,
          trim: 'trim-silence'
        )
      end
    else
      Twilio::TwiML::VoiceResponse.new do |r|
        r.say(message: 'We couldn\'t get your response. Goodbye!')
      end
    end
    
    render xml: response.to_s
  end

end
