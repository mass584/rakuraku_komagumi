import itertools
import numpy
from array_builder.array_index import get_school_grade_index


class IntervalEvaluator():
    def __init__(self, array_size, student_optimization_rules, school_grades):
        self.__array_size = array_size
        self.__interval_cutoff_array = [
            student_optimization_rules[school_grade_index]['interval_cutoff']
            for school_grade_index
            in range(array_size.school_grade_count())]
        self.__interval_costs_array = [
            student_optimization_rules[school_grade_index]['interval_costs']
            for school_grade_index
            in range(array_size.school_grade_count())]
        self.__school_grades = school_grades

    def __each_interval_evaluator(self, array, school_grade):
        school_grade_index = get_school_grade_index(school_grade)
        date_index_list = range(self.__array_size.date_count())
        period_index_list = range(self.__array_size.period_count())
        date_and_period = itertools.product(date_index_list, period_index_list)
        cost = 0
        date_index_before = (-1) + (-self.__interval_cutoff_array[school_grade_index])
        for date_index, period_index in date_and_period:
            if array[date_index, period_index] > 0:
                diff = date_index - date_index_before
                if (diff <= self.__interval_cutoff_array[school_grade_index]):
                    cost += self.__interval_costs_array[school_grade_index][diff]
                date_index_before = date_index
        return cost

    def violation_and_cost(self, tutorial_pieces):
        array = numpy.einsum('ijkml->ikml', tutorial_pieces)
        student_index_list = range(self.__array_size.student_count())
        tutorial_index_list = range(self.__array_size.tutorial_count())
        student_and_tutorial = itertools.product(student_index_list, tutorial_index_list)
        cost = sum(
            self.__each_interval_evaluator(
                array[student_index, tutorial_index, :, :],
                self.__school_grades[student_index])
            for student_index, tutorial_index
            in student_and_tutorial)
        return [0, cost]
