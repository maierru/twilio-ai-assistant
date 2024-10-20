class SpeechToTextService
  OPENAI_API_URL = 'https://api.openai.com/v1'

  def initialize
    @openai_api_key = ENV['OPENAI_API_KEY_PROJECT']
    raise "OPENAI_API_KEY not set in environment" if @openai_api_key.nil? || @openai_api_key.empty?
  end

  def transcribe_and_process(audio_file_path)
    # Step 1: Convert audio to text using OpenAI's Whisper model
    transcription = transcribe_audio(audio_file_path)

    puts "Transcription: #{transcription}"
    # Step 2: Process the transcription with GPT
    # processed_text = process_with_gpt(transcription)

    transcription
  end

  private

  def transcribe_audio(audio_file_path)
    audio_content = File.open(audio_file_path, 'rb')

    response = Typhoeus.post(
      "#{OPENAI_API_URL}/audio/transcriptions",
      headers: {
        'Authorization' => "Bearer #{@openai_api_key}",
        'Content-Type' => 'multipart/form-data'
      },
      body: {
        file: audio_content,
        model: 'whisper-1'
      }
    )

    if response.success?
      result = JSON.parse(response.body)
      puts "Whisper result: #{result['text']}"
      result['text']
    else
      raise "Whisper API error: #{response.code} - #{response.body}"
    end
  end

  def process_with_gpt(transcription)
    request_body = {
      model: 'gpt-4',
      messages: [
        { role: 'system', content: 'You are a helpful assistant.' },
        { role: 'user', content: "Process this transcription: #{transcription}" }
      ],
      max_tokens: 1000
    }

    response = Typhoeus.post(
      "#{OPENAI_API_URL}/chat/completions",
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{@openai_api_key}"
      },
      body: request_body.to_json
    )

    if response.success?
      result = JSON.parse(response.body)
      result['choices'][0]['message']['content']
    else
      raise "GPT API error: #{response.code} - #{response.body}"
    end
  end
end

