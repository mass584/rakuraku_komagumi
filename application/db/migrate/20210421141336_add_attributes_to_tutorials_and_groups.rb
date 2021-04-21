class AddAttributesToTutorialsAndGroups < ActiveRecord::Migration[6.1]
  def change
    add_column :tutorials, :short_name, :string, null: false, default: ''
    add_column :groups, :short_name, :string, null: false, default: ''
    change_column_default :tutorials, :short_name, from: '', to: nil
    change_column_default :groups, :short_name, from: '', to: nil
  end
end
