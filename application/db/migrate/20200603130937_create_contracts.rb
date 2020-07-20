class CreateContracts < ActiveRecord::Migration[5.2]
  def change
    create_table :contracts do |t|
      t.integer :term_id, null: false
      t.integer :student_term_id, null: false
      t.integer :subject_term_id, null: false
      t.integer :teacher_term_id
      t.integer :count, null: false
      t.timestamps
    end
    add_index :contracts, [:student_term_id, :subject_term_id], unique: true
    add_foreign_key :contracts, :terms, on_update: :cascade, on_delete: :cascade
    add_foreign_key :contracts, :student_terms, on_update: :cascade, on_delete: :cascade
    add_foreign_key :contracts, :subject_terms, on_update: :cascade, on_delete: :cascade
  end
end
