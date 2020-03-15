class ChangeColumnsOnTimetablemaster < ActiveRecord::Migration[5.2]
  def change
    remove_column :timetablemasters, :begin_at, :time
    remove_column :timetablemasters, :end_at, :time
    add_column :timetablemasters, :begin_at, :string, null: false, after: :period
    add_column :timetablemasters, :end_at, :string, null: false, after: :begin_at
  end
end
