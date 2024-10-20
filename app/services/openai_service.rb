require 'typhoeus'
require 'json'

class OpenaiService
  BASE_URL = 'https://api.openai.com/v1'

  def initialize
    @api_key = ENV['OPENAI_API_KEY']
  end

  def chat_completion(messages)
    response = Typhoeus.post(
      "#{BASE_URL}/chat/completions",
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{@api_key}"
      },
      body: {
        model: 'gpt-3.5-turbo',
        messages: messages
      }.to_json
    )

    JSON.parse(response.body)['choices'][0]['message']['content']
  end
end
