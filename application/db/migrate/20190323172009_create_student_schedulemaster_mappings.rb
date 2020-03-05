class CreateStudentSchedulemasterMappings < ActiveRecord::Migration[5.2]
  def change
    create_table :student_schedulemaster_mappings do |t|
      t.integer :student_id, null: false
      t.integer :schedulemaster_id, null: false
      t.string  :grade, null: false
      t.timestamps
    end
    add_index :student_schedulemaster_mappings,
              [:schedulemaster_id, :student_id],
              name: 'index_student_schedulemaster_mapping',
              unique: true
  end
end
