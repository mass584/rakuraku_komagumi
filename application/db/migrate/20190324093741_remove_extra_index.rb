class RemoveExtraIndex < ActiveRecord::Migration[5.2]
  def change
    change_table :teachers do |t|
      t.remove_index name: 'index_teachers_on_lastname_and_firstname_and_room_id'
    end
    change_table :students do |t|
      t.remove_index name: 'index_students_on_lastname_and_firstname_and_grade_and_room_id'
    end
    change_table :subjects do |t|
      t.remove_index name: 'index_subjects_on_name_and_room_id'
    end
  end
end
