import itertools
import numpy


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
        self.__student_school_grade_codes = school_grades
        self.__school_grade_indexes = {
            'e1': 0,
            'e2': 1,
            'e3': 2,
            'e4': 3,
            'e5': 4,
            'e6': 5,
            'j1': 6,
            'j2': 7,
            'j3': 8,
            'h1': 9,
            'h2': 10,
            'h3': 11,
            'other': 12}

    def __each_interval_evaluator(
            self, date_and_period_array, school_grade_code):
        date_and_period_index_array = numpy.where(date_and_period_array > 0)
        date_index_array = date_and_period_index_array[0]
        school_grade_index = self.__school_grade_indexes[school_grade_code]
        date_index_before = (-1) + \
            (-self.__interval_cutoff_array[school_grade_index])
        cost = 0
        for date_index in date_index_array:
            diff = date_index - date_index_before
            if (diff <= self.__interval_cutoff_array[school_grade_index]):
                cost += self.__interval_costs_array[school_grade_index][diff]
            date_index_before = date_index
        return cost

    def violation_and_cost(self, tutorial_pieces):
        array = numpy.einsum('ijkml->ikml', tutorial_pieces)
        student_index_list = range(self.__array_size.student_count())
        tutorial_index_list = range(self.__array_size.tutorial_count())
        student_and_tutorial = itertools.product(
            student_index_list, tutorial_index_list)
        cost = sum(
            self.__each_interval_evaluator(
                array[student_index, tutorial_index, :, :],
                self.__student_school_grade_codes[student_index])
            for student_index, tutorial_index
            in student_and_tutorial)
        return [0, cost]
