import itertools
import numpy
from src.array_builder.array_index import get_student_index, get_teacher_index, get_tutorial_index, get_date_index, get_period_index

class TutorialOccupation():
    def __init__(self, term, array_size):
        self.term = term
        self.array_size = array_size
        self.__build_tutorial_occupation()

    def __build_tutorial_occupation(self):
        self.fixed_tutorial_occupation = numpy.zeros(
            (
                self.array_size.student_count,
                self.array_size.teacher_count,
                self.array_size.tutorial_count,
                self.array_size.date_count,
                self.array_size.period_count,
            ),
            dtype=int)
        self.floated_tutorial_occupation = numpy.zeros(
            (
                self.array_size.student_count,
                self.array_size.teacher_count,
                self.array_size.tutorial_count,
                self.array_size.date_count,
                self.array_size.period_count,
            ),
            dtype=int)
        tutorial_pieces = [
            tutorial_piece for tutorial_piece in self.term.tutorial_pieces
                if tutorial_piece['date_index'] != None and tutorial_piece['period_index'] != None
        ]
        for tutorial_piece in tutorial_pieces:
            student_index = get_student_index(self.term.term_students, tutorial_piece['term_student_id'])
            teacher_index = get_teacher_index(self.term.term_teachers, tutorial_piece['term_teacher_id'])
            tutorial_index = get_tutorial_index(self.term.term_tutorials, tutorial_piece['term_tutorial_id'])
            date_index = get_date_index(tutorial_piece['date_index'])
            period_index = get_period_index(tutorial_piece['period_index'])
            is_fixed = tutorial_piece['is_fixed']
            if is_fixed:
                self.fixed_tutorial_occupation[student_index, teacher_index, tutorial_index, date_index, period_index] = 1
            else:
                self.floated_tutorial_occupation[student_index, teacher_index, tutorial_index, date_index, period_index] = 1
