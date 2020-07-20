class CreateStudentRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :student_requests do |t|
      t.integer :term_id, null: false
      t.integer :student_term_id, null: false
      t.integer :timetable_id, null: false
      t.timestamps
    end
    add_index :student_requests, [:term_id, :student_term_id, :timetable_id], unique: true, name: 'student_request_index'
    add_foreign_key :student_requests, :terms, on_update: :cascade, on_delete: :cascade
    add_foreign_key :student_requests, :student_terms, on_update: :cascade, on_delete: :cascade
    add_foreign_key :student_requests, :timetables, on_update: :cascade, on_delete: :cascade
  end
end
