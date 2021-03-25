class CreateTutorialPieces < ActiveRecord::Migration[5.2]
  def change
    create_table :tutorial_pieces do |t|
      t.integer :term_id, null: false
      t.integer :tutorial_contract_id, null: false
      t.integer :seat_id
      t.boolean :is_fixed, default: false, null: false
      t.timestamps
    end
    add_index :tutorial_pieces, :term_id
    add_foreign_key :tutorial_pieces, :terms, on_update: :cascade, on_delete: :cascade
    add_foreign_key :tutorial_pieces, :tutorial_contracts, on_update: :cascade, on_delete: :cascade
  end
end
