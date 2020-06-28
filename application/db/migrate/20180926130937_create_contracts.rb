class CreateContracts < ActiveRecord::Migration[5.2]
  def change
    create_table :contracts do |t|
      t.integer :term_id, null: false
      t.integer :student_id, null: false
      t.integer :teacher_id
      t.integer :subject_id, null: false
      t.integer :count, null: false
      t.timestamps
    end
    add_foreign_key :contracts, :terms, on_update: :cascade, on_delete: :cascade
    add_foreign_key :contracts, :students, on_update: :cascade, on_delete: :restrict
    add_foreign_key :contracts, :subjects, on_update: :cascade, on_delete: :restrict
    add_index :contracts, [:term_id, :student_id, :subject_id], unique: true
  end
end
