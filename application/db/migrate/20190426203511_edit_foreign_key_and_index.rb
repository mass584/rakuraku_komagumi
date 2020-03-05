class EditForeignKeyAndIndex < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :classnumbers, :teachers
    remove_foreign_key :classnumbers, :students
    add_foreign_key :classnumbers, :students, on_update: :cascade, on_delete: :restrict
    remove_foreign_key :studentrequests, :students
    add_foreign_key :studentrequests, :students, on_update: :cascade, on_delete: :restrict
    remove_foreign_key :teacherrequests, :teachers
    add_foreign_key :teacherrequests, :teachers, on_update: :cascade, on_delete: :restrict
    remove_foreign_key :schedules, :students
    add_foreign_key :schedules, :students, on_update: :cascade, on_delete: :restrict
    remove_foreign_key :schedules, :teachers
    remove_foreign_key :schedules, :timetables
    add_foreign_key :studentrequestmasters, :schedulemasters, on_update: :cascade, on_delete: :cascade
    add_foreign_key :teacherrequestmasters, :schedulemasters, on_update: :cascade, on_delete: :cascade
    add_foreign_key :teacher_schedulemaster_mappings, :schedulemasters, on_update: :cascade, on_delete: :cascade
    add_foreign_key :teacher_schedulemaster_mappings, :teachers, on_update: :cascade, on_delete: :restrict
    add_foreign_key :student_schedulemaster_mappings, :schedulemasters, on_update: :cascade, on_delete: :cascade
    add_foreign_key :student_schedulemaster_mappings, :students, on_update: :cascade, on_delete: :restrict
    add_foreign_key :teacher_subject_mappings, :subjects, on_update: :cascade, on_delete: :cascade
    add_foreign_key :teacher_subject_mappings, :teachers, on_update: :cascade, on_delete: :cascade
    add_foreign_key :student_subject_mappings, :subjects, on_update: :cascade, on_delete: :cascade
    add_foreign_key :student_subject_mappings, :students, on_update: :cascade, on_delete: :cascade
  end
end
