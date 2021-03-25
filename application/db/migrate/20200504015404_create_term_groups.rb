class CreateTermGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :term_groups do |t|
      t.integer :term_id, null: false
      t.integer :group_id, null: false
      t.integer :term_teacher_id
      t.timestamps
    end
    add_index :term_groups, [:term_id, :group_id], unique: true
    add_foreign_key :term_groups, :terms, on_update: :cascade, on_delete: :cascade
    add_foreign_key :term_groups, :groups, on_update: :cascade, on_delete: :restrict
  end
end
