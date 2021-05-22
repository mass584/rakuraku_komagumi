class OptimizationTermSerializer < ActiveModel::Serializer
  attribute :term
  has_many :timetables
  attribute :teacher_group_timetables
  attribute :student_group_timetables
  has_many :seats
  has_many :teacher_optimization_rules
  has_many :student_optimization_rules
  has_many :term_teachers
  has_many :term_students
  has_many :term_tutorials
  has_many :term_groups
  attribute :student_vacancies
  attribute :teacher_vacancies
  has_many :tutorial_contracts
  has_many :tutorial_pieces

  def term
    {
      term_type: object.term_type,
      date_count: object.date_count,
      period_count: object.period_count,
      seat_count: object.seat_count,
      begin_at: object.begin_at,
      end_at: object.end_at,
    }
  end

  class TimetableSerializer < ActiveModel::Serializer
    attributes :date_index, :period_index, :term_group_id, :is_closed
  end

  class SeatSerializer < ActiveModel::Serializer
    attributes :id, :date_index, :period_index, :seat_index, :term_teacher_id

    def date_index
      object.timetable.date_index
    end

    def period_index
      object.timetable.period_index
    end
  end

  class TeacherOptimizationRuleSerializer < ActiveModel::Serializer
    attributes :single_cost, :different_pair_cost, :occupation_limit, :occupation_costs, :blank_limit, :blank_costs
  end

  class StudentOptimizationRuleSerializer < ActiveModel::Serializer
    attributes :school_grade, :occupation_limit, :occupation_costs, :blank_limit, :blank_costs, :interval_cutoff, :interval_costs
  end

  class TermTeacherSerializer < ActiveModel::Serializer
    attributes :id, :vacancy_status
    attribute :name

    def name
      object.teacher.name
    end
  end

  class TermStudentSerializer < ActiveModel::Serializer
    attributes :id, :vacancy_status
    attribute :name
    attribute :school_grade

    def name
      object.student.name
    end

    def school_grade
      object.student.school_grade
    end
  end

  class TermTutorialSerializer < ActiveModel::Serializer
    attributes :id
    attribute :name

    def name
      object.tutorial.name
    end
  end

  class TermGroupSerializer < ActiveModel::Serializer
    attributes :id
    attribute :name

    def name
      object.group.name
    end
  end

  def student_vacancies
    object.timetables.joins(:student_vacancies).select(
      'timetables.date_index', 'timetables.period_index',
      'student_vacancies.term_student_id', 'student_vacancies.is_vacant',
    ).map do |timetable|
      {
        date_index: timetable.date_index,
        period_index: timetable.period_index,
        term_student_id: timetable.term_student_id,
        is_vacant: timetable.is_vacant,
      }
    end
  end

  def teacher_vacancies
    object.timetables.joins(:teacher_vacancies).select(
      'timetables.date_index', 'timetables.period_index',
      'teacher_vacancies.term_teacher_id', 'teacher_vacancies.is_vacant',
    ).map do |timetable|
      {
        date_index: timetable.date_index,
        period_index: timetable.period_index,
        term_teacher_id: timetable.term_teacher_id,
        is_vacant: timetable.is_vacant,
      }
    end
  end

  class TutorialPieceSerializer < ActiveModel::Serializer
    attributes :id, :seat_id, :is_fixed
    attribute :date_index
    attribute :period_index
    attribute :term_student_id
    attribute :term_teacher_id
    attribute :term_tutorial_id

    def date_index
      object.seat&.timetable&.date_index
    end

    def period_index
      object.seat&.timetable&.period_index
    end

    def term_student_id
      object.tutorial_contract.term_student_id
    end

    def term_tutorial_id
      object.tutorial_contract.term_tutorial_id
    end

    def term_teacher_id
      object.tutorial_contract.term_teacher_id
    end
  end

  class TutorialContractSerializer < ActiveModel::Serializer
    attributes :term_teacher_id, :term_student_id, :term_tutorial_id, :piece_count
  end

  def teacher_group_timetables
    object.timetables.joins(
      term_group: :term_group_term_teachers,
    ).select('timetables.*', 'term_group_term_teachers.term_teacher_id').map do |timetable|
      {
        date_index: timetable.date_index,
        period_index: timetable.period_index,
        term_group_id: timetable.term_group_id,
        term_teacher_id: timetable.term_teacher_id,
      }
    end
  end

  def student_group_timetables
    object.timetables.joins(
      term_group: :group_contracts,
    ).where('group_contracts.is_contracted': true).select(
      'timetables.*', 'group_contracts.term_student_id'
    ).map do |timetable|
      {
        date_index: timetable.date_index,
        period_index: timetable.period_index,
        term_group_id: timetable.term_group_id,
        term_student_id: timetable.term_student_id,
      }
    end
  end
end
