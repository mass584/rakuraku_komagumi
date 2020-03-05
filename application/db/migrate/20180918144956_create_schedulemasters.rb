class CreateSchedulemasters < ActiveRecord::Migration[5.2]
  def change
    create_table :schedulemasters do |t|
      t.string :name, null: false
      t.integer :type, null: false
      t.date :begin_at, null: false
      t.date :end_at, null: false
      t.integer :max_period, null: false
      t.integer :max_seat, null: false
      t.integer :batch_status, null: false
      t.datetime :batch_begin_at
      t.datetime :batch_end_at
      t.text :batch_result
      t.integer :batch_progress
      t.integer :room_id, null: false
      t.timestamps
    end
    add_foreign_key :schedulemasters, :rooms, on_update: :cascade, on_delete: :restrict
  end
end
