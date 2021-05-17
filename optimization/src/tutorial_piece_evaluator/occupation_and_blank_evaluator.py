import itertools
import numpy
from ..cost_evaluator.occupation_and_blank_vector_evaluator \
    import OccupationAndBlankVectorEvaluator


class OccupationAndBlankEvaluator():
    def __init__(
            self,
            array_size,
            student_optimization_rules,
            teacher_optimization_rule,
            student_group_occupation,
            teacher_group_occupation,
            school_grades):
        self.__array_size = array_size
        self.__student_vector_evaluators = [OccupationAndBlankVectorEvaluator(
            period_count=array_size.period_count(),
            occupation_limit=student_optimization_rules[
                school_grade_index]['occupation_limit'],
            blank_limit=student_optimization_rules[
                school_grade_index]['blank_limit'],
            occupation_costs=student_optimization_rules[
                school_grade_index]['occupation_costs'],
            blank_costs=student_optimization_rules[
                school_grade_index]['blank_costs']
        ) for school_grade_index in range(array_size.school_grade_count())]
        self.__teacher_vector_evaluator = OccupationAndBlankVectorEvaluator(
            period_count=array_size.period_count(),
            occupation_limit=teacher_optimization_rule['occupation_limit'],
            blank_limit=teacher_optimization_rule['blank_limit'],
            occupation_costs=teacher_optimization_rule['occupation_costs'],
            blank_costs=teacher_optimization_rule['blank_costs']
        )
        self.__student_group_occupation = student_group_occupation
        self.__teacher_group_occupation = teacher_group_occupation
        self.__student_school_grade_codes = school_grades
        self.__school_grade_indexes = {
            11: 0,
            12: 1,
            13: 2,
            14: 3,
            15: 4,
            16: 5,
            21: 6,
            22: 7,
            23: 8,
            31: 9,
            32: 10,
            33: 11,
            99: 12}

    def __teacher_violation_and_cost(
            self, tutorial_occupation, violation_array, cost_array):
        teacher_tutorial_occupation = (numpy.einsum(
            'ijkml->jml', tutorial_occupation) > 0).astype(int)
        occupation = teacher_tutorial_occupation + self.__teacher_group_occupation
        term_teacher_list = range(self.__array_size.teacher_count())
        date_index_list = range(self.__array_size.date_count())
        product = itertools.product(term_teacher_list, date_index_list)
        for teacher_index, date_index in product:
            vector = occupation[teacher_index, date_index, :]
            [violation, cost] = \
                self.__teacher_vector_evaluator.violation_and_cost(vector)
            student_and_tutorial_period_index = numpy.array(numpy.where(
                tutorial_occupation[:, teacher_index, :, date_index, :])).transpose()
            for student_index, tutorial_index, period_index in student_and_tutorial_period_index:
                violation_array[student_index, teacher_index, tutorial_index, date_index, period_index] += violation
                cost_array[student_index, teacher_index, tutorial_index, date_index, period_index] += cost

    def __student_violation_and_cost(
            self, tutorial_occupation, violation_array, cost_array):
        student_tutorial_occupation = (numpy.einsum(
            'ikjml->iml', tutorial_occupation) > 0).astype(int)
        occupation = student_tutorial_occupation + self.__student_group_occupation
        term_student_list = range(self.__array_size.student_count())
        date_index_list = range(self.__array_size.date_count())
        product = itertools.product(term_student_list, date_index_list)
        for student_index, date_index in product:
            school_grade_code = self.__student_school_grade_codes[student_index]
            school_grade_index = self.__school_grade_indexes[school_grade_code]
            vector = occupation[student_index, date_index, :]
            [violation, cost] = self.__student_vector_evaluators[
                school_grade_index].violation_and_cost(vector)
            teacher_and_tutorial_period_index = numpy.array(numpy.where(
                tutorial_occupation[student_index, :, :, date_index, :])).transpose()
            for teacher_index, tutorial_index, period_index in teacher_and_tutorial_period_index:
                violation_array[student_index, teacher_index, tutorial_index, date_index, period_index] += violation
                cost_array[student_index, teacher_index, tutorial_index, date_index, period_index] += cost

    def get_violation_and_cost_array(self, tutorial_occupation, violation_array, cost_array):
        self.__teacher_violation_and_cost(tutorial_occupation, violation_array, cost_array)
        self.__student_violation_and_cost(tutorial_occupation, violation_array, cost_array)
