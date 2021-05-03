class AddExitMessageToOptimizationLogs < ActiveRecord::Migration[6.1]
  def change
    add_column :optimization_logs, :exit_message, :string
  end
end
