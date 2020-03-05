class CreateSubjects < ActiveRecord::Migration[5.2]
  def change
    create_table :subjects do |t|
      t.string :name, null: false
      t.string :classtype, null: false
      t.integer :row_order
      t.integer :room_id, null: false
      t.timestamps
    end
    add_index :subjects, [:name, :room_id], unique: true
  end
end
