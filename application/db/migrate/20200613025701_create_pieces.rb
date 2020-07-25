class CreatePieces < ActiveRecord::Migration[5.2]
  def change
    create_table :pieces do |t|
      t.integer :term_id, null: false
      t.integer :contract_id, null: false
      t.integer :seat_id
      t.boolean :is_fixed, default: false, null: false
      t.timestamps
    end
    add_foreign_key :pieces, :terms, on_update: :cascade, on_delete: :cascade
    add_foreign_key :pieces, :contracts, on_update: :cascade, on_delete: :cascade
  end
end
