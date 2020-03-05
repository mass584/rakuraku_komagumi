class CreateCalculationRules < ActiveRecord::Migration[5.2]
  def change
    create_table :calculation_rules do |t|
      t.integer :schedulemaster_id, null: false
      t.string  :eval_target, null: false
      t.integer :single_cost
      t.integer :different_pair_cost
      t.string  :blank_class_cost
      t.integer :blank_class_max
      t.string  :total_class_cost
      t.integer :total_class_max
      t.string  :interval_cost
      t.timestamps
    end
    add_foreign_key :calculation_rules, :schedulemasters, on_update: :cascade, on_delete: :cascade
  end
end
