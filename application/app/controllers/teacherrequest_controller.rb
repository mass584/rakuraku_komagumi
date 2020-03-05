class TeacherrequestController < ApplicationController
  include RoomStore
  include SchedulemasterStore
  before_action :check_logined
  before_action :check_schedulemaster
  helper_method :room
  helper_method :schedulemaster

  def index
    @teacherrequestmaster = Teacherrequestmaster.get_teacherrequestmasters(schedulemaster)
    if params[:teacher_id].nil?
      gon.teachers = schedulemaster.teachers.map { |teacher| { id: teacher.id } }
      render('teacherrequest/index_teacher_list') && return
    else
      teacher_id = params[:teacher_id].to_i
      @teacher = Teacher.find(teacher_id)
      @teacherrequest = Teacherrequest.get_teacherrequests(teacher_id, schedulemaster)
      case @teacherrequestmaster[teacher_id].status
      when 0 then
        render('teacherrequest/index_status_not_ready') && return
      when 1 then
        render('teacherrequest/index_status_ready') && return
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
    Teacherrequest.create(
      schedulemaster_id: schedulemaster.id,
      teacher_id: params[:teacher_id],
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
        Teacherrequest.create(
          schedulemaster_id: schedulemaster.id,
          teacher_id: params[:teacher_id],
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
          Teacherrequest.create(
            schedulemaster_id: schedulemaster.id,
            teacher_id: params[:teacher_id],
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
      teacher_id: params[:teacher_id],
      timetable_id: timetable.id,
    ).count
    # TODO : This validation check had better add to model.
    if child_record_count.positive?
      render(json: { message: '既に授業が割り当てられているため削除できません。' }, status: :bad_request) && return
    end
    schedulemaster.teacherrequests.joins(:timetable).where(
      teacher_id: params[:teacher_id],
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
          teacher_id: params[:teacher_id],
          timetable_id: timetable.id,
        ).count
        # TODO : This validation check had better add to model.
        if child_record_count.zero?
          schedulemaster.teacherrequests.joins(:timetable).where(
            teacher_id: params[:teacher_id],
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
            teacher_id: params[:teacher_id],
            timetable_id: timetable.id,
          ).count
          # TODO : This validation check had better add to model.
          if child_record_count.zero?
            schedulemaster.teacherrequests.joins(:timetable).where(
              teacher_id: params[:teacher_id],
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
    teacherrequestmaster = Teacherrequestmaster.find(params[:id])
    respond_to do |_format|
      if teacherrequestmaster.update(status: params[:status])
        render(json: {}, status: :no_content) && return
      else
        render(json: {}, status: :bad_request) && return
      end
    end
  end

  def occupation_and_matching
    schedulemaster = Schedulemaster.find(session[:schedulemaster_id])
    teacher_id = params[:teacher_id]
    required_number = get_required_number(teacher_id, schedulemaster)
    occupation_rate = get_occupation_rate(teacher_id, schedulemaster)
    bad_matching_list = get_bad_matching_list(teacher_id, schedulemaster)
    render(json: {
      required: required_number,
      occupation: occupation_rate,
      matching: bad_matching_list,
    }, status: :ok) && return
  end

  private

  def get_required_number(teacher_id, schedulemaster)
    schedulemaster.classnumbers.joins(:subject).where(
      teacher_id: teacher_id,
    ).where.not(
      'subjects.classtype': '集団授業',
    ).sum(:number)
  end

  def get_occupation_rate(teacher_id, schedulemaster)
    required = schedulemaster.classnumbers.joins(:subject).where(
      teacher_id: teacher_id,
    ).where.not(
      'subjects.classtype': '集団授業',
    ).sum(:number)
    available = 2 * schedulemaster.teacherrequests.joins(:timetable).where(
      teacher_id: teacher_id,
      'timetables.status': 0,
    ).count
    available != 0 ? (required.to_f / available.to_f) : -1
  end

  def get_bad_matching_list(teacher_id, schedulemaster)
    bad_matching_list = []
    schedulemaster.studentrequestmasters.joins(:student).where(
      'status': 1,
    ).each do |stm|
      required = schedulemaster.classnumbers.where(
        student_id: stm.student.id,
        teacher_id: teacher_id,
      ).sum(:number)
      next if required.zero?

      max_per_day = get_max_per_day(schedulemaster)
      matched = 0
      schedulemaster.date_array.each do |scheduledate|
        matched_per_day = get_matched_per_day(teacher_id, stm.student.id, scheduledate, schedulemaster)
        addnum = matched_per_day <= max_per_day ? matched_per_day : max_per_day
        matched += addnum
      end
      next if (required.to_f / matched.to_f) < 0.7

      item = {
        'student_fullname' => stm.student.fullname,
        'required' => required,
        'matched' => matched,
      }
      bad_matching_list.push(item)
    end
    bad_matching_list
  end

  def get_max_per_day(schedulemaster)
    calculation_rule = CalculationRule.find_by(
      schedulemaster_id: schedulemaster.id,
      eval_target: 'teacher',
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
