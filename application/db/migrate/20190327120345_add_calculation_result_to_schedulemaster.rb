class AddCalculationResultToSchedulemaster < ActiveRecord::Migration[5.2]
  def change
    change_table :schedulemasters, bulk: true do |t|
      t.text :calculation_result
      t.integer :calculation_progress
    end
  end
end
