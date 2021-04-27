import itertools
from array_index import term_student_index, term_teacher_index, term_tutorial_index, date_index, period_index

class TutorialOccupation():
    def __init__(self, term):
        self.term = term
        self.__build_tutorial_occupation

    def __build_tutorial_occupation(self):
        self.fixed_tutorial_occupation = np.zeros(
            (
                self.term.term_student_count,
                self.term.term_teacher_count,
                self.term.term_tutorial_count,
                self.term.date_count,
                self.term.period_count,
            ),
            dtype=int)
        self.floated_tutorial_occupation = np.zeros(
            (
                self.term.term_student_count,
                self.term.term_teacher_count,
                self.term.term_tutorial_count,
                self.term.date_count,
                self.term.period_count,
            ),
            dtype=int)
        for tutorial_piece in self.term.tutorial_pieces:
            term_student_index = term_student_index(self.term.term_students, tutorial_piece['term_student_id'])
            term_teacher_index = term_teacher_index(self.term.term_teachers, tutorial_piece['term_teacher_id'])
            term_tutorial_index = term_tutorial_index(self.term.term_tutorials, tutorial_piece['term_tutorial_id'])
            date_index = date_index(tutorial_piece['date_index'])
            period_index = period_index(tutorial_piece['period_index'])
            is_fixed = tutorial_piece['is_fixed']
            if is_fixed:
                self.fixed_tutorial_occupation[term_student_index, term_teacher_index, term_tutorial_index, date_index, period_index] = 1
            else:
                self.floated_tutorial_occupation[term_student_index, term_teacher_index, term_tutorial_index, date_index, period_index] = 1
