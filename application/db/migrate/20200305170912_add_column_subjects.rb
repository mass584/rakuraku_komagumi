class AddColumnSubjects < ActiveRecord::Migration[5.2]
  def up
    add_column :subjects, :order, :integer, after: :name
    change_column :subjects, :order, :integer, null: false
  end

  def down
    remove_column :subjects, :order
  end
end
