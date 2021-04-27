import numpy as np
import itertools
from array_contract import term_student_index, term_teacher_index

class GroupOccupation():
    def __init__(self, term, array_size):
        self.term = term
        self.array_size = array_size
        self.__build_student_occupation
        self.__build_teacher_occupation

    def __build_student_occupation(self):
        self.student_occupation = np.zeros(
            (self.array_size.student_count, self.array_size.date_count, self.array_size.period_count),
            dtype=int)
        student_index_list = list(range(self.array_size.student_count))
        date_index_list = list(range(self.array_size.date_count))
        period_index_list = list(range(self.array_size.period_count))
        group_index_list = list(range(self.array_size.group_count))
        product = itertools.product(student_index_list, date_index_list, period_index_list, group_index_list)
        for student_index, date_index, period_index, group_index in product:
            is_matched = (lambda timetable:
                timetable['date_index'] == date_index and
                timetable['period_index'] == period_index and
                timetable['term_group_index'] == group_index and
                timetable['term_student_index'] == student_index)
            is_contracted = True in [True for timetable in self.term.timetables if is_matched(timetable)]
            if is_contracted: self.student_occupation[student_index, date_index, period_index] = 1

    def __build_teacher_occupation(self):
        self.teacher_occupation = np.zeros(
            (self.array_size.teacher_count, self.array_size.date_count, self.array_size.period_count)
            dtype=int)
        teacher_index_list = list(range(self.array_size.teacher_count))
        date_index_list = list(range(self.array_size.date_count))
        period_index_list = list(range(self.array_size.period_count))
        group_index_list = list(range(self.array_size.group_count))
        product = itertools.product(teacher_index_list, date_index_list, period_index_list, group_index_list)
        for term_teacher_index, date_index, period_index, term_group_index in product:
            is_matched = (lambda timetable:
                timetable['date_index'] == date_index and
                timetable['period_index'] == period_index and
                timetable['term_group_index'] == group_index and
                timetable['term_teacher_index'] == teacher_index)
            is_contracted = True in [True for timetable in self.term.timetables if is_matched(timetable)]
            if is_contracted: self.teacher_occupation[teacher_index, date_index, period_index] = 1
