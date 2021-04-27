import logging
import itertools
from array_contract import term_student_index, term_teacher_index

logger = logging.getLogger('ArrayIndex')

class GroupOccupation():
    def __init__(self, term):
        self.term = term
        self.__build_student_occupation
        self.__build_teacher_occupation

    def __build_student_occupation(self):
        self.student_occupation = np.zeros(
            (self.term.term_student_count, self.term.date_count, self.term.period_count),
            dtype=int)
        term_student_list = list(range(self.term.term_student_count))
        date_index_list = list(range(self.term.date_count))
        period_index_list = list(range(self.term.period_count))
        term_group_index_list = list(range(self.term.term_group_count))
        product = itertools.product(term_student_list, date_index_list, period_index_list, term_group_index_list)
        for term_student_index, date_index, period_index, term_group_index in product:
            is_matched = (lambda timetable:
                timetable['date_index'] == date_index and
                timetable['period_index'] == period_index and
                timetable['term_group_index'] == term_group_index and
                timetable['term_student_index'] == term_student_index)
            is_contracted = True in [True for timetable in self.term.timetables if is_matched(timetable)]
            if is_contracted: self.student_occupation[term_student_index, date_index, period_index] = 1

    def __build_teacher_occupation(self):
        self.teacher_occupation = np.zeros(
            (self.term.term_teacher_count, self.term.date_count, self.term.period_count)
            dtype=int)
        term_teacher_list = list(range(self.term.term_teacher_count))
        date_index_list = list(range(self.term.date_count))
        period_index_list = list(range(self.term.period_count))
        term_group_index_list = list(range(self.term.term_group_count))
        product = itertools.product(term_teacher_list, date_index_list, period_index_list, term_group_index_list)
        for term_teacher_index, date_index, period_index, term_group_index in product:
            is_matched = (lambda timetable:
                timetable['date_index'] == date_index and
                timetable['period_index'] == period_index and
                timetable['term_group_index'] == term_group_index and
                timetable['term_teacher_index'] == term_teacher_index)
            is_contracted = True in [True for timetable in self.term.timetables if is_matched(timetable)]
            if is_contracted: self.teacher_occupation[term_teacher_index, date_index, period_index] = 1
