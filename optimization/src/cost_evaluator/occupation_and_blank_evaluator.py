import itertools
import numpy as np
from occupation_and_blank_vector_evaluator import OccupationAndBlankVectorEvaluator

class OccupationAndBlankEvaluator():
    def __init__(array_size, student_optimization_rule, teacher_optimization_rule):
        self.array_size = array_size
        self.student_vector_evaluator = OccupationAndBlankVectorEvaluator(
            period_count=array_size.period_count,
            occupation_limit=student_optimization_rule['occupation_limit'],
            blank_limit=student_optimization_rule['blank_limit'],
            occupation_costs=student_optimization_rule['occupation_costs'],
            blank_costs=student_optimization_rule['blank_costs']
        )
        self.teacher_vector_evaluator = OccupationAndBlankVectorEvaluator(
            period_count=array_size.period_count,
            occupation_limit=teacher_optimization_rule['occupation_limit'],
            blank_limit=teacher_optimization_rule['blank_limit'],
            occupation_costs=teacher_optimization_rule['occupation_costs'],
            blank_costs=teacher_optimization_rule['blank_costs']
        )

    def teacher_evaluation(self, tutorial_occupation, teacher_group_occupation):
        teacher_tutorial_occupation = (np.einsum('ijkml->jml', tutorial_occupation) > 0).astype(np.int)
        occupation = teacher_tutorial_occupation + teacher_group_occupation
        term_teacher_list = range(self.array_size.teacher_count)
        date_index_list = range(self.array_size.date_count)
        product = itertools.product(term_teacher_list, date_index_list)
        for teacher_index, date_index in product:
            vector = occupation[teacher_index, date_index, :]
            [violation, cost] = self.teacher_vector_evaluator(vector)
            violation_summation += violation
            cost_summation += cost
        return [violation_summation, cost_summation]

    def student_evaluation(self, tutorial_occupation, student_group_occupation):
        student_tutorial_occupation = (np.einsum('ikjml->iml', tutorial_occupation) > 0).astype(np.int)
        occupation = student_tutorial_occupation + student_group_occupation
        term_student_list = range(self.array_size.student_count)
        date_index_list = range(self.array_size.date_count)
        product = itertools.product(term_student_list, date_index_list)
        for student_index, date_index in product:
            vector = occupation[student_index, date_index, :]
            [violation, cost] = self.student_vector_evaluator(vector)
            violation_summation += violation
            cost_summation += cost
        return [violation_summation, cost_summation]
