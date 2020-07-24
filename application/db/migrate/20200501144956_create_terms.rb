class CreateTerms < ActiveRecord::Migration[5.2]
  def change
    create_table :terms do |t|
      t.integer :room_id, null: false
      t.string :name, null: false
      t.integer :type, null: false
      t.integer :year, null: false
      t.date :begin_at, null: false
      t.date :end_at, null: false
      t.integer :max_period, null: false
      t.integer :max_seat, null: false
      t.integer :max_frame, null: false
      t.timestamps
    end
    add_foreign_key :terms, :rooms, on_update: :cascade, on_delete: :restrict
  end
end
