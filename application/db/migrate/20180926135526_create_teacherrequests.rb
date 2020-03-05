class CreateTeacherrequests < ActiveRecord::Migration[5.2]
  def change
    create_table :teacherrequests do |t|
      t.integer :schedulemaster_id, null: false
      t.integer :teacher_id, null: false
      t.integer :timetable_id, null: false
      t.timestamps
    end
    add_foreign_key :teacherrequests, :schedulemasters, on_update: :cascade, on_delete: :cascade
    add_foreign_key :teacherrequests, :teachers, on_update: :cascade, on_delete: :cascade
    add_foreign_key :teacherrequests, :timetables, on_update: :cascade, on_delete: :cascade
    add_index :teacherrequests, [:schedulemaster_id, :teacher_id, :timetable_id], unique: true, name: 'index_teacherrequests'
  end
end
