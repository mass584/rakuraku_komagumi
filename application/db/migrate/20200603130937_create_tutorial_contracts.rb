class CreateTutorialContracts < ActiveRecord::Migration[5.2]
  def change
    create_table :tutorial_contracts do |t|
      t.integer :term_id, null: false
      t.integer :term_tutorial_id, null: false
      t.integer :term_student_id, null: false
      t.integer :term_teacher_id
      t.integer :piece_count, null: false
      t.timestamps
    end
    add_index :tutorial_contracts, [:term_id, :term_tutorial_id, :term_student_id], unique: true, name: :tutorial_contracts_main_index
    add_foreign_key :tutorial_contracts, :terms, on_update: :cascade, on_delete: :cascade
    add_foreign_key :tutorial_contracts, :term_tutorials, on_update: :cascade, on_delete: :cascade
    add_foreign_key :tutorial_contracts, :term_students, on_update: :cascade, on_delete: :cascade
  end
end
