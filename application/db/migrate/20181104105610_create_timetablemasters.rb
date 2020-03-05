class CreateTimetablemasters < ActiveRecord::Migration[5.2]
  def change
    create_table :timetablemasters do |t|
      t.integer :schedulemaster_id, null: false
      t.integer :period, null: false
      t.time :begin_at
      t.time :end_at
      t.timestamps
    end
    add_foreign_key :timetablemasters, :schedulemasters, on_update: :cascade, on_delete: :cascade
    add_index :timetablemasters, [:schedulemaster_id, :period], unique: true
  end
end
