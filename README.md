# how it works

```
sequenceDiagram
    participant Caller
    participant Twilio
    participant Your App
    participant AI Assistant
    participant Speech-to-Text Service

    Caller->>Twilio: Incoming call
    Twilio->>Your App: Webhook - new call
    Your App->>Twilio: TwiML to start recording
    Twilio->>Caller: Connect call
    Twilio->>Your App: Start recording
    loop Conversation
        Caller->>Twilio: Speech
        Twilio->>Your App: Stream audio
        Your App->>Speech-to-Text Service: Convert speech to text
        Speech-to-Text Service->>Your App: Transcribed text
        Your App->>AI Assistant: Process transcribed text
        AI Assistant->>Your App: Generate response
        Your App->>Twilio: TwiML for AI response
        Twilio->>Caller: AI response audio
    end
    Caller->>Twilio: End call
    Twilio->>Your App: Call ended webhook
    Twilio->>Your App: Send recording file
    Your App->>Speech-to-Text Service: Convert full recording to text
    Speech-to-Text Service->>Your App: Full call transcript
```

![Sequence Diagram](./requirements/seq%20diagram.png)

# setup for local development aka how to run it on your machine

```
bundle install
```

```
rails db:migrate
```

provide your own `.env` file and credentials:

- Create a new project in Twilio and obtain your credentials
- Create a new project in OpenAI and obtain your credentials (speech-to-text model)
- Create a new project in ElevenLabs and obtain your credentials (text-to-speech model)

```
rails s
```

rails started on port 5000

```
ngrok http 5000
```

use ngrok url in twilio for your app url
