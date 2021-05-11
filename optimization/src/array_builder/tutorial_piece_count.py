import itertools
import numpy


class TutorialPieceCount():
    def __init__(self, term, array_size):
        self.__term = term
        self.__array_size = array_size
        self.__build_tutorial_piece_count()

    def __build_tutorial_piece_count(self):
        self.__tutorial_piece_count_array = numpy.zeros(
            (self.__array_size.student_count(),
             self.__array_size.teacher_count(),
             self.__array_size.tutorial_count()),
            dtype=int)
        student_index_list = list(range(self.__array_size.student_count()))
        teacher_index_list = list(range(self.__array_size.teacher_count()))
        tutorial_index_list = list(range(self.__array_size.tutorial_count()))
        product = itertools.product(student_index_list, teacher_index_list, tutorial_index_list)
        for student_index, teacher_index, tutorial_index in product:
            term_student_id = \
                self.__term['term_students'][student_index]['id']
            term_teacher_id = \
                self.__term['term_teachers'][teacher_index]['id']
            term_tutorial_id = \
                self.__term['term_tutorials'][tutorial_index]['id']
            is_matched = (
                lambda tutorial_contract:
                    tutorial_contract['term_student_id'] == term_student_id and
                    tutorial_contract['term_teacher_id'] == term_teacher_id and
                    tutorial_contract['term_tutorial_id'] == term_tutorial_id)
            piece_count = next(
                (tutorial_contract['piece_count']
                for tutorial_contract in self.__term['tutorial_contracts']
                if is_matched(tutorial_contract)), 0)
            self.__tutorial_piece_count_array[
                student_index, teacher_index, tutorial_index] = piece_count

    def tutorial_piece_count_array(self):
        return self.__tutorial_piece_count_array
