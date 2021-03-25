class CreateStudentVacancies < ActiveRecord::Migration[5.2]
  def change
    create_table :student_vacancies do |t|
      t.integer :term_student_id, null: false
      t.integer :timetable_id, null: false
      t.boolean :is_vacant, default: false, null: false
      t.timestamps
    end
    add_index :student_vacancies, [:term_student_id, :timetable_id], unique: true
    add_foreign_key :student_vacancies, :term_students, on_update: :cascade, on_delete: :cascade
    add_foreign_key :student_vacancies, :timetables, on_update: :cascade, on_delete: :cascade
  end
end
