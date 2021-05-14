import numpy


class SchoolGrade():
    def __init__(self, term, array_size):
        self.__term = term
        self.__array_size = array_size
        self.__build_school_grade_array()

    def __build_school_grade_array(self):
        self.__school_grade_array = numpy.zeros(
            (self.__array_size.student_count()), dtype=int)
        for student_index in range(self.__array_size.student_count()):
            school_grade = \
                self.__term['term_students'][student_index]['school_grade']
            self.__school_grade_array[student_index] = school_grade

    def school_grade_array(self):
        return self.__school_grade_array
