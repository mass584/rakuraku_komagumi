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

ActiveRecord::Schema.define(version: 2021_04_23_053342) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "begin_end_times", force: :cascade do |t|
    t.integer "term_id", null: false
    t.integer "period_index", null: false
    t.time "begin_at", null: false
    t.time "end_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["term_id", "period_index"], name: "index_begin_end_times_on_term_id_and_period_index", unique: true
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

  create_table "group_contracts", force: :cascade do |t|
    t.integer "term_id", null: false
    t.integer "term_group_id", null: false
    t.integer "term_student_id", null: false
    t.boolean "is_contracted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["term_id", "term_group_id", "term_student_id"], name: "group_contracts_main_index", unique: true
  end

  create_table "groups", force: :cascade do |t|
    t.integer "room_id", null: false
    t.string "name", null: false
    t.integer "order", null: false
    t.boolean "is_deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "short_name", null: false
  end

  create_table "rooms", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "seats", force: :cascade do |t|
    t.integer "term_id", null: false
    t.integer "timetable_id", null: false
    t.integer "term_teacher_id"
    t.integer "seat_index", null: false
    t.integer "position_count", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["term_id", "timetable_id", "seat_index"], name: "index_seats_on_term_id_and_timetable_id_and_seat_index", unique: true
  end

  create_table "student_optimization_rules", force: :cascade do |t|
    t.integer "term_id", null: false
    t.integer "school_grade", null: false
    t.integer "occupation_limit", null: false
    t.integer "occupation_costs", null: false, array: true
    t.integer "blank_limit", null: false
    t.integer "blank_costs", null: false, array: true
    t.integer "interval_cutoff", null: false
    t.integer "interval_costs", null: false, array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "student_vacancies", force: :cascade do |t|
    t.integer "term_student_id", null: false
    t.integer "timetable_id", null: false
    t.boolean "is_vacant", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["term_student_id", "timetable_id"], name: "index_student_vacancies_on_term_student_id_and_timetable_id", unique: true
  end

  create_table "students", force: :cascade do |t|
    t.integer "room_id", null: false
    t.string "name", null: false
    t.string "email", null: false
    t.integer "school_grade", null: false
    t.boolean "is_deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "teacher_optimization_rules", force: :cascade do |t|
    t.integer "term_id", null: false
    t.integer "single_cost", null: false
    t.integer "different_pair_cost", null: false
    t.integer "occupation_limit", null: false
    t.integer "occupation_costs", null: false, array: true
    t.integer "blank_limit", null: false
    t.integer "blank_costs", null: false, array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "teacher_vacancies", force: :cascade do |t|
    t.integer "term_teacher_id", null: false
    t.integer "timetable_id", null: false
    t.boolean "is_vacant", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["term_teacher_id", "timetable_id"], name: "index_teacher_vacancies_on_term_teacher_id_and_timetable_id", unique: true
  end

  create_table "teachers", force: :cascade do |t|
    t.integer "room_id", null: false
    t.string "name", null: false
    t.string "email", null: false
    t.boolean "is_deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "term_groups", force: :cascade do |t|
    t.integer "term_id", null: false
    t.integer "group_id", null: false
    t.integer "term_teacher_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["term_id", "group_id"], name: "index_term_groups_on_term_id_and_group_id", unique: true
  end

  create_table "term_students", force: :cascade do |t|
    t.integer "term_id", null: false
    t.integer "student_id", null: false
    t.integer "school_grade", null: false
    t.integer "vacancy_status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["term_id", "student_id"], name: "index_term_students_on_term_id_and_student_id", unique: true
  end

  create_table "term_teachers", force: :cascade do |t|
    t.integer "term_id", null: false
    t.integer "teacher_id", null: false
    t.integer "vacancy_status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "row_order"
    t.index ["term_id", "teacher_id"], name: "index_term_teachers_on_term_id_and_teacher_id", unique: true
  end

  create_table "term_tutorials", force: :cascade do |t|
    t.integer "term_id", null: false
    t.integer "tutorial_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["term_id", "tutorial_id"], name: "index_term_tutorials_on_term_id_and_tutorial_id", unique: true
  end

  create_table "terms", force: :cascade do |t|
    t.integer "room_id", null: false
    t.string "name", null: false
    t.integer "year", null: false
    t.integer "term_type", null: false
    t.date "begin_at", null: false
    t.date "end_at", null: false
    t.integer "period_count", null: false
    t.integer "seat_count", null: false
    t.integer "position_count", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "timetables", force: :cascade do |t|
    t.integer "term_id", null: false
    t.integer "term_group_id"
    t.integer "date_index", null: false
    t.integer "period_index", null: false
    t.boolean "is_closed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["term_id", "date_index", "period_index"], name: "index_timetables_on_term_id_and_date_index_and_period_index", unique: true
  end

  create_table "tutorial_contracts", force: :cascade do |t|
    t.integer "term_id", null: false
    t.integer "term_tutorial_id", null: false
    t.integer "term_student_id", null: false
    t.integer "term_teacher_id"
    t.integer "piece_count", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["term_id", "term_tutorial_id", "term_student_id"], name: "tutorial_contracts_main_index", unique: true
  end

  create_table "tutorial_pieces", force: :cascade do |t|
    t.integer "term_id", null: false
    t.integer "tutorial_contract_id", null: false
    t.integer "seat_id"
    t.boolean "is_fixed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["term_id"], name: "index_tutorial_pieces_on_term_id"
  end

  create_table "tutorials", force: :cascade do |t|
    t.integer "room_id", null: false
    t.string "name", null: false
    t.integer "order", null: false
    t.boolean "is_deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "short_name", null: false
  end

  create_table "users", force: :cascade do |t|
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
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "begin_end_times", "terms", on_update: :cascade, on_delete: :cascade
  add_foreign_key "group_contracts", "term_groups", on_update: :cascade, on_delete: :cascade
  add_foreign_key "group_contracts", "term_students", on_update: :cascade, on_delete: :cascade
  add_foreign_key "group_contracts", "terms", on_update: :cascade, on_delete: :cascade
  add_foreign_key "groups", "rooms", on_update: :cascade, on_delete: :restrict
  add_foreign_key "seats", "terms", on_update: :cascade, on_delete: :cascade
  add_foreign_key "seats", "timetables", on_update: :cascade, on_delete: :cascade
  add_foreign_key "student_optimization_rules", "terms", on_update: :cascade, on_delete: :cascade
  add_foreign_key "student_vacancies", "term_students", on_update: :cascade, on_delete: :cascade
  add_foreign_key "student_vacancies", "timetables", on_update: :cascade, on_delete: :cascade
  add_foreign_key "students", "rooms", on_update: :cascade, on_delete: :restrict
  add_foreign_key "teacher_optimization_rules", "terms", on_update: :cascade, on_delete: :cascade
  add_foreign_key "teacher_vacancies", "term_teachers", on_update: :cascade, on_delete: :cascade
  add_foreign_key "teacher_vacancies", "timetables", on_update: :cascade, on_delete: :cascade
  add_foreign_key "teachers", "rooms", on_update: :cascade, on_delete: :restrict
  add_foreign_key "term_groups", "groups", on_update: :cascade, on_delete: :restrict
  add_foreign_key "term_groups", "terms", on_update: :cascade, on_delete: :cascade
  add_foreign_key "term_students", "students", on_update: :cascade, on_delete: :restrict
  add_foreign_key "term_students", "terms", on_update: :cascade, on_delete: :cascade
  add_foreign_key "term_teachers", "teachers", on_update: :cascade, on_delete: :restrict
  add_foreign_key "term_teachers", "terms", on_update: :cascade, on_delete: :cascade
  add_foreign_key "term_tutorials", "terms", on_update: :cascade, on_delete: :cascade
  add_foreign_key "term_tutorials", "tutorials", on_update: :cascade, on_delete: :restrict
  add_foreign_key "terms", "rooms", on_update: :cascade, on_delete: :restrict
  add_foreign_key "timetables", "terms", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tutorial_contracts", "term_students", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tutorial_contracts", "term_tutorials", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tutorial_contracts", "terms", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tutorial_pieces", "terms", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tutorial_pieces", "tutorial_contracts", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tutorials", "rooms", on_update: :cascade, on_delete: :restrict
end
