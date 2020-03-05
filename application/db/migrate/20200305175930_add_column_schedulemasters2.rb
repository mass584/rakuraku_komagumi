class AddColumnSchedulemasters2 < ActiveRecord::Migration[5.2]
  def up
    add_column :schedulemasters, :class_per_teacher, :integer, after: :max_seat
    change_column :schedulemasters, :class_per_teacher, :integer, null: false
  end

  def down
    remove_column :schedulemasters, :class_per_teacher
  end
end
