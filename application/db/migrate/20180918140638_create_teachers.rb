class CreateTeachers < ActiveRecord::Migration[5.2]
  def change
    create_table :teachers do |t|
      t.string :name, null: false
      t.string :name_kana, null: false
      t.string :email
      t.string :tel
      t.string :zip
      t.string :address
      t.boolean :is_deleted, null: false
      t.integer :room_id, null: false
      t.timestamps
    end
    add_foreign_key :teachers, :rooms, on_update: :cascade, on_delete: :restrict
  end
end
