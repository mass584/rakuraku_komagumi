# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_07_03_014027) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "begin_end_times", force: :cascade do |t|
    t.integer "term_id", null: false
    t.integer "period", null: false
    t.string "begin_at", null: false
    t.string "end_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["term_id", "period"], name: "index_begin_end_times_on_term_id_and_period", unique: true
  end

  create_table "contracts", force: :cascade do |t|
    t.integer "term_id", null: false
    t.integer "student_term_id", null: false
    t.integer "subject_term_id", null: false
    t.integer "teacher_term_id"
    t.integer "count", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["student_term_id", "subject_term_id"], name: "index_contracts_on_student_term_id_and_subject_term_id", unique: true
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "pieces", force: :cascade do |t|
    t.integer "term_id", null: false
    t.integer "contract_id", null: false
    t.integer "seat_id"
    t.boolean "is_fixed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rooms", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "encrypted_password", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.index ["confirmation_token"], name: "index_rooms_on_confirmation_token", unique: true
    t.index ["email"], name: "index_rooms_on_email", unique: true
    t.index ["reset_password_token"], name: "index_rooms_on_reset_password_token", unique: true
  end

  create_table "seats", force: :cascade do |t|
    t.integer "term_id", null: false
    t.integer "timetable_id", null: false
    t.integer "number", null: false
    t.integer "teacher_term_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["timetable_id", "number"], name: "index_seats_on_timetable_id_and_number", unique: true
  end

  create_table "student_requests", force: :cascade do |t|
    t.integer "term_id", null: false
    t.integer "student_term_id", null: false
    t.integer "timetable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["term_id", "student_term_id", "timetable_id"], name: "student_request_index", unique: true
  end

  create_table "student_subjects", force: :cascade do |t|
    t.integer "student_id", null: false
    t.integer "subject_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["student_id", "subject_id"], name: "index_student_subjects_on_student_id_and_subject_id", unique: true
  end

  create_table "student_terms", force: :cascade do |t|
    t.integer "student_id", null: false
    t.integer "term_id", null: false
    t.integer "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["term_id", "student_id"], name: "index_student_terms_on_term_id_and_student_id", unique: true
  end

  create_table "students", force: :cascade do |t|
    t.integer "room_id", null: false
    t.string "name", null: false
    t.string "name_kana", null: false
    t.integer "gender", null: false
    t.integer "birth_year", null: false
    t.string "school_name", null: false
    t.string "email", null: false
    t.string "tel", null: false
    t.string "zip", null: false
    t.string "address", null: false
    t.boolean "is_deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subject_terms", force: :cascade do |t|
    t.integer "subject_id", null: false
    t.integer "term_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["term_id", "subject_id"], name: "index_subject_terms_on_term_id_and_subject_id", unique: true
  end

  create_table "subjects", force: :cascade do |t|
    t.integer "room_id", null: false
    t.string "name", null: false
    t.integer "order", null: false
    t.boolean "is_deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "teacher_requests", force: :cascade do |t|
    t.integer "term_id", null: false
    t.integer "teacher_term_id", null: false
    t.integer "timetable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["term_id", "teacher_term_id", "timetable_id"], name: "teacher_request_index", unique: true
  end

  create_table "teacher_subjects", force: :cascade do |t|
    t.integer "teacher_id", null: false
    t.integer "subject_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["teacher_id", "subject_id"], name: "index_teacher_subjects_on_teacher_id_and_subject_id", unique: true
  end

  create_table "teacher_terms", force: :cascade do |t|
    t.integer "teacher_id", null: false
    t.integer "term_id", null: false
    t.integer "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["term_id", "teacher_id"], name: "index_teacher_terms_on_term_id_and_teacher_id", unique: true
  end

  create_table "teachers", force: :cascade do |t|
    t.integer "room_id", null: false
    t.string "name", null: false
    t.string "name_kana", null: false
    t.string "email", null: false
    t.string "tel", null: false
    t.string "zip", null: false
    t.string "address", null: false
    t.boolean "is_deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "terms", force: :cascade do |t|
    t.integer "room_id", null: false
    t.string "name", null: false
    t.integer "type", null: false
    t.integer "year", null: false
    t.date "begin_at", null: false
    t.date "end_at", null: false
    t.integer "max_period", null: false
    t.integer "max_seat", null: false
    t.integer "max_piece", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "timetables", force: :cascade do |t|
    t.integer "term_id", null: false
    t.date "date", null: false
    t.integer "period", null: false
    t.boolean "is_closed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["term_id", "date", "period"], name: "index_timetables_on_term_id_and_date_and_period", unique: true
  end

  add_foreign_key "begin_end_times", "terms", on_update: :cascade, on_delete: :cascade
  add_foreign_key "contracts", "student_terms", on_update: :cascade, on_delete: :cascade
  add_foreign_key "contracts", "subject_terms", on_update: :cascade, on_delete: :cascade
  add_foreign_key "contracts", "terms", on_update: :cascade, on_delete: :cascade
  add_foreign_key "pieces", "contracts", on_update: :cascade, on_delete: :restrict
  add_foreign_key "pieces", "terms", on_update: :cascade, on_delete: :cascade
  add_foreign_key "seats", "terms", on_update: :cascade, on_delete: :cascade
  add_foreign_key "seats", "timetables", on_update: :cascade, on_delete: :cascade
  add_foreign_key "student_requests", "student_terms", on_update: :cascade, on_delete: :cascade
  add_foreign_key "student_requests", "terms", on_update: :cascade, on_delete: :cascade
  add_foreign_key "student_requests", "timetables", on_update: :cascade, on_delete: :cascade
  add_foreign_key "student_subjects", "students", on_update: :cascade, on_delete: :cascade
  add_foreign_key "student_subjects", "subjects", on_update: :cascade, on_delete: :cascade
  add_foreign_key "student_terms", "students", on_update: :cascade, on_delete: :restrict
  add_foreign_key "student_terms", "terms", on_update: :cascade, on_delete: :cascade
  add_foreign_key "students", "rooms", on_update: :cascade, on_delete: :restrict
  add_foreign_key "subject_terms", "subjects", on_update: :cascade, on_delete: :restrict
  add_foreign_key "subject_terms", "terms", on_update: :cascade, on_delete: :cascade
  add_foreign_key "subjects", "rooms", on_update: :cascade, on_delete: :restrict
  add_foreign_key "teacher_requests", "teacher_terms", on_update: :cascade, on_delete: :cascade
  add_foreign_key "teacher_requests", "terms", on_update: :cascade, on_delete: :cascade
  add_foreign_key "teacher_requests", "timetables", on_update: :cascade, on_delete: :cascade
  add_foreign_key "teacher_subjects", "subjects", on_update: :cascade, on_delete: :cascade
  add_foreign_key "teacher_subjects", "teachers", on_update: :cascade, on_delete: :cascade
  add_foreign_key "teacher_terms", "teachers", on_update: :cascade, on_delete: :restrict
  add_foreign_key "teacher_terms", "terms", on_update: :cascade, on_delete: :cascade
  add_foreign_key "teachers", "rooms", on_update: :cascade, on_delete: :restrict
  add_foreign_key "terms", "rooms", on_update: :cascade, on_delete: :restrict
  add_foreign_key "timetables", "terms", on_update: :cascade, on_delete: :cascade
end
