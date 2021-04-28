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
            is_matched = (lambda item:
                item['term_student_id'] == term_student_id and
                item['date_index'] == date_index + 1 and
                item['period_index'] == period_index + 1)
            is_exist = True in [True for item in self.term.student_group_timetables if is_matched(item)]
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
            is_matched = (lambda item:
                item['term_teacher_id'] == term_teacher_id and
                item['date_index'] == date_index + 1 and
                item['period_index'] == period_index + 1)
            is_exist = True in [True for item in self.term.teacher_group_timetables if is_matched(item)]
            if is_exist: self.teacher_occupation_array[teacher_index, date_index, period_index] = 1
