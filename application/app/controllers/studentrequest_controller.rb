class StudentrequestController < ApplicationController
  include RoomStore
  include SchedulemasterStore
  before_action :check_logined
  before_action :check_schedulemaster
  helper_method :room
  helper_method :schedulemaster

  def index
    @studentrequestmaster = Studentrequestmaster.get_studentrequestmasters(schedulemaster)
    if params[:student_id].nil?
      gon.students = schedulemaster.students.map { |student| { id: student.id } }
      render('studentrequest/index_student_list') && return
    else
      student_id = params[:student_id].to_i
      @student = Student.find(student_id)
      @studentrequest = Studentrequest.get_studentrequests(student_id, schedulemaster)
      case @studentrequestmaster[student_id].status
      when 0 then
        render('studentrequest/index_status_not_ready') && return
      when 1 then
        render('studentrequest/index_status_ready') && return
      else
        raise 'UNEXPECTED_STATUS'
      end
    end
  end

  def create
    schedulemaster = Schedulemaster.find(session[:schedulemaster_id])
    timetable = schedulemaster.timetables.find_by(
      scheduledate: params[:scheduledate],
      classnumber: params[:classnumber],
    )
    Studentrequest.create(
      schedulemaster_id: schedulemaster.id,
      student_id: params[:student_id],
      timetable_id: timetable.id,
    )
    render(json: {}, status: :no_content) && return
  end

  def bulk_create
    schedulemaster = Schedulemaster.find(session[:schedulemaster_id])
    if params[:scheduledate]
      schedulemaster.class_array.each do |c|
        timetable = schedulemaster.timetables.find_by(
          scheduledate: params[:scheduledate],
          classnumber: c,
        )
        Studentrequest.create(
          schedulemaster_id: schedulemaster.id,
          student_id: params[:student_id],
          timetable_id: timetable.id,
        )
      end
    else
      schedulemaster.date_array.each do |d|
        schedulemaster.class_array.each do |c|
          timetable = schedulemaster.timetables.find_by(
            scheduledate: d,
            classnumber: c,
          )
          Studentrequest.create(
            schedulemaster_id: schedulemaster.id,
            student_id: params[:student_id],
            timetable_id: timetable.id,
          )
        end
      end
    end
    render(json: {}, status: :no_content) && return
  end

  def delete
    schedulemaster = Schedulemaster.find(session[:schedulemaster_id])
    timetable = schedulemaster.timetables.find_by(
      classnumber: params[:classnumber],
      scheduledate: params[:scheduledate],
    )
    child_record_count = schedulemaster.schedules.where(
      student_id: params[:student_id],
      timetable_id: timetable.id,
    ).count
    # TODO : This validation check had better add to model.
    if child_record_count.positive?
      render(json: { message: '既に授業が割り当てられているため削除できません。' }, status: :bad_request) && return
    end
    schedulemaster.studentrequests.joins(:timetable).where(
      student_id: params[:student_id],
      'timetables.scheduledate': params[:scheduledate],
      'timetables.classnumber': params[:classnumber],
    ).destroy_all
    render(json: {}, status: :no_content) && return
  end

  def bulk_delete
    schedulemaster = Schedulemaster.find(session[:schedulemaster_id])
    fail_list = []
    if params[:scheduledate]
      schedulemaster.class_array.each do |c|
        timetable = schedulemaster.timetables.find_by(
          scheduledate: params[:scheduledate],
          classnumber: c,
        )
        child_record_count = schedulemaster.schedules.where(
          student_id: params[:student_id],
          timetable_id: timetable.id,
        ).count
        # TODO : This validation check had better add to model.
        if child_record_count.zero?
          schedulemaster.studentrequests.joins(:timetable).where(
            student_id: params[:student_id],
            'timetables.scheduledate': params[:scheduledate],
            'timetables.classnumber': c,
          ).destroy_all
        else
          fail_list.push(
            scheduledate: params[:scheduledate],
            classnumber: c,
          )
        end
      end
    else
      schedulemaster.date_array.each do |d|
        schedulemaster.class_array.each do |c|
          timetable = schedulemaster.timetables.find_by(
            scheduledate: d,
            classnumber: c,
          )
          child_record_count = schedulemaster.schedules.where(
            student_id: params[:student_id],
            timetable_id: timetable.id,
          ).count
          # TODO : This validation check had better add to model.
          if child_record_count.zero?
            schedulemaster.studentrequests.joins(:timetable).where(
              student_id: params[:student_id],
              'timetables.scheduledate': d,
              'timetables.classnumber': c,
            ).destroy_all
          else
            fail_list.push(
              scheduledate: d,
              classnumber: c,
            )
          end
        end
      end
    end
    render(json: { fail_list: fail_list }, status: :ok) && return
  end

  def update_master
    studentrequestmaster = Studentrequestmaster.find(params[:id])
    respond_to do |_format|
      if studentrequestmaster.update(status: params[:status])
        render(json: {}, status: :no_content) && return
      else
        render(json: {}, status: :bad_request) && return
      end
    end
  end

  def occupation_and_matching
    schedulemaster = Schedulemaster.find(session[:schedulemaster_id])
    student_id = params[:student_id]
    required_number = get_required_number(student_id, schedulemaster)
    occupation_rate = get_occupation_rate(student_id, schedulemaster)
    bad_matching_list = get_bad_matching_list(student_id, schedulemaster)
    render(json: {
      student_id: student_id,
      required: required_number,
      occupation: occupation_rate,
      matching: bad_matching_list,
    }, status: :ok) && return
  end

  private

  def get_required_number(student_id, schedulemaster)
    schedulemaster.classnumbers.joins(:subject).where(
      student_id: student_id,
    ).where.not(
      'subjects.classtype': '集団授業',
    ).sum(:number)
  end

  def get_occupation_rate(student_id, schedulemaster)
    required = schedulemaster.classnumbers.joins(:subject).where(
      student_id: student_id,
    ).where.not(
      'subjects.classtype': '集団授業',
    ).sum(:number)
    available = schedulemaster.studentrequests.joins(:timetable).where(
      student_id: student_id,
      'timetables.status': 0,
    ).count
    available != 0 ? (required.to_f / available.to_f) : -1
  end

  def get_bad_matching_list(student_id, schedulemaster)
    bad_matching_list = []
    schedulemaster.teacherrequestmasters.joins(:teacher).where(
      'status': 1,
    ).each do |tem|
      required = schedulemaster.classnumbers.where(
        student_id: student_id,
        teacher_id: tem.teacher.id,
      ).sum(:number)
      next if required.zero?

      max_per_day = get_max_per_day(student_id, schedulemaster)
      matched = 0
      schedulemaster.date_array.each do |scheduledate|
        matched_per_day = get_matched_per_day(tem.teacher.id, student_id, scheduledate, schedulemaster)
        addnum = matched_per_day <= max_per_day ? matched_per_day : max_per_day
        matched += addnum
      end
      next if (required.to_f / matched.to_f) < 0.7

      item = {
        'teacher_fullname' => tem.teacher.fullname,
        'required' => required,
        'matched' => matched,
      }
      bad_matching_list.push(item)
    end
    bad_matching_list
  end

  def get_max_per_day(student_id, schedulemaster)
    case Student.find(student_id).grade_when(schedulemaster)
    when '小6', '中1', '中2'
      eval_target = 'student'
    when '中3'
      eval_target = 'student3g'
    end
    calculation_rule = CalculationRule.find_by(
      schedulemaster_id: schedulemaster.id,
      eval_target: eval_target,
    )
    calculation_rule.total_class_max
  end

  def get_matched_per_day(teacher_id, student_id, date, schedulemaster)
    matched_per_day = 0
    teacherrequests = schedulemaster.teacherrequests.joins(:timetable).where(
      teacher_id: teacher_id,
      'timetables.scheduledate': date,
    )
    studentrequests = schedulemaster.studentrequests.joins(:timetable).where(
      student_id: student_id,
      'timetables.scheduledate': date,
    )
    schedulemaster.class_array.each do |classnumber|
      next unless teacherrequests.exists?(
        'timetables.classnumber': classnumber,
      ) && studentrequests.exists?(
        'timetables.classnumber': classnumber,
      )

      matched_per_day += 1
    end
    matched_per_day
  end
end
