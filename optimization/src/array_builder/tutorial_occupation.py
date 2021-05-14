import numpy


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
            tutorial_piece for tutorial_piece
            in self.__term['tutorial_pieces']
            if tutorial_piece['date_index'] is not None and
            tutorial_piece['period_index'] is not None
        ]
        for tutorial_piece in tutorial_pieces:
            student_index = self.__get_student_index(
                tutorial_piece['term_student_id'])
            teacher_index = self.__get_teacher_index(
                tutorial_piece['term_teacher_id'])
            tutorial_index = self.__get_tutorial_index(
                tutorial_piece['term_tutorial_id'])
            date_index = self.__get_date_index(
                tutorial_piece['date_index'])
            period_index = self.__get_period_index(
                tutorial_piece['period_index'])
            is_fixed = tutorial_piece['is_fixed']
            if is_fixed:
                self.__fixed_tutorial_occupation[
                    student_index,
                    teacher_index,
                    tutorial_index,
                    date_index,
                    period_index
                ] = 1
            if not is_fixed:
                self.__floated_tutorial_occupation[
                    student_index,
                    teacher_index,
                    tutorial_index,
                    date_index,
                    period_index
                ] = 1
            self.__tutorial_occupation[
                student_index,
                teacher_index,
                tutorial_index,
                date_index,
                period_index
            ] = 1

    def __get_student_index(self, term_student_id):
        term_student = next(
            term_student for term_student in self.__term['term_students']
            if term_student['id'] == term_student_id)
        return self.__term['term_students'].index(term_student)

    def __get_teacher_index(self, term_teacher_id):
        term_teacher = next(
            term_teacher for term_teacher in self.__term['term_teachers']
            if term_teacher['id'] == term_teacher_id)
        return self.__term['term_teachers'].index(term_teacher)

    def __get_tutorial_index(self, term_tutorial_id):
        term_tutorial = next(
            term_tutorial for term_tutorial in self.__term['term_tutorials']
            if term_tutorial['id'] == term_tutorial_id)
        return self.__term['term_tutorials'].index(term_tutorial)

    def __get_date_index(self, date_index):
        return date_index - 1

    def __get_period_index(self, period_index):
        return period_index - 1

    def fixed_tutorial_occupation_array(self):
        return self.__fixed_tutorial_occupation

    def floated_tutorial_occupation_array(self):
        return self.__floated_tutorial_occupation

    def tutorial_occupation_array(self):
        return self.__tutorial_occupation
