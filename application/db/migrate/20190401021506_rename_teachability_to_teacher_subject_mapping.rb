class RenameTeachabilityToTeacherSubjectMapping < ActiveRecord::Migration[5.2]
  def change
    rename_table :teachabilities, :teacher_subject_mappings
  end
end
