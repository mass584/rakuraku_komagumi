class TermSerializer < ActiveModel::Serializer
  attributes :id, :name, :year, :date_count, :period_count, :seat_count, :position_count
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
    attribute :vacant_term_teacher_ids
    attribute :vacant_term_student_ids
    attribute :occupied_term_teacher_ids
    attribute :occupied_term_student_ids

    belongs_to :term_group
    has_many :seats

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
      object.seats.pluck(:term_teacher_id).uniq.delete(nil).to_a
    end

    def occupied_term_student_ids
      object.seats.map do |seat|
        seat.tutorial_pieces.map do |tutorial_piece|
          tutorial_piece.tutorial_contract.term_student_id
        end
      end.flatten.uniq
    end

    class TermGroupSerializer < ActiveModel::Serializer
      attributes :id, :term_teacher_id
      attribute :term_group_name
      attribute :term_student_ids

      def term_group_name
        object.group.name
      end

      def term_student_ids
        object.group_contracts.pluck(:term_student_id)
      end
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
    attributes :id, :tutorial_contract_id, :seat_id, :is_fixed
    belongs_to :tutorial_contract

    class TutorialContractSerializer < ActiveModel::Serializer
      attributes :id, :term_tutorial_id, :term_student_id, :term_teacher_id, :piece_count
      attribute :term_tutorial_name
      attribute :term_student_name
      attribute :term_student_school_grade

      def term_tutorial_name
        object.term_tutorial.tutorial.name
      end

      def term_student_name
        object.term_student.student.name
      end

      def term_student_school_grade
        object.term_student.school_grade
      end
    end
  end
end
