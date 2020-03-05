class CreateStudentrequestmasters < ActiveRecord::Migration[5.2]
  def change
    create_table :studentrequestmasters do |t|
      t.integer :schedulemaster_id, null: false
      t.integer :student_id, null: false
      t.integer :status, null: false
      t.timestamps
    end
    add_index :studentrequestmasters, [:schedulemaster_id, :student_id], unique: true, name: 'index_studentrequestmasters'
    add_foreign_key :studentrequestmasters, :schedulemasters, on_update: :cascade, on_delete: :cascade
    add_foreign_key :studentrequestmasters, :students, on_update: :cascade, on_delete: :restrict
  end
end
