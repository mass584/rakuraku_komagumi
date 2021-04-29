import logging

logger = logging.getLogger('Term')


class TermObject():
    def __init__(self, database, term_id):
        self.__database = database
        self.__term_id = term_id
        self.__fetched = False

    def fetch(self):
        if not self.__fetched:
            self.__fetch_all()
        self.__fetched = True
        return {
            'term': self.__term,
            'teacher_optimization_rule': self.__teacher_optimization_rule,
            'student_optimization_rules': self.__student_optimization_rules,
            'term_teachers': self.__term_teachers,
            'term_students': self.__term_students,
            'term_tutorials': self.__term_tutorials,
            'term_groups': self.__term_groups,
            'student_vacancies': self.__student_vacancies,
            'teacher_vacancies': self.__teacher_vacancies,
            'tutorial_contracts': self.__tutorial_contracts,
            'tutorial_pieces': self.__tutorial_pieces,
            'teacher_group_timetables': self.__teacher_group_timetables,
            'student_group_timetables': self.__student_group_timetables,
            'seats': self.__seats,
        }

    def __fetch_all(self):
        self.__database.connect()
        self.__fetch_term()
        self.__fetch_teacher_optimization_rule()
        self.__fetch_student_optimization_rules()
        self.__fetch_term_teachers()
        self.__fetch_term_students()
        self.__fetch_term_tutorials()
        self.__fetch_term_groups()
        self.__fetch_student_vacancies()
        self.__fetch_teacher_vacancies()
        self.__fetch_tutorial_pieces()
        self.__fetch_tutorial_contracts()
        self.__fetch_teacher_group_timetables()
        self.__fetch_student_group_timetables()
        self.__fetch_seats()
        self.__database.commit()
        self.__database.close()

    def __fetch_term(self):
        cur = self.__database.cursor()
        sql_select = (', '.join([
            "id", "name", "year", "term_type", "begin_at",
            "end_at", "period_count", "seat_count", "position_count"]))
        sql_from = "terms"
        sql_where = f"id = {self.__term_id}"
        cur.execute(' '.join([
            'select', sql_select,
            'from', sql_from,
            'where', sql_where]))
        self.__term = dict(cur.fetchone())
        cur.close()

    def __fetch_teacher_optimization_rule(self):
        cur = self.__database.cursor()
        sql_select = (', '.join([
            "single_cost", "different_pair_cost",
            "occupation_limit", "occupation_costs",
            "blank_limit", "blank_costs"]))
        sql_from = "teacher_optimization_rules"
        sql_where = f"term_id = {self.__term_id}"
        cur.execute(' '.join([
            'select', sql_select,
            'from', sql_from,
            'where', sql_where]))
        self.__teacher_optimization_rule = dict(cur.fetchone())
        cur.close()

    def __fetch_student_optimization_rules(self):
        cur = self.__database.cursor()
        sql_select = (', '.join([
            "school_grade", "occupation_limit", "occupation_costs",
            "blank_limit", "blank_costs",
            "interval_cutoff", "interval_costs"]))
        sql_from = "student_optimization_rules"
        sql_where = f"term_id = {self.__term_id}"
        cur.execute(' '.join([
            'select', sql_select,
            'from', sql_from,
            'where', sql_where]))
        self.__student_optimization_rules = list(
            map(lambda record: dict(record), cur.fetchall()))
        cur.close()

    def __fetch_term_teachers(self):
        cur = self.__database.cursor()
        sql_select = (', '.join([
            "term_teachers.id", "teachers.name",
            "term_teachers.vacancy_status"]))
        sql_from = (
            "term_teachers join teachers "
            "on teachers.id = term_teachers.teacher_id")
        sql_where = f"term_teachers.term_id = {self.__term_id}"
        cur.execute(' '.join([
            'select', sql_select,
            'from', sql_from,
            'where', sql_where]))
        self.__term_teachers = list(
            map(lambda record: dict(record), cur.fetchall()))
        cur.close()

    def __fetch_term_students(self):
        cur = self.__database.cursor()
        sql_select = (', '.join([
            "term_students.id", "students.name",
            "students.school_grade", "term_students.vacancy_status"]))
        sql_from = (
            "term_students join students "
            "on students.id = term_students.student_id")
        sql_where = f"term_students.term_id = {self.__term_id}"
        cur.execute(' '.join([
            'select', sql_select,
            'from', sql_from,
            'where', sql_where]))
        self.__term_students = list(
            map(lambda record: dict(record), cur.fetchall()))
        cur.close()

    def __fetch_term_tutorials(self):
        cur = self.__database.cursor()
        sql_select = "term_tutorials.id, tutorials.name"
        sql_from = (
            "term_tutorials join tutorials "
            "on tutorials.id = term_tutorials.tutorial_id")
        sql_where = f"term_tutorials.term_id = {self.__term_id}"
        cur.execute(' '.join([
            'select', sql_select,
            'from', sql_from,
            'where', sql_where]))
        self.__term_tutorials = list(
            map(lambda record: dict(record), cur.fetchall()))
        cur.close()

    def __fetch_term_groups(self):
        cur = self.__database.cursor()
        sql_select = "term_groups.id, groups.name"
        sql_from = (
            "term_groups join groups "
            "on groups.id = term_groups.group_id")
        sql_where = f"term_groups.term_id = {self.__term_id}"
        cur.execute(' '.join([
            'select', sql_select,
            'from', sql_from,
            'where', sql_where]))
        self.__term_groups = list(
            map(lambda record: dict(record), cur.fetchall()))
        cur.close()

    def __fetch_student_vacancies(self):
        cur = self.__database.cursor()
        sql_select = (', '.join([
            "timetables.date_index",
            "timetables.period_index",
            "term_student_id", "is_vacant"]))
        sql_from = (
            "student_vacancies join timetables "
            "on timetables.id = student_vacancies.timetable_id")
        sql_where = f"timetables.term_id = {self.__term_id}"
        cur.execute(' '.join([
            'select', sql_select,
            'from', sql_from,
            'where', sql_where]))
        self.__student_vacancies = list(
            map(lambda record: dict(record), cur.fetchall()))
        cur.close()

    def __fetch_teacher_vacancies(self):
        cur = self.database.cursor()
        sql_select = (', '.join([
            "timetables.date_index",
            "timetables.period_index",
            "term_teacher_id",
            "is_vacant"]))
        sql_from = (
            "teacher_vacancies join timetables "
            "on timetables.id = teacher_vacancies.timetable_id")
        sql_where = f"timetables.term_id = {self.__term_id}"
        cur.execute(' '.join([
            'select', sql_select,
            'from', sql_from,
            'where', sql_where]))
        self.__teacher_vacancies = list(
            map(lambda record: dict(record), cur.fetchall()))
        cur.close()

    def __fetch_tutorial_pieces(self):
        cur = self.__database.cursor()
        sql_select = (', '.join([
            "timetables.date_index", "timetables.period_index",
            "tutorial_contracts.term_student_id",
            "tutorial_contracts.term_teacher_id",
            "tutorial_contracts.term_tutorial_id",
            "tutorial_pieces.is_fixed"]))
        sql_from = (
            "((tutorial_pieces left join seats "
            "on seats.id = tutorial_pieces.seat_id) "
            "left join timetables on timetables.id = seats.timetable_id) "
            "left join tutorial_contracts on "
            "tutorial_contracts.id = tutorial_pieces.tutorial_contract_id")
        sql_where = f"tutorial_pieces.term_id = {self.__term_id}"
        cur.execute(' '.join([
            'select', sql_select,
            'from', sql_from,
            'where', sql_where]))
        self.__tutorial_pieces = list(
            map(lambda record: dict(record), cur.fetchall()))
        cur.close()

    def __fetch_tutorial_contracts(self):
        cur = self.__database.cursor()
        sql_select = (', '.join([
            "term_student_id", "term_tutorial_id",
            "term_teacher_id", "piece_count"]))
        sql_from = "tutorial_contracts"
        sql_where = f"term_id = {self.__term_id}"
        cur.execute(' '.join([
            'select', sql_select,
            'from', sql_from,
            'where', sql_where]))
        self.__tutorial_contracts = list(
            map(lambda record: dict(record), cur.fetchall()))
        cur.close()

    def __fetch_teacher_group_timetables(self):
        cur = self.__database.cursor()
        sql_select = (', '.join([
            "timetables.date_index", "timetables.period_index",
            "timetables.term_group_id", "term_groups.term_teacher_id"]))
        sql_from = (
            "timetables join term_groups "
            "on term_groups.id = timetables.term_group_id")
        sql_where = f"timetables.term_id = {self.__term_id}"
        cur.execute(' '.join([
            'select', sql_select,
            'from', sql_from,
            'where', sql_where]))
        self.__teacher_group_timetables = list(
            map(lambda record: dict(record), cur.fetchall()))
        cur.close()

    def __fetch_student_group_timetables(self):
        cur = self.__database.cursor()
        sql_select = (', '.join([
            "timetables.date_index",
            "timetables.period_index",
            "timetables.term_group_id",
            "group_contracts.term_student_id"]))
        sql_from = (
            "timetables join group_contracts "
            "on timetables.term_group_id = group_contracts.term_group_id")
        sql_where = (
            f"group_contracts.term_id = {self.__term_id} "
            "and group_contracts.is_contracted = true")
        cur.execute(' '.join([
            'select', sql_select,
            'from', sql_from,
            'where', sql_where]))
        self.__student_group_timetables = list(
            map(lambda record: dict(record), cur.fetchall()))
        cur.close()

    def __fetch_seats(self):
        cur = self.__database.cursor()
        sql_select = (', '.join([
            "id", "timetables.date_index", "timetables.period_index",
            "seat_index", "term_teacher_id", "position_count"]))
        sql_from = (
            "seats join timetables "
            "on timetables.id = seats.timetable_id")
        sql_where = f"seats.term_id = {self.__term_id}"
        cur.execute(' '.join([
            'select', sql_select,
            'from', sql_from,
            'where', sql_where]))
        self.__seats = list(map(lambda record: dict(record), cur.fetchall()))
        cur.close()
