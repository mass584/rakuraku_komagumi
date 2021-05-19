import itertools
import math
import numpy
from logging import getLogger


logger = getLogger(__name__)

# 第３近傍の最適解取得クラス(対象のコマを、他の時間枠のコマと入れ替えるパターン)


class SwapperThirdNeighborhoodProcess():
    def __init__(self, process_num, process_count,
                 array_builder, cost_evaluator):
        self.__process_num = process_num
        self.__process_count = process_count
        self.__array_size = array_builder.array_size()
        self.__cost_evaluator = cost_evaluator
        self.__timetable_array = array_builder.timetable_array()
        self.__tutorial_occupation_array = array_builder.tutorial_occupation_array()
        self.__fixed_tutorial_occupation_array = array_builder.fixed_tutorial_occupation_array()

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
                    student_index, teacher_index, tutorial_index,
                    new_date_index, new_period_index] == 1:
                continue
            # 入れ替える相手となるコマのインデックスを探す
            pair_student_and_tutorial_index_list = [
                [pair_student_index, pair_tutorial_index]
                for [pair_student_index, pair_tutorial_index]
                in numpy.array(numpy.where(self.__tutorial_occupation_array[
                    :, teacher_index, :, new_date_index, new_period_index] == 1)).transpose()
                if not (pair_student_index == student_index and pair_tutorial_index == tutorial_index)]
            for pair_student_index, pair_tutorial_index in pair_student_and_tutorial_index_list:
                # 入れ替える相手となるコマがロック中の場合は探索しない
                if self.__fixed_tutorial_occupation_array[
                        pair_student_index, teacher_index, pair_tutorial_index,
                        date_index, period_index] == 1:
                    continue
                # 入れ替える相手のコマと同種のコマが、入れ替える元のコマの日時にすでに割り当て済みの場合は探索しない
                if self.__tutorial_occupation_array[
                        pair_student_index, teacher_index, pair_tutorial_index,
                        date_index, period_index] == 1:
                    continue
                # 入れ替える元のコマと同種のコマが、入れ替える相手のコマの日時にすでに割り当て済みの場合は探索しない
                if self.__tutorial_occupation_array[
                        student_index, teacher_index, tutorial_index,
                        new_date_index, new_period_index] == 1:
                    continue
                # 配置を変更する
                self.__tutorial_occupation_array[
                    student_index, teacher_index, tutorial_index,
                    date_index, period_index] = 0
                self.__tutorial_occupation_array[
                    pair_student_index, teacher_index, pair_tutorial_index,
                    new_date_index, new_period_index] = 0
                self.__tutorial_occupation_array[
                    pair_student_index, teacher_index, pair_tutorial_index,
                    date_index, period_index] = 1
                self.__tutorial_occupation_array[
                    student_index, teacher_index, tutorial_index,
                    new_date_index, new_period_index] = 1
                # 違反+コストが最小値を下回れば、更新する
                violation_and_cost = self.__cost_evaluator.cost(
                    self.__tutorial_occupation_array)
                result_array.append({
                    'violation_and_cost': violation_and_cost,
                    'student_1_index': student_index,
                    'student_2_index': pair_student_index,
                    'teacher_index': teacher_index,
                    'tutorial_1_index': tutorial_index,
                    'tutorial_2_index': pair_tutorial_index,
                    'date_index': date_index,
                    'new_date_index': new_date_index,
                    'period_index': period_index,
                    'new_period_index': new_period_index,
                })
                # 配置の変更を元に戻す
                self.__tutorial_occupation_array[
                    student_index, teacher_index, tutorial_index,
                    date_index, period_index] = 1
                self.__tutorial_occupation_array[
                    pair_student_index, teacher_index, pair_tutorial_index,
                    new_date_index, new_period_index] = 1
                self.__tutorial_occupation_array[
                    pair_student_index, teacher_index, pair_tutorial_index,
                    date_index, period_index] = 0
                self.__tutorial_occupation_array[
                    student_index, teacher_index, tutorial_index,
                    new_date_index, new_period_index] = 0
