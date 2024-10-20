class CreateTwilioRecordings < ActiveRecord::Migration[7.1]
  def change
    create_table :twilio_recordings do |t|
      t.references :twilio_call_log, null: false, foreign_key: false
      t.string :recording_path
      t.string :call_sid
      t.timestamps
    end
    add_index :twilio_recordings, :call_sid
  end
end
