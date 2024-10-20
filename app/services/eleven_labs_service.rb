require 'typhoeus'
require 'json'
require 'dotenv'
require 'digest'
require 'fileutils'

class ElevenLabsService
  BASE_URL = 'https://api.elevenlabs.io/v1'.freeze
  VOICE_ID = 'pNInz6obpgDQGcFmaJgB'.freeze # Adam voice
  # VOICE_ID = 'Cj8SfwmqpX3NWgqn7XM4'.freeze # Oleg voice
  STORAGE_DIR = Rails.root.join('storage', 'tts')

  def initialize
    Dotenv.load
    @api_key = ENV['ELEVENLABS_API_KEY']
    FileUtils.mkdir_p(STORAGE_DIR) unless File.directory?(STORAGE_DIR)
  end

  def text_to_speech(text)
    filename = generate_filename(text)
    full_path = File.join(STORAGE_DIR, filename)
    
    if File.exist?(full_path)
      puts "Audio file already exists: #{full_path}"
      return full_path
    end

    response = Typhoeus.post(
      "#{BASE_URL}/text-to-speech/#{VOICE_ID}",
      headers: {
        'Accept' => 'audio/mpeg',
        'xi-api-key' => @api_key,
        'Content-Type' => 'application/json'
      },
      body: JSON.generate({
        text: text,
        model_id: 'eleven_monolingual_v1',
        voice_settings: {
          stability: 0.5,
          similarity_boost: 0.5
        }
      })
    )

    if response.success?
      save_audio(response.body, full_path)
      
    else
      puts "Error: #{response.code} - #{response.body}"
      nil
    end
  end

  private

  def save_audio(audio_data, full_path)
    File.open(full_path, 'wb') do |file|
      file.write(audio_data)
    end
    puts "Audio saved as #{full_path}"
    full_path
  end

  def generate_filename(text)
    hash = Digest::MD5.hexdigest(text)[0..7]
    "audio_#{VOICE_ID}_#{hash}.mp3"
  end
end
