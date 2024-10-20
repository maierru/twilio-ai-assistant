class CreateTwilioCallLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :twilio_call_logs do |t|
      t.string :call_sid
      t.string :from
      t.string :to
      t.string :direction
      t.string :status
      t.json :parameters

      t.timestamps
    end
  end
end
