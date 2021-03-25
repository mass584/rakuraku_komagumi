class CreateTeachers < ActiveRecord::Migration[5.2]
  def change
    create_table :teachers do |t|
      t.integer :room_id, null: false
      t.string :name, null: false
      t.string :email, null: false
      t.boolean :is_deleted, default: false, null: false
      t.timestamps
    end
    add_foreign_key :teachers, :rooms, on_update: :cascade, on_delete: :restrict
  end
end
