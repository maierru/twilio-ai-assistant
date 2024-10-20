class AddTranscriptionToTwilioRecordings < ActiveRecord::Migration[7.1]
  def change
    add_column :twilio_recordings, :transcription, :text
    add_column :twilio_recordings, :transcription_status, :string
  end
end
