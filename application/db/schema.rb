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

ActiveRecord::Schema.define(version: 2020_03_05_171553) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "classnumbers", force: :cascade do |t|
    t.integer "schedulemaster_id", null: false
    t.integer "student_id", null: false
    t.integer "teacher_id"
    t.integer "subject_id", null: false
    t.integer "number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["schedulemaster_id", "student_id", "subject_id"], name: "index_classnumbers", unique: true
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

  create_table "rooms", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_rooms_on_email", unique: true
  end

  create_table "schedulemasters", force: :cascade do |t|
    t.string "name", null: false
    t.integer "type", null: false
    t.date "begin_at", null: false
    t.date "end_at", null: false
    t.integer "max_period", null: false
    t.integer "max_seat", null: false
    t.integer "batch_status", null: false
    t.datetime "batch_begin_at"
    t.datetime "batch_end_at"
    t.text "batch_result"
    t.integer "batch_progress"
    t.integer "room_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "year", null: false
  end

  create_table "schedules", force: :cascade do |t|
    t.integer "schedulemaster_id", null: false
    t.integer "student_id", null: false
    t.integer "teacher_id"
    t.integer "subject_id", null: false
    t.integer "timetable_id"
    t.integer "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "student_schedulemaster_mappings", force: :cascade do |t|
    t.integer "student_id", null: false
    t.integer "schedulemaster_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["schedulemaster_id", "student_id"], name: "index_student_schedulemaster_mapping", unique: true
  end

  create_table "student_subject_mappings", force: :cascade do |t|
    t.integer "student_id", null: false
    t.integer "subject_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["student_id", "subject_id"], name: "index_student_subject_mapping", unique: true
  end

  create_table "studentrequestmasters", force: :cascade do |t|
    t.integer "schedulemaster_id", null: false
    t.integer "student_id", null: false
    t.integer "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["schedulemaster_id", "student_id"], name: "index_studentrequestmasters", unique: true
  end

  create_table "studentrequests", force: :cascade do |t|
    t.integer "schedulemaster_id", null: false
    t.integer "student_id", null: false
    t.integer "timetable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["schedulemaster_id", "student_id", "timetable_id"], name: "index_studentrequests", unique: true
  end

  create_table "students", force: :cascade do |t|
    t.string "name", null: false
    t.string "name_kana", null: false
    t.integer "gender", null: false
    t.integer "birth_year", null: false
    t.string "school"
    t.string "email"
    t.string "tel"
    t.string "zip"
    t.string "address"
    t.boolean "is_deleted", null: false
    t.integer "room_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subject_schedulemaster_mappings", force: :cascade do |t|
    t.integer "subject_id", null: false
    t.integer "schedulemaster_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["schedulemaster_id", "subject_id"], name: "index_subject_schedulemaster_mapping", unique: true
  end

  create_table "subjects", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "is_deleted", null: false
    t.integer "room_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "order", null: false
  end

  create_table "teacher_schedulemaster_mappings", force: :cascade do |t|
    t.integer "teacher_id", null: false
    t.integer "schedulemaster_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["schedulemaster_id", "teacher_id"], name: "index_teacher_schedulemaster_mapping", unique: true
  end

  create_table "teacher_subject_mappings", force: :cascade do |t|
    t.integer "subject_id", null: false
    t.integer "teacher_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subject_id", "teacher_id"], name: "index_teacher_subject_mappings_on_subject_id_and_teacher_id", unique: true
  end

  create_table "teacherrequestmasters", force: :cascade do |t|
    t.integer "schedulemaster_id", null: false
    t.integer "teacher_id", null: false
    t.integer "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["schedulemaster_id", "teacher_id"], name: "index_teacherrequestmasters", unique: true
  end

  create_table "teacherrequests", force: :cascade do |t|
    t.integer "schedulemaster_id", null: false
    t.integer "teacher_id", null: false
    t.integer "timetable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["schedulemaster_id", "teacher_id", "timetable_id"], name: "index_teacherrequests", unique: true
  end

  create_table "teachers", force: :cascade do |t|
    t.string "name", null: false
    t.string "name_kana", null: false
    t.string "email"
    t.string "tel"
    t.string "zip"
    t.string "address"
    t.boolean "is_deleted", null: false
    t.integer "room_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "timetablemasters", force: :cascade do |t|
    t.integer "schedulemaster_id", null: false
    t.integer "period", null: false
    t.time "begin_at"
    t.time "end_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["schedulemaster_id", "period"], name: "index_timetablemasters_on_schedulemaster_id_and_period", unique: true
  end

  create_table "timetables", force: :cascade do |t|
    t.integer "schedulemaster_id", null: false
    t.date "date", null: false
    t.integer "period", null: false
    t.integer "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["schedulemaster_id", "date", "period"], name: "index_timetables", unique: true
  end

  add_foreign_key "classnumbers", "schedulemasters", on_update: :cascade, on_delete: :cascade
  add_foreign_key "classnumbers", "students", on_update: :cascade, on_delete: :restrict
  add_foreign_key "classnumbers", "subjects", on_update: :cascade, on_delete: :restrict
  add_foreign_key "schedulemasters", "rooms", on_update: :cascade, on_delete: :restrict
  add_foreign_key "schedules", "schedulemasters", on_update: :cascade, on_delete: :cascade
  add_foreign_key "schedules", "students", on_update: :cascade, on_delete: :restrict
  add_foreign_key "schedules", "subjects", on_update: :cascade, on_delete: :restrict
  add_foreign_key "student_schedulemaster_mappings", "schedulemasters", on_update: :cascade, on_delete: :cascade
  add_foreign_key "student_schedulemaster_mappings", "students", on_update: :cascade, on_delete: :restrict
  add_foreign_key "student_subject_mappings", "students", on_update: :cascade, on_delete: :cascade
  add_foreign_key "student_subject_mappings", "subjects", on_update: :cascade, on_delete: :cascade
  add_foreign_key "studentrequestmasters", "schedulemasters", on_update: :cascade, on_delete: :cascade
  add_foreign_key "studentrequestmasters", "students", on_update: :cascade, on_delete: :restrict
  add_foreign_key "studentrequests", "schedulemasters", on_update: :cascade, on_delete: :cascade
  add_foreign_key "studentrequests", "students", on_update: :cascade, on_delete: :restrict
  add_foreign_key "studentrequests", "timetables", on_update: :cascade, on_delete: :cascade
  add_foreign_key "students", "rooms", on_update: :cascade, on_delete: :restrict
  add_foreign_key "subject_schedulemaster_mappings", "schedulemasters", on_update: :cascade, on_delete: :cascade
  add_foreign_key "subject_schedulemaster_mappings", "subjects", on_update: :cascade, on_delete: :restrict
  add_foreign_key "subjects", "rooms", on_update: :cascade, on_delete: :restrict
  add_foreign_key "teacher_schedulemaster_mappings", "schedulemasters", on_update: :cascade, on_delete: :cascade
  add_foreign_key "teacher_schedulemaster_mappings", "teachers", on_update: :cascade, on_delete: :restrict
  add_foreign_key "teacher_subject_mappings", "subjects", on_update: :cascade, on_delete: :cascade
  add_foreign_key "teacher_subject_mappings", "teachers", on_update: :cascade, on_delete: :cascade
  add_foreign_key "teacherrequestmasters", "schedulemasters", on_update: :cascade, on_delete: :cascade
  add_foreign_key "teacherrequestmasters", "teachers", on_update: :cascade, on_delete: :restrict
  add_foreign_key "teacherrequests", "schedulemasters", on_update: :cascade, on_delete: :cascade
  add_foreign_key "teacherrequests", "teachers", on_update: :cascade, on_delete: :restrict
  add_foreign_key "teacherrequests", "timetables", on_update: :cascade, on_delete: :cascade
  add_foreign_key "teachers", "rooms", on_update: :cascade, on_delete: :restrict
  add_foreign_key "timetablemasters", "schedulemasters", on_update: :cascade, on_delete: :cascade
  add_foreign_key "timetables", "schedulemasters", on_update: :cascade, on_delete: :cascade
end
