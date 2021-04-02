class CreateStudentOptimizationRules < ActiveRecord::Migration[6.0]
  def change
    create_table :student_optimization_rules do |t|
      t.integer :term_id, null: false
      t.integer :school_grade, null: false
      t.integer :occupation_limit, null: false
      t.integer :occupation_costs, null: false, array: true
      t.integer :blank_limit, null: false
      t.integer :blank_costs, null: false, array: true
      t.integer :interval_cutoff, null: false
      t.integer :interval_costs, null: false, array: true
      t.timestamps
    end
    add_foreign_key :student_optimization_rules, :terms, on_update: :cascade, on_delete: :cascade
  end
end
