class CreateTermGroupTermTeachers < ActiveRecord::Migration[6.1]
  def change
    create_table :term_group_term_teachers do |t|
      t.references :term_group, null: false, foreign_key: true
      t.references :term_teacher, null: false, foreign_key: true

      t.timestamps
    end
  end
end
