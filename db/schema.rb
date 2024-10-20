# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_10_19_155631) do
  create_table "twilio_call_logs", force: :cascade do |t|
    t.string "call_sid"
    t.string "from"
    t.string "to"
    t.string "direction"
    t.string "status"
    t.json "parameters"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "twilio_recordings", force: :cascade do |t|
    t.integer "twilio_call_log_id", null: false
    t.string "recording_path"
    t.string "call_sid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "transcription"
    t.string "transcription_status"
    t.index ["call_sid"], name: "index_twilio_recordings_on_call_sid"
    t.index ["twilio_call_log_id"], name: "index_twilio_recordings_on_twilio_call_log_id"
  end

end
