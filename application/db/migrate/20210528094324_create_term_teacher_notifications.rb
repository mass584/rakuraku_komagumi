class CreateTermTeacherNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :term_teacher_notifications do |t|
      t.integer :term_id, null: false
      t.integer :term_teacher_id, null: false
      t.timestamps
    end
    add_foreign_key :term_teacher_notifications, :term_teachers, on_update: :cascade, on_delete: :cascade
  end
end
