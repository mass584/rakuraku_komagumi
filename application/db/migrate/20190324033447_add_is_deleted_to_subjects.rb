class AddIsDeletedToSubjects < ActiveRecord::Migration[5.2]
  def change
    add_column :subjects, :is_deleted, :boolean, default: false, null: false
  end
end
