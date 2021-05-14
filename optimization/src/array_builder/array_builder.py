from .array_size import ArraySize
from .group_occupation import GroupOccupation
from .school_grade import SchoolGrade
from .timetable import Timetable
from .tutorial_occupation import TutorialOccupation
from .tutorial_piece_count import TutorialPieceCount
from .vacancy import Vacancy


class ArrayBuilder():
    def __init__(self, term_object):
        self.__array_size = ArraySize(term_object)
        self.__group_occupation = GroupOccupation(
            term_object, self.__array_size)
        self.__school_grade = SchoolGrade(term_object, self.__array_size)
        self.__timetable = Timetable(term_object, self.__array_size)
        self.__tutorial_occupation = TutorialOccupation(
            term_object, self.__array_size)
        self.__tutorial_piece_count = TutorialPieceCount(
            term_object, self.__array_size)
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
