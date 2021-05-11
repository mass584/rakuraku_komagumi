from .array_size import ArraySize
from .group_occupation import GroupOccupation
from .school_grade import SchoolGrade
from .timetable import Timetable
from .tutorial_occupation import TutorialOccupation
from .tutorial_piece_count import TutorialPieceCount
from .vacancy import Vacancy

class ArrayBuilder():
    def __init__(self, term_object):
        self.__term_object = term_object
        self.__array_size = ArraySize(term_object)
        self.__group_occupation = GroupOccupation(term_object, self.__array_size)
        self.__school_grade = SchoolGrade(term_object, self.__array_size)
        self.__timetable = Timetable(term_object, self.__array_size)
        self.__tutorial_occupation = TutorialOccupation(term_object, self.__array_size)
        self.__tutorial_piece_count = TutorialPieceCount(term_object, self.__array_size)
        self.__vacancy = Vacancy(term_object, self.__array_size)

    def array_size(self):
        return self.__array_size

    def student_group_occupation_array(self):
        return self.__group_occupation.student_occupation_array()

    def teacher_group_occupation_array(self):
        return self.__group_occupation.teacher_occupation_array()

    def school_grade_array(self):
        return self.__school_grade.school_grade_array()

    def timetable_array(self):
        return self.__timetable.timetable_array()

    def tutorial_occupation_array(self):
        return self.__tutorial_occupation.tutorial_occupation_array()

    def tutorial_piece_count_array(self):
        return self.__tutorial_piece_count.tutorial_piece_count_array()

    def student_vacancy_array(self):
        return self.__vacancy.student_vacancy_array()

    def teacher_vacancy_array(self):
        return self.__vacancy.teacher_vacancy_array()

    def get_student_index(self, term_student_id):
        term_student = next(
            term_student for term_student in self.__term_object['term_students']
            if term_student['id'] == term_student_id)
        return self.__term_object['term_students'].index(term_student)

    def get_teacher_index(self, term_teacher_id):
        term_teacher = next(
            term_teacher for term_teacher in self.__term_teachers
            if term_teacher['id'] == term_teacher_id)
        return self.__term_object['term_teachers'].index(term_teacher)

    def get_tutorial_index(self, term_tutorial_id):
        term_tutorial = next(
            term_tutorial for term_tutorial in self.__term_tutorials
            if term_tutorial['id'] == term_tutorial_id)
        return self.__term_object['term_tutorials'].index(term_tutorial)

    def get_group_index(self, term_group_id):
        term_group = next(
            term_group for term_group in self.__term_groups
            if term_group['id'] == term_group_id)
        return self.__term_object['term_groups'].index(term_group)

    def get_date_index(self, date_index):
        return date_index - 1

    def get_period_index(self, period_index):
        return period_index - 1

    def get_school_grade_index(self, school_grade):
        school_grades = [11, 12, 13, 14, 15, 16, 21, 22, 23, 31, 32, 33, 99]
        return school_grades.index(school_grade)
