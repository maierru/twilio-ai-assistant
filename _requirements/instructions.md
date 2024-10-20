# Project overview

Use this instruction to build a voice assistant that can answer questions and help with tasks.

# Feature requirements

- We will use Rails to build the application.
- The assistant should answer questions and help with tasks.
- The assistant should be able to handle phone calls and voice messages.
- The assistant should be able to handle natural language processing.
- The assistant should be able to handle text-to-speech.

# Relevant docs

- We want to use the Twilio API to handle phone calls and voice messages.
  (documentation)[https://www.twilio.com/docs/voice]
- We want to use the OpenAI API to handle natural language processing.
  (documentation)[https://platform.openai.com/docs/api-reference]
- We want to use the ElevenLabs API to handle text-to-speech.
  (documentation)[https://elevenlabs.io/docs]
- We will use Rails to build the application.
  (guides)[https://guides.rubyonrails.org/getting_started.html]
  (api)[https://api.rubyonrails.org/]
- We will use Typhoeus to handle the HTTP requests.
  (documentation)[https://rubydoc.info/github/typhoeus/typhoeus/frames/Typhoeus/]
- We will use Dotenv to handle the environment variables.
  (documentation)[https://rubydoc.info/github/bkeepers/dotenv/main]
  reuse existing .env file and credentials if their present
- instead of using gems api use raw http requests with Typhoeus


# Current file structure

├── app
│   ├── assets
│   │   ├── config
│   │   │   └── manifest.js
│   │   ├── images
│   │   │   └── .keep
│   │   └── stylesheets
│   │       └── application.css
│   ├── channels
│   ├── controllers
│   │   ├── concerns
│   │   ├── application_controller.rb
│   │   ├── audio_files_controller.rb
│   │   └── twilio_controller.rb
│   ├── helpers
│   ├── javascript
│   │   ├── controllers
│   │   └── application.js
│   ├── jobs
│   ├── mailers
│   ├── models
│   ├── services
│   │   ├── eleven_labs_service.rb
│   │   └── speech_to_text_service.rb
│   └── views
│       └── layouts
│           ├── application.html.erb
│           ├── mailer.html.erb
│           └── mailer.text.erb
├── bin
├── config
├── db
├── lib
├── log
├── public
├── storage
├── test
├── tmp
├── vendor
├── .cursorules
└── .dockerignore

# RULES

- All new code should be added to the `app/` directory.
- All new tests should be added to the `test/` directory.
- do not modify .env file, use existing credentials if present

## ElevenLabs service (file eleven_labs_service.rb)

- use ElevenLabsService class to handle text-to-speech
- preserve the audio files in the storage/tts directory
- each combination of voice and text should have a unique filename for caching purposes
- hash of filename and text should be consistent
- use elevenlabs api key from .env file
- if we get the same text for the same voice, and we have the file, do not call the api again, just use the file (caching mechanism)
- do not allow external service calls to use defined voices, only use default voice

usage example:

```ruby
welcome_message = "Hello, thank you for calling. We'd like to ask you a question."
service = ElevenLabsService.new
welcome_filename = service.text_to_speech(welcome_message)
```

## Speech to text service (file speech_to_text_service.rb)

- use SpeechToTextService class to handle speech to text
- use open ai key from .env file
- use whisper-1 model
- return the text from the transcription

usage example:

```ruby
service = SpeechToTextService.new
text = service.speech_to_text(welcome_filename)
```

## Twilio calls

- reuse TwilioCallLog model to store the call logs
- reuse TwilioRecording model to store the recordings for related call logs

for example with some_action and create_call_log method:

```ruby

class TwilioController < ApplicationController
  before_action :create_twillio_call_log, only: [:some_action]

  def some_action

    ...
  end
  ... 
```

## Audio files (file audio_files_controller.rb)

- use AudioFilesController to handle the audio files (show action)
- use storage/tts directory to play the audio files

## Assistant (file assistant_controller.rb)

- main logic for the assistant

