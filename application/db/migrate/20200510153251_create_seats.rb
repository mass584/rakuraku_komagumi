class CreateSeats < ActiveRecord::Migration[5.2]
  def change
    create_table :seats do |t|
      t.integer :term_id, null: false
      t.integer :timetable_id, null: false
      t.integer :term_teacher_id
      t.integer :seat_index, null: false
      t.integer :position_count, null: false
      t.timestamps
    end
    add_index :seats, [:term_id, :timetable_id, :seat_index], unique: true
    add_foreign_key :seats, :terms, on_update: :cascade, on_delete: :cascade
    add_foreign_key :seats, :timetables, on_update: :cascade, on_delete: :cascade
  end
end
