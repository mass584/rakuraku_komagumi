class CreateOptimizationLogs < ActiveRecord::Migration[6.1]
  def change
    create_table :optimization_logs do |t|
      t.integer :term_id, null: false
      t.integer :sequence_number, null: false
      t.integer :installation_progress, null: false
      t.integer :swapping_progress, null: false
      t.integer :deletion_progress, null: false
      t.integer :exit_status, null: false
      t.datetime :end_at
      t.timestamps
    end
    add_foreign_key :optimization_logs, :terms, on_update: :cascade, on_delete: :cascade
  end
end
