class CreateTermTutorials < ActiveRecord::Migration[5.2]
  def change
    create_table :term_tutorials do |t|
      t.integer :term_id, null: false
      t.integer :tutorial_id, null: false
      t.timestamps
    end
    add_index :term_tutorials, [:term_id, :tutorial_id], unique: true
    add_foreign_key :term_tutorials, :terms, on_update: :cascade, on_delete: :cascade
    add_foreign_key :term_tutorials, :tutorials, on_update: :cascade, on_delete: :restrict
  end
end
