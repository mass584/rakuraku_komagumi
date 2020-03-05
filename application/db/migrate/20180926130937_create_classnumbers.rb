class CreateClassnumbers < ActiveRecord::Migration[5.2]
  def change
    create_table :classnumbers do |t|
      t.integer :schedulemaster_id, null: false
      t.integer :student_id, null: false
      t.integer :teacher_id
      t.integer :subject_id, null: false
      t.integer :number, null: false
      t.timestamps
    end
    add_foreign_key :classnumbers, :schedulemasters, on_update: :cascade, on_delete: :cascade
    add_foreign_key :classnumbers, :students, on_update: :cascade, on_delete: :nullify
    add_foreign_key :classnumbers, :teachers, on_update: :cascade, on_delete: :nullify
    add_foreign_key :classnumbers, :subjects, on_update: :cascade, on_delete: :restrict
    add_index :classnumbers, [:schedulemaster_id, :student_id, :subject_id], unique: true, name: 'index_classnumbers'
  end
end
