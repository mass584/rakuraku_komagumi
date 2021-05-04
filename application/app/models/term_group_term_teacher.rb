class TermGroupTermTeacher < ApplicationRecord
  belongs_to :term_group
  belongs_to :term_teacher
end
