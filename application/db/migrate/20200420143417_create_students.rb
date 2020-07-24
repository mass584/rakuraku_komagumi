class CreateStudents < ActiveRecord::Migration[5.2]
  def change
    create_table :students do |t|
      t.integer :room_id, null: false
      t.string :name, null: false
      t.string :name_kana, null: false
      t.integer :gender, null: false
      t.integer :school_year, null: false
      t.string :school_name, null: false
      t.string :email, null: false
      t.string :tel, null: false
      t.string :zip, null: false
      t.string :address, null: false
      t.boolean :is_deleted, default: false, null: false
      t.timestamps
    end
    add_foreign_key :students, :rooms, on_update: :cascade, on_delete: :restrict
  end
end
