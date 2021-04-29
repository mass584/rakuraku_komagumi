import itertools
import numpy
from src.array_builder.array_index import get_student_index, get_teacher_index, get_tutorial_index, get_date_index, get_period_index


class TutorialOccupation():
    def __init__(self, term, array_size):
        self.__term = term
        self.__array_size = array_size
        self.__build_tutorial_occupation()

    def __build_tutorial_occupation(self):
        self.__fixed_tutorial_occupation = numpy.zeros(
            (
                self.__array_size.student_count(),
                self.__array_size.teacher_count(),
                self.__array_size.tutorial_count(),
                self.__array_size.date_count(),
                self.__array_size.period_count(),
            ),
            dtype=int)
        self.__floated_tutorial_occupation = numpy.zeros(
            (
                self.__array_size.student_count(),
                self.__array_size.teacher_count(),
                self.__array_size.tutorial_count(),
                self.__array_size.date_count(),
                self.__array_size.period_count(),
            ),
            dtype=int)
        self.__tutorial_occupation = numpy.zeros(
            (
                self.__array_size.student_count(),
                self.__array_size.teacher_count(),
                self.__array_size.tutorial_count(),
                self.__array_size.date_count(),
                self.__array_size.period_count(),
            ),
            dtype=int)
        tutorial_pieces = [
            tutorial_piece for tutorial_piece in self.__term['tutorial_pieces']
            if tutorial_piece['date_index'] is not None and tutorial_piece['period_index'] is not None
        ]
        for tutorial_piece in tutorial_pieces:
            student_index = get_student_index(
                self.__term['term_students'], tutorial_piece['term_student_id'])
            teacher_index = get_teacher_index(
                self.__term['term_teachers'], tutorial_piece['term_teacher_id'])
            tutorial_index = get_tutorial_index(
                self.__term['term_tutorials'], tutorial_piece['term_tutorial_id'])
            date_index = get_date_index(tutorial_piece['date_index'])
            period_index = get_period_index(tutorial_piece['period_index'])
            is_fixed = tutorial_piece['is_fixed']
            if is_fixed:
                self.__fixed_tutorial_occupation[
                    student_index, teacher_index, tutorial_index, date_index, period_index
                ] = 1
            if not is_fixed:
                self.__floated_tutorial_occupation[
                    student_index, teacher_index, tutorial_index, date_index, period_index
                ] = 1
            self.__tutorial_occupation[
                student_index, teacher_index, tutorial_index, date_index, period_index
            ] = 1

    def fixed_tutorial_occupation(self):
        return self.__fixed_tutorial_occupation

    def floated_tutorial_occupation(self):
        return self.__floated_tutorial_occupation

    def tutorial_occupation(self):
        return self.__tutorial_occupation
