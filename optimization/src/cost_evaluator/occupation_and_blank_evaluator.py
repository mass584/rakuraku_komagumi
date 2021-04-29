import itertools
import numpy
from .occupation_and_blank_vector_evaluator import OccupationAndBlankVectorEvaluator


class OccupationAndBlankEvaluator():
    def __init__(self, array_size, student_optimization_rule,
                 teacher_optimization_rule):
        self.__array_size = array_size
        self.__student_vector_evaluator = OccupationAndBlankVectorEvaluator(
            period_count=array_size.period_count(),
            occupation_limit=student_optimization_rule['occupation_limit'],
            blank_limit=student_optimization_rule['blank_limit'],
            occupation_costs=student_optimization_rule['occupation_costs'],
            blank_costs=student_optimization_rule['blank_costs']
        )
        self.__teacher_vector_evaluator = OccupationAndBlankVectorEvaluator(
            period_count=array_size.period_count(),
            occupation_limit=teacher_optimization_rule['occupation_limit'],
            blank_limit=teacher_optimization_rule['blank_limit'],
            occupation_costs=teacher_optimization_rule['occupation_costs'],
            blank_costs=teacher_optimization_rule['blank_costs']
        )

    def __teacher_violation_and_cost(
            self, tutorial_occupation, teacher_group_occupation):
        teacher_tutorial_occupation = (numpy.einsum(
            'ijkml->jml', tutorial_occupation) > 0).astype(int)
        occupation = teacher_tutorial_occupation + teacher_group_occupation
        term_teacher_list = range(self.__array_size.teacher_count())
        date_index_list = range(self.__array_size.date_count())
        product = itertools.product(term_teacher_list, date_index_list)
        violation_summation = 0
        cost_summation = 0
        for teacher_index, date_index in product:
            vector = occupation[teacher_index, date_index, :]
            [violation, cost] = self.__teacher_vector_evaluator.violation_and_cost(
                vector)
            violation_summation += violation
            cost_summation += cost
        return [violation_summation, cost_summation]

    def __student_violation_and_cost(
            self, tutorial_occupation, student_group_occupation):
        student_tutorial_occupation = (numpy.einsum(
            'ikjml->iml', tutorial_occupation) > 0).astype(int)
        occupation = student_tutorial_occupation + student_group_occupation
        term_student_list = range(self.__array_size.student_count())
        date_index_list = range(self.__array_size.date_count())
        product = itertools.product(term_student_list, date_index_list)
        violation_summation = 0
        cost_summation = 0
        for student_index, date_index in product:
            vector = occupation[student_index, date_index, :]
            [violation, cost] = self.__student_vector_evaluator.violation_and_cost(
                vector)
            violation_summation += violation
            cost_summation += cost
        return [violation_summation, cost_summation]

    def violation_and_cost(self, tutorial_occupation,
                           teacher_group_occupation, student_group_occupation):
        teacher_violation_and_cost = self.__teacher_violation_and_cost(
            tutorial_occupation, teacher_group_occupation)
        student_violation_and_cost = self.__student_violation_and_cost(
            tutorial_occupation, student_group_occupation)
        return [teacher + student for teacher,
                student in zip(teacher_violation_and_cost, student_violation_and_cost)]
