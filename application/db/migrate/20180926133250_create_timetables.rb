class CreateTimetables < ActiveRecord::Migration[5.2]
  def change
    create_table :timetables do |t|
      t.integer :term_id, null: false
      t.date :date, null: false
      t.integer :period, null: false
      t.integer :status, null: false
      t.timestamps
    end
    add_foreign_key :timetables, :terms, on_update: :cascade, on_delete: :cascade
    add_index :timetables, [:term_id, :date, :period], unique: true
  end
end
