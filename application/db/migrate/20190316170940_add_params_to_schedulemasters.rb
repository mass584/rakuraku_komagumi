class AddParamsToSchedulemasters < ActiveRecord::Migration[5.2]
  def change
    change_table :schedulemasters, bulk: true do |t|
      t.integer :max_count, default: 50
      t.integer :max_time_sec, default: 0
    end
  end
end
