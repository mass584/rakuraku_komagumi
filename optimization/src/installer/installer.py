import itertools
import numpy
from cost_evaluator.cost_evaluator import CostEvaluator

class Installer():
    def __init__(self, array_builder, student_optimization_rules, teacher_optimization_rule):
        self.__array_size = array_builder.array_size()
        self.__uninstalled_tutorial_piece_count = \
            self.__get_uninstalled_tutorial_piece_count(
                tutorial_piece_count=array_builder.tutorial_piece_count_array(),
                tutorial_occupation_array=array_builder.tutorial_occupation_array())
        self.__cost_evaluator = CostEvaluator(
            array_size=array_builder.array_size(),
            timetable=array_builder.timetable_array(),
            student_optimization_rules=student_optimization_rules,
            teacher_optimization_rule=teacher_optimization_rule,
            student_group_occupation=array_builder.student_group_occupation_array(),
            teacher_group_occupation=array_builder.teacher_group_occupation_array(),
            student_vacancy=array_builder.student_vacancy_array(),
            teacher_vacancy=array_builder.teacher_vacancy_array(),
            school_grades=array_builder.school_grade_array())
        self.__tutorial_occupation_array = array_builder.tutorial_occupation_array()

    def __get_uninstalled_tutorial_piece_count(self, tutorial_piece_count, tutorial_occupation_array):
        installed_tutorial_piece_count = numpy.einsum('ijkml->ijk', tutorial_occupation_array)
        return tutorial_piece_count - installed_tutorial_piece_count

    def __add_tutorial_piece(self, student_index, teacher_index, tutorial_index):
        date_index_list = range(self.__array_size.date_count())
        period_index_list = range(self.__array_size.period_count())
        product = itertools.product(date_index_list, period_index_list)
        cost_array = numpy.full(
            (self.__array_size.date_count(), self.__array_size.period_count()),
            numpy.inf)
        for date_index, period_index in product:
            is_tutorial_piece_occupied = self.__tutorial_occupation_array[
                student_index,
                teacher_index,
                tutorial_index,
                date_index,
                period_index] == 1
            if is_tutorial_piece_occupied:
                self.__tutorial_occupation_array[
                    student_index,
                    teacher_index,
                    tutorial_index,
                    date_index,
                    period_index] = 1
                cost_array[date_index, period_index] = self.__cost_evaluator.cost(
                    self.__tutorial_occupation_array)
                self.__tutorial_occupation_array[
                    student_index,
                    teacher_index,
                    tutorial_index,
                    date_index,
                    period_index] = 0
        [date_index, period_index] = numpy.unravel_index(
            cost_array.argmin(),
            cost_array.shape)
        self.__tutorial_occupation_array[
            student_index,
            teacher_index,
            tutorial_index,
            date_index,
            period_index] = 1

    def __execute_single_loop(self, product):
        for tutorial_index, student_index, teacher_index in product:
            is_uninstalled = self.__uninstalled_tutorial_piece_count[
                student_index, teacher_index, tutorial_index] > 0
            if is_uninstalled:
                self.__add_tutorial_piece(
                    student_index, teacher_index, tutorial_index)
                self.__uninstalled_tutorial_piece_count[
                    student_index, teacher_index, tutorial_index] -= 1

    def execute(self):
        student_index_list = range(self.__array_size.student_count())
        teacher_index_list = range(self.__array_size.teacher_count())
        tutorial_index_list = range(self.__array_size.tutorial_count())
        # 公平になるように生徒インデックスのループを先に回す
        product = itertools.product(
            tutorial_index_list, student_index_list, teacher_index_list)
        max_tutorial_piece_count = numpy.amax(self.__uninstalled_tutorial_piece_count)
        for _ in range(max_tutorial_piece_count): self.__execute_single_loop(product)
