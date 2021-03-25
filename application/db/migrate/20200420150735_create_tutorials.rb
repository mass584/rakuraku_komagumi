class CreateTutorials < ActiveRecord::Migration[5.2]
  def change
    create_table :tutorials do |t|
      t.integer :room_id, null: false
      t.string :name, null: false
      t.integer :order, null: false
      t.boolean :is_deleted, default: false, null: false
      t.timestamps
    end
    add_foreign_key :tutorials, :rooms, on_update: :cascade, on_delete: :restrict
  end
end
