class ClassnumberController < ApplicationController
  before_action :check_login
  before_action :check_schedulemaster
  before_action :check_schedulemaster_batch_status

  ERROR_MSG_CHANGE_TANNIN = '予定が決定済の授業があるため、担任の先生を変更することが出来ません。変更したい場合は、この画面で該当する授業を削除し、再設定を行ってください。'.freeze
  ERROR_MSG_CHANGE_NUMBER = '授業回数を、予定決定済の授業数よりも少なくすることは出来ません。少なくしたい場合は、全体予定編集画面で決定済の授業を未決定に戻してください。'.freeze
  ERROR_MSG_BLANK_CLASS_VIOLATION = '空きコマ違反が発生してしまうため、変更できませんでした。'.freeze
  ERROR_MSG_TOTAL_CLASS_VIOLATION = 'コマ数上限の違反が発生してしまうため、変更できませんでした。'.freeze

  def classnumbers
    return @classnumbers if defined? @classnumbers

    @classnumbers = Classnumber.get_classnumbers(@schedulemaster)
  end
  helper_method :classnumbers

  def index
  end

  def update
    respond_to do |format|
      format.json do
        classnumber = Classnumber.find(params[:id])
        schedules = @schedulemaster.schedules.where(
          student_id: classnumber.student_id,
          subject_id: classnumber.subject_id,
        )
        old_teacher_id = classnumber.teacher_id
        old_number = classnumber.number
        new_teacher_id = params[:teacher_id].to_i
        new_number = params[:number].to_i
        # validate
        if !can_change_tannin(new_teacher_id, old_teacher_id, schedules)
          render(json: { message: ERROR_MSG_CHANGE_TANNIN }, status: :bad_request) && return
        end
        if !can_change_schedule_number(new_number, old_number, schedules)
          render(json: { message: ERROR_MSG_CHANGE_NUMBER }, status: :bad_request) && return
        end
        if new_number > old_number
          (new_number - old_number).times do
            Schedule.create!(
              schedulemaster_id: classnumber.schedulemaster_id,
              student_id: classnumber.student_id,
              teacher_id: classnumber.teacher_id,
              subject_id: classnumber.subject_id,
              timetable_id: 0,
              status: 0,
            )
          end
        elsif new_number < old_number
          (old_number - new_number).times do
            schedules.find_by(timetable_id: 0).destroy
          end
        end
        schedules.update_all(teacher_id: new_teacher_id)
        classnumber.update(teacher_id: new_teacher_id, number: new_number)
        render(json: {}, status: :no_content) && return
      end
    end
  end

  def destroy
    respond_to do |format|
      format.json do
        classnumber = Classnumber.find(params[:id])
        # validate
        if !student_blank_class_check_for_delete_individual(classnumber) ||
           !teacher_blank_class_check_for_delete(classnumber)
          render(json: { message: ERROR_MSG_BLANK_CLASS_VIOLATION }, status: :bad_request) && return
        end
        @schedulemaster.schedules.where(
          student_id: classnumber.student_id,
          subject_id: classnumber.subject_id,
        ).destroy_all
        classnumber.update(
          teacher_id: 0,
          number: 0,
        )
        render(json: {}, status: :no_content) && return
      end
    end
  end

  private

  def can_change_tannin(new_teacher_id, old_teacher_id, schedules)
    if new_teacher_id == old_teacher_id
      true
    else
      schedules.where.not(timetable_id: 0).count.zero?
    end
  end

  def can_change_schedule_number(new_number, old_number, schedules)
    deletable_schedule_count = schedules.where(timetable_id: 0).count
    case
    when new_number == old_number
      return true
    when new_number > old_number
      return true
    when new_number < old_number && (old_number - new_number) <= deletable_schedule_count
      return true
    else
      return false
    end
  end

  def student_total_class_check_for_create(classnumber)
    student_id = classnumber.student_id
    total_class_max = if Student.find(student_id).grade == '中3'
                        @schedulemaster.calculation_rules.find_by(eval_target: 'student3g').total_class_max
                      else
                        @schedulemaster.calculation_rules.find_by(eval_target: 'student').total_class_max
                      end
    @schedulemaster.date_array.each do |d|
      total_count = 0
      @schedulemaster.class_array.each do |c|
        timetable = @schedulemaster.timetables.find_by(
          scheduledate: d,
          classnumber: c,
        )
        case timetable.status
        when -1
          total_count += 0
        when 0
          total_count += 1 if @schedulemaster.schedules.where(
            student_id: student_id,
            timetable_id: timetable.id,
          ).exists?
        else
          total_count += 1 if @schedulemaster.classnumbers.where(
            subject_id: timetable.status,
            student_id: student_id,
            number: 1,
          ).exists? || classnumber.subject_id == timetable.status
        end
      end
      return false if total_count > total_class_max
    end
    true
  end

  def student_blank_class_check_for_create(classnumber)
    student_id = classnumber.student_id
    blank_class_max = if Student.find(student_id).grade == '中3'
                        @schedulemaster.calculation_rules.find_by(eval_target: 'student3g').blank_class_max
                      else
                        @schedulemaster.calculation_rules.find_by(eval_target: 'student').blank_class_max
                      end
    @schedulemaster.date_array.each do |d|
      blank_count = 0
      blank_count_tmp = 0
      class_begin = false
      @schedulemaster.class_array.each do |c|
        timetable = @schedulemaster.timetables.find_by(
          scheduledate: d,
          classnumber: c,
        )
        case timetable.status
        when -1
          exist = false
        when 0
          exist = @schedulemaster.schedules.where(
            student_id: student_id,
            timetable_id: timetable.id,
          ).exists?
          logger.warn("student_blank_class_check_for_create:exist(0):#{exist}")
        else
          exist = @schedulemaster.classnumbers.where(
            subject_id: timetable.status,
            student_id: student_id,
            number: 1,
          ).exists? || classnumber.subject_id == timetable.status
          logger.warn("student_blank_class_check_for_create:exist(group):#{exist}")
          logger.warn("student_blank_class_check_for_create:timetable.status:#{timetable.status}")
          logger.warn("student_blank_class_check_for_create:classnumber.subject_id:#{classnumber.subject_id}")
        end
        if exist
          blank_count += blank_count_tmp if class_begin
          blank_count_tmp = 0
          class_begin = true
        else
          blank_count_tmp += 1
        end
      end
      logger.warn("student_blank_class_check_for_create:blank_count:#{blank_count}")
      logger.warn("student_blank_class_check_for_create:blank_class_max:#{blank_class_max}")
      return false if blank_count > blank_class_max
    end
    true
  end

  def student_blank_class_check_for_delete_group(classnumber)
    student_id = classnumber.student_id
    blank_class_max = if Student.find(student_id).grade == '中3'
                        @schedulemaster.calculation_rules.find_by(eval_target: 'student3g').blank_class_max
                      else
                        @schedulemaster.calculation_rules.find_by(eval_target: 'student').blank_class_max
                      end
    @schedulemaster.date_array.each do |d|
      blank_count = 0
      blank_count_tmp = 0
      class_begin = false
      @schedulemaster.class_array.each do |c|
        timetable = @schedulemaster.timetables.find_by(
          scheduledate: d,
          classnumber: c,
        )
        exist = case timetable.status
                when -1
                  false
                when 0
                  @schedulemaster.schedules.where(
                    student_id: student_id,
                    timetable_id: timetable.id,
                  ).exists?
                else
                  @schedulemaster.classnumbers.where(
                    subject_id: timetable.status,
                    student_id: student_id,
                    number: 1,
                  ).where.not(
                    id: classnumber.id,
                  ).exists?
                end
        if exist
          blank_count += blank_count_tmp if class_begin
          blank_count_tmp = 0
          class_begin = true
        else
          blank_count_tmp += 1
        end
      end
      return false if blank_count > blank_class_max
    end
    true
  end

  def student_blank_class_check_for_delete_individual(classnumber)
    student_id = classnumber.student_id
    subject_id = classnumber.subject_id
    blank_class_max = if Student.find(student_id).grade == '中3'
                        @schedulemaster.calculation_rules.find_by(eval_target: 'student3g').blank_class_max
                      else
                        @schedulemaster.calculation_rules.find_by(eval_target: 'student').blank_class_max
                      end
    @schedulemaster.date_array.each do |d|
      blank_count = 0
      blank_count_tmp = 0
      class_begin = false
      @schedulemaster.class_array.each do |c|
        timetable = schedulemaster.timetables.find_by(
          scheduledate: d,
          classnumber: c,
        )
        exist = case timetable.status
                when -1
                  false
                when 0
                  @schedulemaster.schedules.where(
                    student_id: student_id,
                    timetable_id: timetable.id,
                  ).where.not(
                    subject_id: subject_id,
                  ).exists?
                else
                  @schedulemaster.classnumbers.where(
                    subject_id: timetable.status,
                    student_id: student_id,
                    number: 1,
                  ).exists?
                end
        if exist
          blank_count += blank_count_tmp if class_begin
          blank_count_tmp = 0
          class_begin = true
        else
          blank_count_tmp += 1
        end
      end
      return false if blank_count > blank_class_max
    end
    true
  end

  def teacher_blank_class_check_for_delete(classnumber)
    teacher_id = classnumber.teacher_id
    student_id = classnumber.student_id
    subject_id = classnumber.subject_id
    blank_class_max = @schedulemaster.calculation_rules.find_by(eval_target: 'teacher').blank_class_max
    @schedulemaster.date_array.each do |d|
      blank_count = 0
      blank_count_tmp = 0
      class_begin = false
      @schedulemaster.class_array.each do |c|
        timetable = @schedulemaster.timetables.find_by(
          scheduledate: d,
          classnumber: c,
        )
        exist = case timetable.status
                when -1
                  false
                when 0
                  @schedulemaster.schedules.where(
                    teacher_id: teacher_id,
                    timetable_id: timetable.id,
                  ).where.not(
                    student_id: student_id,
                    subject_id: subject_id,
                  ).exists?
                else
                  @schedulemaster.subject_schedulemaster_mappings.where(
                    subject_id: timetable.status,
                    teacher_id: teacher_id,
                  ).exists?
                end
        if exist
          blank_count += blank_count_tmp if class_begin
          blank_count_tmp = 0
          class_begin = true
        else
          blank_count_tmp += 1
        end
      end
      return false if blank_count > blank_class_max
    end
    true
  end
end
