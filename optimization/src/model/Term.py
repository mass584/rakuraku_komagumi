import logging

logger = logging.getLogger('Term')

class Term():
    def __init__(self, database, term_id):
        self.database = database
        self.term_id = term_id

    def fetch_all(self):
        self.database.connect()
        self.__fetch_term()
        self.__fetch_teacher_optimization_rule()
        self.__fetch_student_optimization_rules()
        self.__fetch_term_teachers()
        self.__fetch_term_students()
        self.__fetch_term_tutorials()
        self.__fetch_term_groups()
        self.__fetch_tutorial_contracts()
        self.__fetch_tutorial_pieces()
        self.__fetch_group_contracts()
        self.__fetch_student_vacancies()
        self.__fetch_teacher_vacancies()
        self.__fetch_timetables()
        self.__fetch_seats()
        self.__build_counts()
        self.database.commit()
        self.database.close()

    def update_exit_status(self, exit_status):
        self.database.connect()
        cur = self.database.cursor()
        cur.execute(f"update terms set exit_status = '{exit_status}' where id = {self.term_id}")
        cur.close()
        self.database.commit()
        self.database.close()

    def __fetch_term(self):
        cur = self.database.cursor()
        sql = f"select * from terms where id = {self.term_id}"
        cur.execute(sql)
        self.term = dict(cur.fetchone())
        cur.close()

    def __fetch_teacher_optimization_rule(self):
        cur = self.database.cursor()
        sql = f"select * from teacher_optimization_rules where term_id = {self.term_id}"
        cur.execute(sql)
        self.teacher_optimization_rule = dict(cur.fetchone())
        cur.close()

    def __fetch_student_optimization_rules(self):
        cur = self.database.cursor()
        sql = f"select * from student_optimization_rules where term_id = {self.term_id}"
        cur.execute(sql)
        self.student_optimization_rules = list(map(lambda record: dict(record), cur.fetchall()))
        cur.close()

    def __fetch_term_teachers(self):
        cur = self.database.cursor()
        sql_select = "select term_teachers.id, teachers.name, term_teachers.vacancy_status from term_teachers "
        sql_join = "join teachers on teachers.id = term_teachers.teacher_id "
        sql_where = f"where term_teachers.term_id = {self.term_id}"
        cur.execute(sql_select + sql_join + sql_where)
        self.term_teachers = list(map(lambda record: dict(record), cur.fetchall()))
        cur.close()

    def __fetch_term_students(self):
        cur = self.database.cursor()
        sql_select = "select term_students.id, students.name, students.school_grade, term_students.vacancy_status from term_students "
        sql_join = "join students on students.id = term_students.student_id "
        sql_where = f"where term_students.term_id = {self.term_id}"
        cur.execute(sql_select + sql_join + sql_where)
        self.term_students = list(map(lambda record: dict(record), cur.fetchall()))
        cur.close()

    def __fetch_term_tutorials(self):
        cur = self.database.cursor()
        sql_select = "select term_tutorials.id, tutorials.name from term_tutorials "
        sql_join = "join tutorials on tutorials.id = term_tutorials.tutorial_id "
        sql_where = f"where term_tutorials.term_id = {self.term_id}"
        cur.execute(sql_select + sql_join + sql_where)
        self.term_tutorials = list(map(lambda record: dict(record), cur.fetchall()))
        cur.close()

    def __fetch_term_groups(self):
        cur = self.database.cursor()
        sql_select = "select term_groups.id, groups.name from term_groups "
        sql_join = "join groups on groups.id = term_groups.group_id "
        sql_where = f"where term_groups.term_id = {self.term_id} "
        cur.execute(sql_select + sql_join + sql_where)
        self.term_groups = list(map(lambda record: dict(record), cur.fetchall()))
        cur.close()

    def __fetch_tutorial_contracts(self):
        cur = self.database.cursor()
        sql_select = "select term_teacher_id, term_student_id, term_tutorial_id, piece_count from tutorial_contracts "
        sql_where = f"where term_id = {self.term_id}"
        cur.execute(sql_select + sql_where)
        self.tutorial_contracts = list(map(lambda record: dict(record), cur.fetchall()))
        cur.close()

    def __fetch_group_contracts(self):
        cur = self.database.cursor()
        sql_select = "select term_student_id, term_group_id, is_contracted from group_contracts "
        sql_where = f"where term_id = {self.term_id}"
        cur.execute(sql_select + sql_where)
        self.group_contracts = list(map(lambda record: dict(record), cur.fetchall()))
        cur.close()

    def __fetch_tutorial_pieces(self):
        cur = self.database.cursor()
        sql_select = "timetables.date_index, timetables.period_index, tutorial_contracts.term_student_id, tutorial_contracts.term_teacher_id, tutorial_contracts.term_tutorial_id"
        sql_from = "((tutorial_pieces left join seats on seats.id = tutorial_pieces.seat_id) left join timetables on timetables.id = seats.timetable_id) left join tutorial_contracts on tutorial_contracts.id = tutorial_pieces.tutorial_contract_id"
        sql_where = f"tutorial_pieces.term_id = {self.term_id}"
        cur.execute(' '.join(['select', sql_select, 'from', sql_from, 'where', sql_where]))
        self.tutorial_pieces = list(map(lambda record: dict(record), cur.fetchall()))
        cur.close()

    def __fetch_student_vacancies(self):
        cur = self.database.cursor()
        sql_select = "select timetables.date_index, timetables.period_index, term_student_id, is_vacant from student_vacancies "
        sql_join = "join timetables on timetables.id = student_vacancies.timetable_id "
        sql_where = f"where timetables.term_id = {self.term_id}"
        cur.execute(sql_select + sql_join + sql_where)
        self.student_vacancies = list(map(lambda record: dict(record), cur.fetchall()))
        cur.close()

    def __fetch_teacher_vacancies(self):
        cur = self.database.cursor()
        sql_select = "select timetables.date_index, timetables.period_index, term_teacher_id, is_vacant from teacher_vacancies "
        sql_join = "join timetables on timetables.id = teacher_vacancies.timetable_id "
        sql_where = f"where timetables.term_id = {self.term_id}"
        cur.execute(sql_select + sql_join + sql_where)
        self.teacher_vacancies = list(map(lambda record: dict(record), cur.fetchall()))
        cur.close()

    def __fetch_timetables(self):
        cur = self.database.cursor()
        sql_select = "select date_index, period_index, is_closed, term_group_id, term_groups.term_teacher_id from timetables "
        sql_join = "join term_groups on term_groups.term_teacher_id = timetables.term_group_id "
        sql_where = f"where timetables.term_id = {self.term_id}"
        cur.execute(sql_select + sql_join + sql_where)
        self.timetables = list(map(lambda record: dict(record), cur.fetchall()))
        cur.close()

    def __fetch_seats(self):
        cur = self.database.cursor()
        sql_select = "select timetables.date_index, timetables.period_index, seat_index, term_teacher_id, position_count from seats "
        sql_join = "join timetables on timetables.id = seats.timetable_id "
        sql_where = f"where seats.term_id = {self.term_id}"
        cur.execute(sql_select + sql_join + sql_where)
        self.seats = list(map(lambda record: dict(record), cur.fetchall()))
        cur.close()

    def __build_counts(self):
        self.term_teacher_count = len(self.term_teachers)
        self.term_student_count = len(self.term_students)
        self.term_tutorial_count = len(self.term_tutorials)
        self.term_group_count = len(self.term_groups)
        self.date_count = (self.term['end_at'] - self.term['begin_at']).days + 1
        self.period_count = self.term['period_count']
