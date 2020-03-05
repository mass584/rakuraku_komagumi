class CreateStudentrequestmasters < ActiveRecord::Migration[5.2]
  def change
    create_table :studentrequestmasters do |t|
      t.integer :schedulemaster_id, null: false
      t.integer :student_id, null: false
      t.integer :status, null: false
      t.timestamps
    end
    add_index :studentrequestmasters, [:schedulemaster_id, :student_id], unique: true, name: 'index_studentrequestmasters'
  end
end
