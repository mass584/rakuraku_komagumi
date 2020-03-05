class CreateStudentrequests < ActiveRecord::Migration[5.2]
  def change
    create_table :studentrequests do |t|
      t.integer :schedulemaster_id, null: false
      t.integer :student_id, null: false
      t.integer :timetable_id, null: false
      t.timestamps
    end
    add_foreign_key :studentrequests, :schedulemasters, on_update: :cascade, on_delete: :cascade
    add_foreign_key :studentrequests, :students, on_update: :cascade, on_delete: :restrict
    add_foreign_key :studentrequests, :timetables, on_update: :cascade, on_delete: :cascade
    add_index :studentrequests, [:schedulemaster_id, :student_id, :timetable_id], unique: true, name: 'index_studentrequests'
  end
end
