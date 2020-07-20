class CreateSubjectTerms < ActiveRecord::Migration[5.2]
  def change
    create_table :subject_terms do |t|
      t.integer :subject_id, null: false
      t.integer :term_id, null: false
      t.timestamps
    end
    add_index :subject_terms, [:term_id, :subject_id], unique: true
    add_foreign_key :subject_terms, :terms, on_update: :cascade, on_delete: :cascade
    add_foreign_key :subject_terms, :subjects, on_update: :cascade, on_delete: :restrict
  end
end
