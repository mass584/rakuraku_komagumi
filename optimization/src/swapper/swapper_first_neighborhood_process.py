import itertools
import math
from logging import getLogger


logger = getLogger(__name__)

# 第１近傍の最適解取得クラス(対象のコマを、空いている時間枠に移動するパターン)


class SwapperFirstNeighborhoodProcess():
    def __init__(self, process_num, process_count, array_size, timetable_array,
                 tutorial_occupation_array, cost_evaluator):
        self.__process_num = process_num
        self.__process_count = process_count
        self.__array_size = array_size
        self.__cost_evaluator = cost_evaluator
        self.__timetable_array = timetable_array
        self.__tutorial_occupation_array = tutorial_occupation_array

    def __date_and_period_index(self):
        date_index_list = range(self.__array_size.date_count())
        period_index_list = range(self.__array_size.period_count())
        date_and_period_index_list = list(
            itertools.product(date_index_list, period_index_list))
        list_length = math.ceil(
            len(date_and_period_index_list) /
            self.__process_count)
        begin_index = self.__process_num * list_length
        end_index = (self.__process_num + 1) * list_length
        return date_and_period_index_list[begin_index:end_index]

    def run(self, result_array,
            student_index, teacher_index, tutorial_index, date_index, period_index):
        for new_date_index, new_period_index in self.__date_and_period_index():
            # 集団科目が配置済みか休講の所は探索しない
            if self.__timetable_array[new_date_index, new_period_index] == 0:
                continue
            # 同種のコマが配置済みの所は探索しない
            if self.__tutorial_occupation_array[
                    student_index, teacher_index, tutorial_index, new_date_index, new_period_index] == 1:
                continue
            # 配置を変更する
            self.__tutorial_occupation_array[
                student_index, teacher_index, tutorial_index, date_index, period_index] = 0
            self.__tutorial_occupation_array[
                student_index, teacher_index, tutorial_index, new_date_index, new_period_index] = 1
            # 違反+コストが最小値を下回れば、更新する
            violation_and_cost = self.__cost_evaluator.cost(
                self.__tutorial_occupation_array)
            result_array.append({
                'violation_and_cost': violation_and_cost,
                'student_index': student_index,
                'teacher_index': teacher_index,
                'tutorial_index': tutorial_index,
                'date_index': date_index,
                'new_date_index': new_date_index,
                'period_index': period_index,
                'new_period_index': new_period_index,
            })
            # 配置の変更を元に戻す
            self.__tutorial_occupation_array[
                student_index, teacher_index, tutorial_index, date_index, period_index] = 1
            self.__tutorial_occupation_array[
                student_index, teacher_index, tutorial_index, new_date_index, new_period_index] = 0
