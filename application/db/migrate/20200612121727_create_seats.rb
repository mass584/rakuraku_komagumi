class CreateSeats < ActiveRecord::Migration[5.2]
  def change
    create_table :seats do |t|
      t.integer :term_id, null: false
      t.integer :timetable_id, null: false
      t.integer :number, null: false
      t.integer :teacher_term_id
      t.timestamps
    end
    add_index :seats, [:timetable_id, :number], unique: true
    add_foreign_key :seats, :terms, on_update: :cascade, on_delete: :cascade
    add_foreign_key :seats, :timetables, on_update: :cascade, on_delete: :cascade
  end
end
