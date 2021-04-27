import itertools
import numpy

class TutorialContract():
    def __init__(self, term, array_size):
        self.term = term
        self.array_size = array_size
        self.__build_tutorial_contract()

    def __build_tutorial_contract(self):
        self.tutorial_contract_array = numpy.zeros(
            (self.array_size.student_count, self.array_size.tutorial_count),
            dtype=int)
        student_index_list = list(range(self.array_size.student_count))
        tutorial_index_list = list(range(self.array_size.tutorial_count))
        product = itertools.product(student_index_list, tutorial_index_list)
        for student_index, tutorial_index in product:
            term_student_id = self.term.term_students[student_index]['id']
            term_tutorial_id = self.term.term_tutorials[tutorial_index]['id']
            is_matched = (lambda tutorial_contract:
                tutorial_contract['term_student_id'] == term_student_id and
                tutorial_contract['term_tutorial_id'] == term_tutorial_id)
            piece_count = next(tutorial_contract['piece_count'] for tutorial_contract in self.term.tutorial_contracts if is_matched(tutorial_contract))
            self.tutorial_contract_array[student_index, tutorial_index] = piece_count
