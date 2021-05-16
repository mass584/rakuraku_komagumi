import itertools
import math
import multiprocessing
import numpy
import os
import time
from cost_evaluator.cost_evaluator import CostEvaluator
from logging import getLogger


logger = getLogger(__name__)


class InstallerProcess():
    def __init__(self, process_num, process_count, array_size, cost_evaluator, tutorial_occupation_array, timetable_array):
        self.__process_num = process_num
        self.__process_count = process_count
        self.__array_size = array_size
        self.__cost_evaluator = cost_evaluator
        self.__timetable_array = timetable_array
        self.__tutorial_occupation_array = tutorial_occupation_array

    def __search_guard(self, student_index, teacher_index,
                       tutorial_index, date_index, period_index):
        # 個別科目が配置済みの所は探索しない
        if self.__tutorial_occupation_array[
                student_index, teacher_index, tutorial_index, date_index, period_index] == 1:
            return True
        # 集団科目が配置済みか休講の所は探索しない
        if self.__timetable_array[date_index, period_index] == 0:
            return True

    def __date_and_period_index(self):
        date_index_list = range(self.__array_size.date_count())
        period_index_list = range(self.__array_size.period_count())
        date_and_period_index_list = list(
            itertools.product(date_index_list, period_index_list))
        list_length = math.ceil(len(date_and_period_index_list) / self.__process_count)
        begin_index = self.__process_num * list_length
        end_index = (self.__process_num  + 1) * list_length
        return date_and_period_index_list[begin_index:end_index]

    def run(self, cost_array, student_index, teacher_index, tutorial_index):
        logger.debug(f"プロセス開始：PID{os.getpid()}")
        for date_index, period_index in self.__date_and_period_index():
            if self.__search_guard(
                    student_index,
                    teacher_index,
                    tutorial_index,
                    date_index,
                    period_index): continue
            self.__tutorial_occupation_array[
                student_index,
                teacher_index,
                tutorial_index,
                date_index,
                period_index] += 1
            cost = self.__cost_evaluator.cost(self.__tutorial_occupation_array)
            self.__tutorial_occupation_array[
                student_index,
                teacher_index,
                tutorial_index,
                date_index,
                period_index] -= 1
            cost_array[date_index * self.__array_size.period_count() + period_index] = cost
        logger.debug(f"プロセス終了：PID{os.getpid()}")
