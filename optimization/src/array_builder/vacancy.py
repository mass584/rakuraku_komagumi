import itertools
import numpy

class Vacancy():
    def __init__(self, term, array_size):
        self.term = term
        self.array_size = array_size
        self.__build_student_vacancy()
        self.__build_teacher_vacancy()

    def __build_student_vacancy(self):
        array = numpy.zeros(
            (self.array_size.student_count, self.array_size.date_count, self.array_size.period_count),
            dtype=int)
        student_list = list(range(self.array_size.student_count))
        date_index_list = list(range(self.array_size.date_count))
        period_index_list = list(range(self.array_size.period_count))
        product = itertools.product(student_list, date_index_list, period_index_list)
        for student_index, date_index, period_index in product:
            term_student_id = self.term.term_students[student_index]['id']
            is_matched = (lambda student_vacancy:
                student_vacancy['term_student_id'] == term_student_id and
                student_vacancy['date_index'] == date_index + 1 and
                student_vacancy['period_index'] == period_index + 1 and
                student_vacancy['is_vacant'] == True)
            is_vacant = True in [True for student_vacancy in self.term.student_vacancies if is_matched(student_vacancy)]
            if is_vacant: array[student_index, date_index, period_index] = 1
        self.student_vacancy_array = array

    def __build_teacher_vacancy(self):
        array = numpy.zeros(
            (self.array_size.teacher_count, self.array_size.date_count, self.array_size.period_count),
            dtype=int)
        teacher_list = list(range(self.array_size.teacher_count))
        date_index_list = list(range(self.array_size.date_count))
        period_index_list = list(range(self.array_size.period_count))
        product = itertools.product(teacher_list, date_index_list, period_index_list)
        for teacher_index, date_index, period_index in product:
            term_teacher_id = self.term.term_teachers[teacher_index]['id']
            is_matched = (lambda teacher_vacancy:
                teacher_vacancy['term_teacher_id'] == term_teacher_id and
                teacher_vacancy['date_index'] == date_index + 1 and
                teacher_vacancy['period_index'] == period_index + 1 and
                teacher_vacancy['is_vacant'] == True)
            is_vacant = True in [True for teacher_vacancy in self.term.teacher_vacancies if is_matched(teacher_vacancy)]
            if is_vacant: array[teacher_index, date_index, period_index] = 1
        self.teacher_vacancy_array = array
