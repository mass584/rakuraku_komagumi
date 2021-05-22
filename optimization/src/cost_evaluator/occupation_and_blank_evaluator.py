import itertools
import numpy
from .occupation_and_blank_vector_evaluator \
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
            [violation, cost] = \
                self.__teacher_vector_evaluator.violation_and_cost(vector)
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
            school_grade_code = self.__student_school_grade_codes[student_index]
            school_grade_index = self.__school_grade_indexes[school_grade_code]
            vector = occupation[student_index, date_index, :]
            [violation, cost] = self.__student_vector_evaluators[
                school_grade_index].violation_and_cost(vector)
            violation_summation += violation
            cost_summation += cost
        return [violation_summation, cost_summation]

    def violation_and_cost(self, tutorial_occupation):
        teacher_violation_and_cost = self.__teacher_violation_and_cost(
            tutorial_occupation, self.__teacher_group_occupation)
        student_violation_and_cost = self.__student_violation_and_cost(
            tutorial_occupation, self.__student_group_occupation)
        return [teacher + student for teacher,
                student in zip(
                    teacher_violation_and_cost,
                    student_violation_and_cost)]
