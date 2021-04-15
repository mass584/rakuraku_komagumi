class TermSerializer < ActiveModel::Serializer
  attributes :date_count, :period_count, :seat_count, :position_count, :begin_at, :end_at
  has_many :teacher_optimization_rules
  has_many :student_optimization_rules
  has_many :term_teachers
  has_many :timetables
  has_many :tutorial_pieces

  class TeacherOptimizationRuleSerializer < ActiveModel::Serializer
    attributes :id, :occupation_limit, :blank_limit
  end

  class StudentOptimizationRuleSerializer < ActiveModel::Serializer
    attributes :id, :school_grade, :occupation_limit, :blank_limit
  end

  class TermTeacherSerializer < ActiveModel::Serializer
    attributes :id, :vacancy_status
    attribute :term_teacher_name

    def term_teacher_name
      object.teacher.name
    end
  end

  class TimetableSerializer < ActiveModel::Serializer
    attributes :id, :date_index, :period_index, :term_group_id, :is_closed
    attribute :term_group_name
    attribute :term_group_teacher_id
    attribute :term_group_student_ids
    attribute :vacant_term_teacher_ids
    attribute :vacant_term_student_ids
    attribute :occupied_term_teacher_ids
    attribute :occupied_term_student_ids
    has_many :seats

    def term_group_name
      object.term_group && object.term_group.group.name
    end

    def term_group_teacher_id
      object.term_group && object.term_group.term_teacher_id
    end

    def term_group_student_ids
      object.term_group ? object.term_group.group_contracts.where(is_contracted: true).pluck(:term_student_id) : [] 
    end

    def vacant_term_teacher_ids
      object.teacher_vacancies.filter do |teacher_vacancy|
        teacher_vacancy.is_vacant
      end.pluck(:term_teacher_id)
    end

    def vacant_term_student_ids
      object.student_vacancies.filter do |student_vacancy|
        student_vacancy.is_vacant
      end.pluck(:term_student_id)
    end

    def occupied_term_teacher_ids
      object.seats.pluck(:term_teacher_id).filter do |id|
        id != nil
      end
    end

    def occupied_term_student_ids
      object.seats.map do |seat|
        seat.tutorial_pieces.map do |tutorial_piece|
          tutorial_piece.tutorial_contract.term_student_id
        end
      end.flatten.uniq
    end

    class SeatSerializer < ActiveModel::Serializer
      attributes :id, :seat_index, :term_teacher_id, :position_count
      attribute :tutorial_piece_ids

      def tutorial_piece_ids
        object.tutorial_pieces.pluck(:id)
      end
    end
  end

  class TutorialPieceSerializer < ActiveModel::Serializer
    attributes :id, :seat_id, :is_fixed
    attribute :term_student_id
    attribute :term_student_name
    attribute :term_student_school_grade
    attribute :term_student_school_grade_i18n
    attribute :term_tutorial_id
    attribute :term_tutorial_name
    attribute :term_teacher_id

    def term_student_id
      object.tutorial_contract.term_student_id
    end

    def term_student_name
      object.tutorial_contract.term_student.student.name
    end

    def term_student_school_grade
      object.tutorial_contract.term_student.school_grade
    end

    def term_student_school_grade_i18n
      object.tutorial_contract.term_student.school_grade_i18n
    end

    def term_tutorial_id
      object.tutorial_contract.term_tutorial_id
    end

    def term_tutorial_name
      object.tutorial_contract.term_tutorial.tutorial.name
    end

    def term_teacher_id
      object.tutorial_contract.term_teacher_id
    end
  end
end
