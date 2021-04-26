from datetime import timedelta
import datetime
import psycopg2
import psycopg2.extras
import numpy as np
import logging

logger = logging.getLogger('Database')

class Database():
    def __init__(self, host, port, dbname, username, password):
        self.host = host
        self.port = port
        self.dbname = dbname
        self.username = username
        self.password = password
        self.__fetch_all()

    def write_progress(self, progress):
        self.__connect()
        cur = self.conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        cur.execute(f"update schedulemasters set calculation_progress = {progress} where id = {self.id}")
        cur.close()
        self.__commit()
        self.__close()

    def write_schedules(self, schedule):
        self.__connect()
        index = np.where(schedule != 0)
        cur = self.conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        sql_update = f"update schedules set timetable_id = 0 "
        sql_where = f"where schedulemaster_id = {self.id} and status = 0 "
        cur.execute(sql_update + sql_where)
        cur.close()
        for i in range(index[0].size):
            teacher_id = self.teachers[index[1][i]]['id']
            student_id = self.students[index[0][i]]['id']
            personal_subject_id = self.personal_subjects[index[2][i]]['id']
            timetable_id = self.timetable_id[index[3][i]][index[4][i]]
            cur = self.conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
            sql_select = f"select count(*) from schedules "
            sql_where1 = f"where schedulemaster_id = {self.id} and status = 1 "
            sql_where2 = f"and teacher_id = {teacher_id} and student_id = {student_id} "
            sql_where3 = f"and subject_id = {personal_subject_id} and timetable_id = {timetable_id} "
            cur.execute(sql_select + sql_where1 + sql_where2 + sql_where3)
            select = cur.fetchone()
            cur.close()
            if select['count'] > 0: continue
            cur = self.conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
            sql_update = f"update schedules set timetable_id = {timetable_id}, status = 1 "
            sql_where1 = f"where id in (select id from schedules where "
            sql_where2 = f"schedulemaster_id = {self.id} and status = 0 "
            sql_where3 = f"and teacher_id = {teacher_id} and student_id = {student_id} "
            sql_where4 = f"and subject_id = {personal_subject_id} and timetable_id = 0 "
            sql_limit = f"limit 1)"
            cur.execute(sql_update + sql_where1 + sql_where2 + sql_where3 + sql_where4 + sql_limit)
            update_count = cur.rowcount
            cur.close()
            if update_count == 0: logger.error("rewritable schedule recored is lacked.")
        self.__commit()
        self.__close()

    def write_result(self, message):
        self.__connect()
        cur = self.conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        cur.execute(f"update schedulemasters set calculation_result = '{message}' where id = {self.id}")
        cur.close()
        self.__commit()
        self.__close()

    def __connect(self):
        self.conn = psycopg2.connect(
                host = self.host,
                port = self.port,
                dbname = self.dbname,
                user = self.username,
                password = self.password)

    def __commit(self):
        self.conn.commit()

    def __close(self):
        self.conn.close()

    def __fetch_all(self):
        self.__connect()
        self.__schedulemaster()
        self.__cost_for_teacher()
        self.__cost_for_student()
        self.__cost_for_student3g()
        self.__teachers()
        self.__students()
        self.__personal_subject()
        self.__group_subject()
        self.__student_group()
        self.__teacher_group()
        self.__studentrequestmaster()
        self.__teacherrequestmaster()
        self.__studentrequest()
        self.__teacherrequest()
        self.__schedule()
        self.__classnumber()
        self.__timetable()
        self.__student_group_reshaped()
        self.__teacher_group_reshaped()
        self.__commit()
        self.__close()

    def __schedulemaster(self):
        cur = self.conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        sql_select = "select seatnumber, totalclassnumber, schedule_type, begindate, enddate, max_count, max_time_sec "
        sql_from = "from schedulemasters "
        sql_where = f"where id = {self.id}"
        cur.execute(sql_select + sql_from + sql_where)
        row = cur.fetchone()
        self.max_count = row["max_count"] if row["max_count"] is not None else 50
        self.max_time_sec = row["max_time_sec"] if row["max_time_sec"] is not None else 0
        self.seatnumber = row["seatnumber"]
        self.class_count = row["totalclassnumber"]
        self.classes = range(1, row["totalclassnumber"] + 1, 1)
        if row["schedule_type"] == "講習時期":
            self.day_count = (row["enddate"] - row["begindate"]).days + 1
            self.days = [
                    row["begindate"] + timedelta(days=x) for x in range(self.day_count)
                    ]
        elif row["schedule_type"] == "通常時期":
            self.day_count = 7
            self.days = [
                    datetime.date(2001, 1, 1),
                    datetime.date(2001, 1, 2),
                    datetime.date(2001, 1, 3),
                    datetime.date(2001, 1, 4),
                    datetime.date(2001, 1, 5),
                    datetime.date(2001, 1, 6),
                    datetime.date(2001, 1, 7)
                    ]
        cur.close()
        return

    def __cost_for_teacher(self):
        cur = self.conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        sql_select = "select blank_class_cost, blank_class_max, total_class_cost, total_class_max, different_pair_cost, single_cost "
        sql_from = "from calculation_rules "
        sql_where = f"where schedulemaster_id = {self.id} and eval_target = 'teacher'"
        cur.execute(sql_select + sql_from + sql_where)
        row = cur.fetchone()
        self.single_cost = row["single_cost"]
        self.different_pair_cost = row["different_pair_cost"]
        self.teacher_blank_class_max = row["blank_class_max"]
        self.teacher_blank_class_cost = list(map(lambda x: int(x), row["blank_class_cost"].split(',')))
        self.teacher_total_class_max = row["total_class_max"]
        self.teacher_total_class_cost = list(map(lambda x: int(x), row["total_class_cost"].split(',')))
        cur.close()
        return

    def __cost_for_student(self):
        cur = self.conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        sql_select = "select blank_class_cost, blank_class_max, total_class_cost, total_class_max, interval_cost "
        sql_from = "from calculation_rules "
        sql_where = f"where schedulemaster_id = {self.id} and eval_target = 'student'"
        cur.execute(sql_select + sql_from + sql_where)
        row = cur.fetchone()
        self.student_blank_class_max = row["blank_class_max"]
        self.student_blank_class_cost = list(map(lambda x: int(x), row["blank_class_cost"].split(',')))
        self.student_total_class_max = row["total_class_max"]
        self.student_total_class_cost = list(map(lambda x: int(x), row["total_class_cost"].split(',')))
        self.student_interval_cost = list(map(lambda x: int(x), row["interval_cost"].split(',')))
        self.student_interval_cost_count = len(self.student_interval_cost) - 1
        cur.close()
        return

    def __cost_for_student3g(self):
        cur = self.conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        sql_select = "select blank_class_cost, blank_class_max, total_class_cost, total_class_max, interval_cost "
        sql_from = "from calculation_rules "
        sql_where = f"where schedulemaster_id = {self.id} and eval_target = 'student3g'"
        cur.execute(sql_select + sql_from + sql_where)
        row = cur.fetchone()
        self.student3g_blank_class_max = row["blank_class_max"]
        self.student3g_blank_class_cost = list(map(lambda x: int(x), row["blank_class_cost"].split(',')))
        self.student3g_total_class_max = row["total_class_max"]
        self.student3g_total_class_cost = list(map(lambda x: int(x), row["total_class_cost"].split(',')))
        self.student3g_interval_cost = list(map(lambda x: int(x), row["interval_cost"].split(',')))
        self.student3g_interval_cost_count = len(self.student3g_interval_cost) - 1
        cur.close()
        return

    def __teachers(self):
        self.teachers = []
        cur = self.conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        sql_select = "select teachers.id, lastname, firstname from teachers "
        sql_join = "right join teacher_schedulemaster_mappings on teachers.id = teacher_schedulemaster_mappings.teacher_id "
        sql_where = f"where teacher_schedulemaster_mappings.schedulemaster_id = {self.id}"
        cur.execute(sql_select + sql_join + sql_where)
        for row in cur:
            self.teachers.append(row)
        self.teacher_count = len(self.teachers)
        cur.close()
        return

    def __students(self):
        self.students = []
        cur = self.conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        sql_select = "select students.id, lastname, firstname, student_schedulemaster_mappings.grade from students "
        sql_join = "right join student_schedulemaster_mappings on students.id = student_schedulemaster_mappings.student_id "
        sql_where = f"where student_schedulemaster_mappings.schedulemaster_id = {self.id}"
        cur.execute(sql_select + sql_join + sql_where)
        for row in cur:
            self.students.append(row)
        self.student_count = len(self.students)
        cur.close()
        return

    def __personal_subject(self):
        self.personal_subjects = []
        cur = self.conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        sql_select = "select subjects.id, name from subjects "
        sql_join = "right join subject_schedulemaster_mappings on subjects.id = subject_schedulemaster_mappings.subject_id "
        sql_where1 = f"where subject_schedulemaster_mappings.schedulemaster_id = {self.id} "
        sql_where2 = "and classtype='個別授業'"
        cur.execute(sql_select + sql_join + sql_where1 + sql_where2)
        for row in cur:
            self.personal_subjects.append(row)
        self.personal_subject_count = len(self.personal_subjects)
        cur.close()
        return

    def __group_subject(self):
        self.group_subjects = []
        cur = self.conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        sql_select = "select subjects.id, name from subjects "
        sql_join = "right join subject_schedulemaster_mappings on subjects.id = subject_schedulemaster_mappings.subject_id "
        sql_where1 = f"where subject_schedulemaster_mappings.schedulemaster_id = {self.id} "
        sql_where2 = "and classtype='集団授業'"
        cur.execute(sql_select + sql_join + sql_where1 + sql_where2)
        for row in cur:
            self.group_subjects.append(row)
        self.group_subject_count = len(self.group_subjects)
        cur.close()
        return

    def __student_group(self):
        self.student_group = np.zeros((self.student_count, self.group_subject_count), dtype=int)
        cur = self.conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        sql_select = "select student_id, subject_id from classnumbers "
        sql_join = "left join subjects on subjects.id = classnumbers.subject_id "
        sql_where = f"where schedulemaster_id = {self.id} and number = 1 and subjects.classtype = '集団授業'"
        cur.execute(sql_select + sql_join + sql_where)
        for row in cur:
            student_idx = self.__get_student_idx(row['student_id'])
            group_subject_idx = self.__get_group_subject_idx(row['subject_id'])
            self.student_group[student_idx][group_subject_idx] = 1
        cur.close()
        return

    def __student_group_reshaped(self):
        self.student_group_reshaped = np.zeros((self.student_count, self.day_count, self.class_count), dtype=int)
        for i in range(self.student_count):
            for j in range(self.day_count):
                for k in range(self.class_count):
                    for l in range(self.group_subject_count):
                        groupId = int(self.group_subjects[l]['id'])
                        if self.timetable[j,k] !=  groupId: continue
                        if self.student_group[i,l] == 0: continue
                        self.student_group_reshaped[i,j,k] = 1

    def __teacher_group(self):
        self.teacher_group = np.zeros((self.teacher_count, self.group_subject_count), dtype=int)
        cur = self.conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        sql_select = "select teacher_id, subject_id from subject_schedulemaster_mappings "
        sql_join = "left join subjects on subjects.id = subject_schedulemaster_mappings.subject_id "
        sql_where = f"where schedulemaster_id = {self.id} and subjects.classtype = '集団授業' and teacher_id != 0"
        cur.execute(sql_select + sql_join + sql_where)
        for row in cur:
            teacher_idx = self.__get_teacher_idx(row['teacher_id'])
            group_subject_idx = self.__get_group_subject_idx(row['subject_id'])
            self.teacher_group[teacher_idx][group_subject_idx] = 1
        cur.close()
        return

    def __teacher_group_reshaped(self):
        self.teacher_group_reshaped = np.zeros((self.teacher_count, self.day_count, self.class_count), dtype=int)
        for i in range(self.teacher_count):
            for j in range(self.day_count):
                for k in range(self.class_count):
                    for l in range(self.group_subject_count):
                        groupId = int(self.group_subjects[l]['id'])
                        if self.timetable[j,k] !=  groupId: continue
                        if self.teacher_group[i,l] == 0: continue
                        self.teacher_group_reshaped[i,j,k] = 1

    def __studentrequestmaster(self):
        self.studentrequestmaster = np.zeros((self.student_count), dtype=int)
        cur = self.conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        sql_select = "select student_id, status from studentrequestmasters "
        sql_where = f"where schedulemaster_id = {self.id}"
        cur.execute(sql_select + sql_where)
        for row in cur:
            student_idx = self.__get_student_idx(row['student_id'])
            self.studentrequestmaster[student_idx] = row['status']
        cur.close()
        return

    def __teacherrequestmaster(self):
        self.teacherrequestmaster = np.zeros((self.student_count), dtype=int)
        cur = self.conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        sql_select = "select teacher_id, status from teacherrequestmasters "
        sql_where = f"where schedulemaster_id = {self.id}"
        cur.execute(sql_select + sql_where)
        for row in cur:
            teacher_idx = self.__get_teacher_idx(row['teacher_id'])
            self.teacherrequestmaster[teacher_idx] = row['status']
        cur.close()
        return

    def __studentrequest(self):
        self.studentrequest = np.zeros((self.student_count, self.day_count, self.class_count), dtype=int)
        cur = self.conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        sql_select = "select student_id, timetables.scheduledate, timetables.classnumber from studentrequests "
        sql_join = "left join timetables on timetables.id = studentrequests.timetable_id "
        sql_where = f"where studentrequests.schedulemaster_id = {self.id}"
        cur.execute(sql_select + sql_join + sql_where)
        for row in cur:
            student_idx = self.__get_student_idx(row['student_id'])
            day_idx = self.days.index(row['scheduledate'])
            class_idx = self.classes.index(row['classnumber'])
            self.studentrequest[student_idx][day_idx][class_idx] = 1
        cur.close()
        return

    def __teacherrequest(self):
        self.teacherrequest = np.zeros((self.teacher_count, self.day_count, self.class_count), dtype=int)
        cur = self.conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        sql_select = "select teacher_id, timetables.scheduledate, timetables.classnumber from teacherrequests "
        sql_join = "left join timetables on timetables.id = teacherrequests.timetable_id "
        sql_where = f"where teacherrequests.schedulemaster_id = {self.id}"
        cur.execute(sql_select + sql_join + sql_where)
        for row in cur:
            teacher_idx = self.__get_teacher_idx(row['teacher_id'])
            day_idx = self.days.index(row['scheduledate'])
            class_idx = self.classes.index(row['classnumber'])
            self.teacherrequest[teacher_idx][day_idx][class_idx] = 1
        cur.close()
        return

    def __classnumber(self):
        self.classnumber = np.zeros((self.student_count, self.teacher_count, self.personal_subject_count), dtype=int)
        cur = self.conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        sql_select = "select teacher_id, student_id, subject_id, number from classnumbers "
        sql_join = "left join subjects on subjects.id = classnumbers.subject_id "
        sql_where = f"where schedulemaster_id = {self.id} and subjects.classtype = '個別授業' and teacher_id != 0"
        cur.execute(sql_select + sql_join + sql_where)
        for row in cur:
            student_idx = self.__get_student_idx(row['student_id'])
            teacher_idx = self.__get_teacher_idx(row['teacher_id'])
            personal_subject_idx = self.__get_personal_subject_idx(row['subject_id'])
            if self.teacherrequestmaster[teacher_idx] == 1 and self.studentrequestmaster[student_idx] == 1:
                self.classnumber[student_idx][teacher_idx][personal_subject_idx] = row['number']
            else:
                count = np.einsum('ijkml->ijk', self.schedule)
                self.classnumber[student_idx][teacher_idx][personal_subject_idx] = \
                        count[student_idx][teacher_idx][personal_subject_idx]
        cur.close()
        return

    def __timetable(self):
        self.timetable = np.zeros((self.day_count, self.class_count), dtype=int)
        self.timetable_id = np.zeros((self.day_count, self.class_count), dtype=int)
        cur = self.conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        sql_select = "select id, status, scheduledate, classnumber from timetables "
        sql_where = f"where schedulemaster_id = {self.id}"
        cur.execute(sql_select + sql_where)
        for row in cur:
            day_idx = self.days.index(row['scheduledate'])
            class_idx = self.classes.index(row['classnumber'])
            self.timetable[day_idx][class_idx] = row['status']
            self.timetable_id[day_idx][class_idx] = row['id']
        cur.close()
        return

    def __schedule(self):
        self.schedule = np.zeros(
                (self.student_count, self.teacher_count, self.personal_subject_count, self.day_count, self.class_count),
                dtype=int)
        self.schedule_fixonly = np.zeros(
                (self.student_count, self.teacher_count, self.personal_subject_count, self.day_count, self.class_count),
                dtype=int)
        cur = self.conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        sql_select = "select student_id, teacher_id, subject_id, schedules.status, timetables.scheduledate, timetables.classnumber from schedules "
        sql_join = "left join timetables on timetables.id = schedules.timetable_id "
        sql_where = f"where schedules.schedulemaster_id = {self.id} and timetable_id != 0"
        cur.execute(sql_select + sql_join + sql_where)
        for row in cur:
            student_idx = self.__get_student_idx(row['student_id'])
            teacher_idx = self.__get_teacher_idx(row['teacher_id'])
            personal_subject_idx = self.__get_personal_subject_idx(row['subject_id'])
            day_idx = self.days.index(row['scheduledate'])
            class_idx = self.classes.index(row['classnumber'])
            if row["status"] == 1:
                self.schedule_fixonly[student_idx][teacher_idx][personal_subject_idx][day_idx][class_idx] = 1
                self.schedule[student_idx][teacher_idx][personal_subject_idx][day_idx][class_idx] = 1
            elif row["status"] == 0:
                self.schedule[student_idx][teacher_idx][personal_subject_idx][day_idx][class_idx] = 1
        cur.close()
        return

    def __get_student_idx(self, student_id):
        student = next(student for student in self.students if student['id'] == student_id)
        return self.students.index(student)

    def __get_teacher_idx(self, teacher_id):
        teacher = next(teacher for teacher in self.teachers if teacher['id'] == teacher_id)
        return self.teachers.index(teacher)

    def __get_group_subject_idx(self, group_subject_id):
        group_subject = next(subject for subject in self.group_subjects if subject['id'] == group_subject_id)
        return self.group_subjects.index(group_subject)

    def __get_personal_subject_idx(self, personal_subject_id):
        personal_subject = next(subject for subject in self.personal_subjects if subject['id'] == personal_subject_id)
        return self.personal_subjects.index(personal_subject)
