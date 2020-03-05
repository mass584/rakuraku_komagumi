class AddColumnSchedulemasters < ActiveRecord::Migration[5.2]
  def up
    add_column :schedulemasters, :year, :integer, after: :type
    change_column :schedulemasters, :year, :integer, null: false
  end

  def down
    remove_column :schedulemasters, :year
  end
end
