class CreateTimetablemasters < ActiveRecord::Migration[5.2]
  def change
    create_table :timetablemasters do |t|
      t.integer :schedulemaster_id, null: false
      t.integer :classnumber, null: false
      t.time :begintime
      t.time :endtime
      t.timestamps
    end
    add_foreign_key :timetablemasters, :schedulemasters, on_update: :cascade, on_delete: :cascade
    add_index :timetablemasters, [:schedulemaster_id, :classnumber], unique: true
  end
end
