class CreateBeginEndTimes < ActiveRecord::Migration[5.2]
  def change
    create_table :begin_end_times do |t|
      t.integer :term_id, null: false
      t.integer :period_index, null: false
      t.time :begin_at, null: false
      t.time :end_at, null: false
      t.timestamps
    end
    add_index :begin_end_times, [:term_id, :period_index], unique: true
    add_foreign_key :begin_end_times, :terms, on_update: :cascade, on_delete: :cascade
  end
end
