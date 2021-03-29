class CreateTeacherOptimizationRules < ActiveRecord::Migration[6.0]
  def change
    create_table :teacher_optimization_rules do |t|
      t.integer :term_id, null: false
      t.integer :single_cost, null: false
      t.integer :different_pair_cost, null: false
      t.integer :occupation_limit, null: false
      t.integer :occupation_costs, null: false, array: true
      t.integer :blank_limit, null: false
      t.integer :blank_costs, null: false, array: true
      t.timestamps
    end
    add_foreign_key :teacher_optimization_rules, :terms, on_update: :cascade, on_delete: :cascade
  end
end
