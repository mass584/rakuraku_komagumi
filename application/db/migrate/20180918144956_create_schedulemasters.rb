class CreateSchedulemasters < ActiveRecord::Migration[5.2]
  def change
    create_table :schedulemasters do |t|
      t.string :name, null: false
      t.string :type, null: false
      t.date :begindate, null: false
      t.date :enddate, null: false
      t.integer :totalclassnumber, null: false
      t.integer :seatnumber, null: false
      t.integer :calculation_status, null: false
      t.string :calculation_name
      t.datetime :calculation_begin
      t.datetime :calculation_end
      t.integer :room_id, null: false
      t.timestamps
    end
    add_foreign_key :schedulemasters, :rooms, on_update: :cascade, on_delete: :restrict
  end
end
