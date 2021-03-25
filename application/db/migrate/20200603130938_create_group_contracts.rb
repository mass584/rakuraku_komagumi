class CreateGroupContracts < ActiveRecord::Migration[5.2]
  def change
    create_table :group_contracts do |t|
      t.integer :term_id, null: false
      t.integer :term_group_id, null: false
      t.integer :term_student_id, null: false
      t.boolean :is_contracted, default: false, null: false
      t.timestamps
    end
    add_index :group_contracts, [:term_id, :term_group_id, :term_student_id], unique: true, name: :group_contracts_main_index
    add_foreign_key :group_contracts, :terms, on_update: :cascade, on_delete: :cascade
    add_foreign_key :group_contracts, :term_groups, on_update: :cascade, on_delete: :cascade
    add_foreign_key :group_contracts, :term_students, on_update: :cascade, on_delete: :cascade
  end
end
