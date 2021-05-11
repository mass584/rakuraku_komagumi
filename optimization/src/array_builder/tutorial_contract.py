import itertools
import numpy
from .array_index import get_teacher_index


class TutorialContract():
    def __init__(self, term, array_size):
        self.__term = term
        self.__array_size = array_size
        self.__build_tutorial_contract()

    def __build_tutorial_contract(self):
        self.__tutorial_contract_array = numpy.zeros(
            (self.__array_size.student_count(),
             self.__array_size.teacher_count(),
             self.__array_size.tutorial_count()),
            dtype=int)
        student_index_list = list(range(self.__array_size.student_count()))
        tutorial_index_list = list(range(self.__array_size.tutorial_count()))
        product = itertools.product(student_index_list, tutorial_index_list)
        for student_index, tutorial_index in product:
            term_student_id = \
                self.__term['term_students'][student_index]['id']
            term_tutorial_id = \
                self.__term['term_tutorials'][tutorial_index]['id']
            is_matched = (
                lambda tutorial_contract:
                    tutorial_contract['term_student_id'] == term_student_id and
                    tutorial_contract['term_tutorial_id'] == term_tutorial_id)
            piece_count = next(
                tutorial_contract['piece_count']
                for tutorial_contract in self.__term['tutorial_contracts']
                if is_matched(tutorial_contract))
            teacher_index = next(
                get_teacher_index(
                    self.__term['term_teachers'],
                    tutorial_contract['term_teacher_id'])
                for tutorial_contract in self.__term['tutorial_contracts']
                if is_matched(tutorial_contract))
            self.__tutorial_contract_array[
                student_index, teacher_index, tutorial_index] = piece_count

    def tutorial_contract_array(self):
        return self.__tutorial_contract_array
