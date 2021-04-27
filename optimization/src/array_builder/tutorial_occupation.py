import itertools
from array_index import term_student_index, term_teacher_index, term_tutorial_index, date_index, period_index

class TutorialOccupation():
    def __init__(self, term, array_size):
        self.term = term
        self.array_size = array_size
        self.__build_tutorial_occupation

    def __build_tutorial_occupation(self):
        self.fixed_tutorial_occupation = np.zeros(
            (
                self.array_size.student_count,
                self.array_size.teacher_count,
                self.array_size.tutorial_count,
                self.array_size.date_count,
                self.array_size.period_count,
            ),
            dtype=int)
        self.floated_tutorial_occupation = np.zeros(
            (
                self.array_size.student_count,
                self.array_size.teacher_count,
                self.array_size.tutorial_count,
                self.array_size.date_count,
                self.array_size.period_count,
            ),
            dtype=int)
        for tutorial_piece in self.term.tutorial_pieces:
            student_index = student_index(self.term.term_students, tutorial_piece['term_student_id'])
            teacher_index = teacher_index(self.term.term_teachers, tutorial_piece['term_teacher_id'])
            tutorial_index = tutorial_index(self.term.term_tutorials, tutorial_piece['term_tutorial_id'])
            date_index = date_index(tutorial_piece['date_index'])
            period_index = period_index(tutorial_piece['period_index'])
            is_fixed = tutorial_piece['is_fixed']
            if is_fixed:
                self.fixed_tutorial_occupation[student_index, teacher_index, tutorial_index, date_index, period_index] = 1
            else:
                self.floated_tutorial_occupation[student_index, teacher_index, tutorial_index, date_index, period_index] = 1
