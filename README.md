# Twilio AI Assistant

call me at +1(864)732-1335

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

# Deploying

- create docker image
- save docker image to tar file
- upload tar file to server
- unpack tar file
- run docker container

locally:

```
docker build -t twilio-ai-assistant .
docker save -o twilio-ai-assistant.tar twilio-ai-assistant
scp twilio-ai-assistant.tar root@1.1.1.1:/root/
```

on the server:

```
sudo docker load -i twilio-ai-assistant.tar
sudo docker run --rm -d -p 5000:5000 \
  -e RAILS_MASTER_KEY=00470d9456f92c1ce0109a28c6ec56e2 \
  -e TWILIO_ACCOUNT_SID=your_twilio_account_sid \
  -e TWILIO_AUTH_TOKEN=your_twilio_auth_token \
  -e OPENAI_API_KEY_PROJECT=your_openai_api_key \
  -e ELEVENLABS_API_KEY=your_elevenlabs_api_key \
  twilio-ai-assistant
```
