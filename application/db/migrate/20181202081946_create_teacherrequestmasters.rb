class CreateTeacherrequestmasters < ActiveRecord::Migration[5.2]
  def change
    create_table :teacherrequestmasters do |t|
      t.integer :schedulemaster_id, null: false
      t.integer :teacher_id, null: false
      t.integer :status, null: false
      t.timestamps
    end
    add_index :teacherrequestmasters, [:schedulemaster_id, :teacher_id], unique: true, name: 'index_teacherrequestmasters'
    add_foreign_key :teacherrequestmasters, :schedulemasters, on_update: :cascade, on_delete: :cascade
    add_foreign_key :teacherrequestmasters, :teachers, on_update: :cascade, on_delete: :restrict
  end
end
