import multiprocessing
import numpy
from .swapper_second_neighborhood_process import SwapperSecondNeighborhoodProcess
from logging import getLogger


logger = getLogger(__name__)

# 第２近傍の最適解取得クラス(対象のコマを、対になるコマと一緒に空いている時間枠に移動するパターン)


class SwapperSecondNeighborhood():
    def __init__(self, process_count, term_object, array_size, timetable_array,
                 tutorial_occupation_array, fixed_tutorial_occupation_array, cost_evaluator):
        self.__process_count = process_count
        self.__term_object = term_object
        self.__array_size = array_size
        self.__timetable_array = timetable_array
        self.__tutorial_occupation_array = tutorial_occupation_array
        self.__fixed_tutorial_occupation_array = fixed_tutorial_occupation_array
        self.__cost_evaluator = cost_evaluator
        self.__best_answer = self.__initial_best_answer()

    def __initial_best_answer(self):
        return {
            'violation_and_cost': 1215752191,
            'student_1_index': None,
            'student_2_index': None,
            'teacher_index': None,
            'tutorial_1_index': None,
            'tutorial_2_index': None,
            'date_index': None,
            'new_date_index': None,
            'period_index': None,
            'new_period_index': None,
        }

    def get_best_answer(
            self, student_index, teacher_index, tutorial_index, date_index, period_index):
        self.__best_answer = self.__initial_best_answer()
        # 対になるコマのインデックスを探す
        [pair_student_index, pair_tutorial_index] = next((
            [pair_student_index, pair_tutorial_index]
            for [pair_student_index, pair_tutorial_index]
            in numpy.array(numpy.where(self.__tutorial_occupation_array[
                :, teacher_index, :, date_index, period_index] == 1)).transpose()
            if not (pair_student_index == student_index and pair_tutorial_index == tutorial_index)), [None, None])
        # 対になるコマが存在しない場合は探索しない
        if pair_student_index is None or pair_tutorial_index is None:
            return self.__best_answer['violation_and_cost']
        # 対になるコマがロック中の場合は探索しない
        if self.__fixed_tutorial_occupation_array[
                pair_student_index, teacher_index, pair_tutorial_index, date_index, period_index]:
            return self.__best_answer['violation_and_cost']
        result_array = multiprocessing.Manager().list(
            [self.__initial_best_answer()])
        process = [
            multiprocessing.Process(
                target=SwapperSecondNeighborhoodProcess(
                    proc_num,
                    self.__process_count,
                    self.__array_size,
                    self.__timetable_array,
                    self.__tutorial_occupation_array,
                    self.__cost_evaluator,
                ).run,
                args=[result_array, student_index, teacher_index, tutorial_index,
                      date_index, period_index, pair_student_index, pair_tutorial_index])
            for proc_num in range(self.__process_count)]
        for proc_num in range(self.__process_count):
            process[proc_num].start()
        for proc_num in range(self.__process_count):
            process[proc_num].join()
        min_violation_and_cost = min(
            result['violation_and_cost'] for result in result_array)
        self.__best_answer = next(
            result for result in result_array
            if result['violation_and_cost'] == min_violation_and_cost)
        return min_violation_and_cost

    def execute(self):
        self.__tutorial_occupation_array[
            self.__best_answer['student_1_index'],
            self.__best_answer['teacher_index'],
            self.__best_answer['tutorial_1_index'],
            self.__best_answer['date_index'],
            self.__best_answer['period_index']] = 0
        self.__tutorial_occupation_array[
            self.__best_answer['student_2_index'],
            self.__best_answer['teacher_index'],
            self.__best_answer['tutorial_2_index'],
            self.__best_answer['date_index'],
            self.__best_answer['period_index']] = 0
        self.__tutorial_occupation_array[
            self.__best_answer['student_1_index'],
            self.__best_answer['teacher_index'],
            self.__best_answer['tutorial_1_index'],
            self.__best_answer['new_date_index'],
            self.__best_answer['new_period_index']] = 1
        self.__tutorial_occupation_array[
            self.__best_answer['student_2_index'],
            self.__best_answer['teacher_index'],
            self.__best_answer['tutorial_2_index'],
            self.__best_answer['new_date_index'],
            self.__best_answer['new_period_index']] = 1

    def logging(self, elapsed_sec, round_robin_order, swap_count):
        student_1_index = self.__best_answer['student_1_index']
        student_1_name = self.__term_object['term_students'][student_1_index]['name']
        student_1_school_grade = self.__term_object['term_students'][student_1_index]['school_grade']
        student_2_index = self.__best_answer['student_2_index']
        student_2_name = self.__term_object['term_students'][student_2_index]['name']
        student_2_school_grade = self.__term_object['term_students'][student_2_index]['school_grade']
        teacher_index = self.__best_answer['teacher_index']
        teacher_name = self.__term_object['term_teachers'][teacher_index]['name']
        tutorial_1_index = self.__best_answer['tutorial_1_index']
        tutorial_1_name = self.__term_object['term_tutorials'][tutorial_1_index]['name']
        tutorial_2_index = self.__best_answer['tutorial_2_index']
        tutorial_2_name = self.__term_object['term_tutorials'][tutorial_2_index]['name']
        date_index = self.__best_answer['date_index']
        new_date_index = self.__best_answer['new_date_index']
        period_index = self.__best_answer['period_index']
        new_period_index = self.__best_answer['new_period_index']
        [violation, cost] = self.__cost_evaluator.violation_and_cost(
            self.__tutorial_occupation_array)
        logger.info('================コマを移動しました================')
        logger.info(f'移動No：{swap_count}')
        logger.info(f'選択方式：ラウンドロビン シーケンス番号{round_robin_order}')
        logger.info(f'探索方式：第２近傍探索')
        logger.info(
            f'生徒/科目１：{student_1_name}（{student_1_school_grade}）{tutorial_1_name}')
        logger.info(
            f'生徒/科目２：{student_2_name}（{student_2_school_grade}）{tutorial_2_name}')
        logger.info(f'講師：{teacher_name}')
        logger.info(f'変更元日時：{date_index + 1}日目{period_index + 1}限')
        logger.info(f'変更先日時：{new_date_index + 1}日目{new_period_index + 1}限')
        logger.info(f'合計違反点数：{violation}')
        logger.info(f'合計コスト点数：{cost}')
        logger.info(f'経過時間：{elapsed_sec}秒')
        logger.info('==================================================')
