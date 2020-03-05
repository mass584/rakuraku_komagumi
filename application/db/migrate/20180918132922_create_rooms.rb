class CreateRooms < ActiveRecord::Migration[5.2]
  def change
    create_table :owners do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.timestamps
    end
    add_index :owners, :email, unique: true
  end
end
