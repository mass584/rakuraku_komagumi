import itertools
import numpy

class GroupOccupation():
    def __init__(self, term, array_size):
        self.term = term
        self.array_size = array_size
        self.__build_student_occupation()
        self.__build_teacher_occupation()

    def __build_student_occupation(self):
        self.student_occupation_array = numpy.zeros(
            (self.array_size.student_count, self.array_size.date_count, self.array_size.period_count),
            dtype=int)
        student_index_list = list(range(self.array_size.student_count))
        date_index_list = list(range(self.array_size.date_count))
        period_index_list = list(range(self.array_size.period_count))
        product = itertools.product(student_index_list, date_index_list, period_index_list)
        for student_index, date_index, period_index in product:
            term_student_id = self.term.term_students[student_index]['id']
            is_matched = (lambda group_contract:
                group_contract['date_index'] == date_index + 1 and
                group_contract['period_index'] == period_index + 1 and
                group_contract['term_student_id'] == term_student_id and
                group_contract['is_contracted'] == True)
            is_exist = True in [True for group_contract in self.term.group_contracts if is_matched(group_contract)]
            if is_exist: self.student_occupation_array[student_index, date_index, period_index] = 1

    def __build_teacher_occupation(self):
        self.teacher_occupation_array = numpy.zeros(
            (self.array_size.teacher_count, self.array_size.date_count, self.array_size.period_count),
            dtype=int)
        teacher_index_list = list(range(self.array_size.teacher_count))
        date_index_list = list(range(self.array_size.date_count))
        period_index_list = list(range(self.array_size.period_count))
        product = itertools.product(teacher_index_list, date_index_list, period_index_list)
        for teacher_index, date_index, period_index in product:
            term_teacher_id = self.term.term_teachers[teacher_index]['id']
            is_matched = (lambda timetable:
                timetable['date_index'] == date_index + 1 and
                timetable['period_index'] == period_index + 1 and
                timetable['term_teacher_id'] == term_teacher_id)
            is_exist = True in [True for timetable in self.term.timetables if is_matched(timetable)]
            if is_exist: self.teacher_occupation_array[teacher_index, date_index, period_index] = 1
