class CreateTimetables < ActiveRecord::Migration[5.2]
  def change
    create_table :timetables do |t|
      t.integer :schedulemaster_id, null: false
      t.date :scheduledate, null: false
      t.integer :classnumber, null: false
      t.integer :status, null: false
      t.timestamps
    end
    add_foreign_key :timetables, :schedulemasters, on_update: :cascade, on_delete: :cascade
    add_index :timetables, [:schedulemaster_id, :scheduledate, :classnumber], unique: true, name: 'index_timetables'
  end
end
