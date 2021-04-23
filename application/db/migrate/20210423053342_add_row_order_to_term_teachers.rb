class AddRowOrderToTermTeachers < ActiveRecord::Migration[6.1]
  def change
    add_column :term_teachers, :row_order, :integer
  end
end
