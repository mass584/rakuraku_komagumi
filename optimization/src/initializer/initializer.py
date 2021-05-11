import numpy
from ..cost_evaluator.cost_evaluator import CostEvaluator

class Initializer():
    def __init__(
        self,
        array_size,
        student_optimization_rules,
        teacher_optimization_rule,
        student_group_occupation,
        teacher_group_occupation,
        student_vacancy,
        teacher_vacancy,
        school_grades,
        tutorial_occupation_array):
        self.__array_size = array_size
        self.__cost_evaluator = CostEvaluator(
            array_size=array_size,
            student_optimization_rules=student_optimization_rules,
            teacher_optimization_rule=teacher_optimization_rule,
            student_group_occupation=student_group_occupation,
            teacher_group_occupation=teacher_group_occupation,
            student_vacancy=student_vacancy,
            teacher_vacancy=teacher_vacancy,
            school_grades=school_grades)
        self.__tutorial_occupation_array = tutorial_occupation_array

    def __add_tutorial_piece(self, student_index, teacher_index, tutorial_index):
        date_index_list = range(self.__array_size.date_count())
        period_index_list = range(self.__array_size.period_count())
        violation_and_cost_array = numpy.full(
            (self.__array_size.date_count(), self.__array_size.period_count()),
            numpy.inf)
        for date_index in date_index_list:
            for period_index in period_index_list:
                is_tutorial_piece_occupied = self.__tutorial_occupation_array[
                    student_index,
                    teacher_index,
                    tutorial_index,
                    date_index,
                    period_index] == 0
                # TODO: 休講や集団のコマは初めから埋めないようにする
                if is_tutorial_piece_occupied:
                    self.__tutorial_occupation_array[
                        student_index,
                        teacher_index,
                        tutorial_index,
                        date_index,
                        period_index] = 1
                    violation_and_cost_array[date_index, period_index] = \
                        self.__cost_evaluator.violation_and_cost(
                            self.__tutorial_occupation_array)
                    self.__tutorial_occupation_array[
                        student_index,
                        teacher_index,
                        tutorial_index,
                        date_index,
                        period_index] = 0
        [date_index, period_index] = numpy.unravel_index(
            violation_and_cost_array.argmin(),
            violation_and_cost_array.shape)
        self.__tutorial_occupation_array[
            student_index,
            teacher_index,
            tutorial_index,
            date_index,
            period_index] = 1

    def getNewSchedule(self):
        student_index_list = range(self.__array_size.student_count())
        teacher_index_list = range(self.__array_size.teacher_count())
        tutorial_index_list = range(self.__array_size.tutorial_count())
        loop = 1
        while loop:
            loop = 0
            for student_index in student_index_list:
                for teacher_index in teacher_index_list:
                    for tutorial_index in tutorial_index_list:
                        if self.__tutorial_contracts[student_index, teacher_index, tutorial_index] > 0:
                            self.__add_tutorial_piece(student_index, teacher_index, tutorial_index)
                            loop = 1
