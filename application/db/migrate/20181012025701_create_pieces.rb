class CreatePieces < ActiveRecord::Migration[5.2]
  def change
    create_table :pieces do |t|
      t.integer :term_id, null: false
      t.integer :student_id, null: false
      t.integer :teacher_id
      t.integer :subject_id, null: false
      t.integer :timetable_id
      t.integer :status, null: false
      t.timestamps
    end
    add_foreign_key :pieces, :terms, on_update: :cascade, on_delete: :cascade
    add_foreign_key :pieces, :students, on_update: :cascade, on_delete: :restrict
    add_foreign_key :pieces, :subjects, on_update: :cascade, on_delete: :restrict
  end
end
