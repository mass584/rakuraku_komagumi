class CreateTeacherRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :teacher_requests do |t|
      t.integer :term_id, null: false
      t.integer :teacher_term_id, null: false
      t.integer :timetable_id, null: false
      t.timestamps
    end
    add_index :teacher_requests, [:term_id, :teacher_term_id, :timetable_id], unique: true, name: 'teacher_request_index'
    add_foreign_key :teacher_requests, :terms, on_update: :cascade, on_delete: :cascade
    add_foreign_key :teacher_requests, :teacher_terms, on_update: :cascade, on_delete: :cascade
    add_foreign_key :teacher_requests, :timetables, on_update: :cascade, on_delete: :cascade
  end
end
