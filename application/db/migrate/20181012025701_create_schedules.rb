class CreateSchedules < ActiveRecord::Migration[5.2]
  def change
    create_table :schedules do |t|
      t.integer :schedulemaster_id, null: false
      t.integer :student_id, null: false
      t.integer :teacher_id
      t.integer :subject_id, null: false
      t.integer :timetable_id
      t.integer :status, null: false
      t.timestamps
    end
    add_foreign_key :schedules, :schedulemasters, on_update: :cascade, on_delete: :cascade
    add_foreign_key :schedules, :students, on_update: :cascade, on_delete: :nullify
    add_foreign_key :schedules, :teachers, on_update: :cascade, on_delete: :nullify
    add_foreign_key :schedules, :subjects, on_update: :cascade, on_delete: :restrict
    add_foreign_key :schedules, :timetables, on_update: :cascade, on_delete: :restrict
  end
end
