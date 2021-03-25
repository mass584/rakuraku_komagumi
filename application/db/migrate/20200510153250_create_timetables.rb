class CreateTimetables < ActiveRecord::Migration[5.2]
  def change
    create_table :timetables do |t|
      t.integer :term_id, null: false
      t.integer :term_group_id
      t.integer :date_index, null: false
      t.integer :period_index, null: false
      t.boolean :is_closed, default: false, null: false
      t.timestamps
    end
    add_index :timetables, [:term_id, :date_index, :period_index], unique: true
    add_foreign_key :timetables, :terms, on_update: :cascade, on_delete: :cascade
  end
end
