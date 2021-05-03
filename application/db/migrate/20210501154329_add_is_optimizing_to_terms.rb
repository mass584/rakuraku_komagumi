class AddIsOptimizingToTerms < ActiveRecord::Migration[6.1]
  def change
    add_column :terms, :is_optimizing, :boolean, null: false, default: false
  end
end
