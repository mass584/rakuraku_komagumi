import logging
import itertools
from array_contract import term_student_index, term_teacher_index

logger = logging.getLogger('ArrayIndex')

class Vacancy():
    def __init__(self, term):
        self.term = term
        self.student_vacancy = self.__student_vacancy
        self.teacher_vacancy = self.__teacher_vacancy

    def __student_vacancy(self):
        array = np.zeros(
            (self.term.term_student_count, self.term.date_count, self.term.period_count),
            dtype=int)
        term_student_list = list(range(self.term.term_student_count))
        date_index_list = list(range(self.term.date_count))
        period_index_list = list(range(self.term.period_count))
        product = itertools.product(term_student_list, date_index_list, period_index_list)
        for term_student_index, date_index, period_index in product:
            is_matched = (lambda student_vacancy:
                student_vacancy['term_student_index'] == term_student_index and
                student_vacancy['date_index'] == date_index and
                student_vacancy['period_index'] == period_index and
                student_vacancy['is_vacant'] == True)
            is_vacant = True in [True for timetable in self.term.timetables if is_matched(timetable)]
            if is_vacant: array[term_student_index, date_index, period_index] = 1
        return array

    def __teacher_vacancy(self):
        array = np.zeros(
            (self.term.term_teacher_count, self.term.date_count, self.term.period_count)
            dtype=int)
        term_teacher_list = list(range(self.term.term_teacher_count))
        date_index_list = list(range(self.term.date_count))
        period_index_list = list(range(self.term.period_count))
        product = itertools.product(term_teacher_list, date_index_list, period_index_list, term_group_index_list)
        for term_teacher_index, date_index, period_index in product:
            is_matched = (lambda timetable:
                teacher_vacancy['term_teacher_index'] == term_teacher_index and
                teacher_vacancy['date_index'] == date_index and
                teacher_vacancy['period_index'] == period_index and
                teacher_vacancy['is_vacant'] == True)
            is_vacant = True in [True for timetable in self.term.timetables if is_matched(timetable)]
            if is_vacant: array[term_teacher_index, date_index, period_index] = 1
        return array
