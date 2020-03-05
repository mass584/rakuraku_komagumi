class CreateTeachabilities < ActiveRecord::Migration[5.2]
  def change
    create_table :teachabilities do |t|
      t.integer :subject_id, null: false
      t.integer :teacher_id, null: false
      t.timestamps
    end
    add_foreign_key :teachabilities, :subjects, on_update: :cascade, on_delete: :restrict
    add_foreign_key :teachabilities, :teachers, on_update: :cascade, on_delete: :cascade
    add_index :teachabilities, [:subject_id, :teacher_id], unique: true
  end
end
