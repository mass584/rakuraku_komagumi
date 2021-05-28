class CreateTermStudentNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :term_student_notifications do |t|
      t.integer :term_id, null: false
      t.integer :term_student_id, null: false
      t.timestamps
    end
    add_foreign_key :term_student_notifications, :term_students, on_update: :cascade, on_delete: :cascade
  end
end
