import multiprocessing
from .swapper_first_neighborhood_process import SwapperFirstNeighborhoodProcess
from logging import getLogger


logger = getLogger(__name__)

# 第１近傍の最適解取得クラス(対象のコマを、空いている時間枠に移動するパターン)


class SwapperFirstNeighborhood():
    def __init__(self, process_count, term_object,
                 array_builder, cost_evaluator):
        self.__process_count = process_count
        self.__term_object = term_object
        self.__array_builder = array_builder
        self.__cost_evaluator = cost_evaluator
        self.__tutorial_occupation_array = array_builder.tutorial_occupation_array()
        self.__best_answer = self.__initial_best_answer()

    def __initial_best_answer(self):
        return {
            'min_violation_and_cost': 1215752191,
            'student_index': None,
            'teacher_index': None,
            'tutorial_index': None,
            'date_index': None,
            'new_date_index': None,
            'period_index': None,
            'new_period_index': None,
        }

    def get_best_answer(
            self, student_index, teacher_index, tutorial_index, date_index, period_index):
        result_array = multiprocessing.Manager().list([])
        process = [
            multiprocessing.Process(
                target=SwapperFirstNeighborhoodProcess(
                    proc_num,
                    self.__process_count,
                    self.__array_builder,
                    self.__cost_evaluator,
                ).run,
                args=[result_array, student_index, teacher_index, tutorial_index, date_index, period_index])
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
            self.__best_answer['student_index'],
            self.__best_answer['teacher_index'],
            self.__best_answer['tutorial_index'],
            self.__best_answer['date_index'],
            self.__best_answer['period_index']] = 0
        self.__tutorial_occupation_array[
            self.__best_answer['student_index'],
            self.__best_answer['teacher_index'],
            self.__best_answer['tutorial_index'],
            self.__best_answer['new_date_index'],
            self.__best_answer['new_period_index']] = 1

    def logging(self, elapsed_sec, round_robin_order, swap_count):
        student_index = self.__best_answer['student_index']
        student_name = self.__term_object['term_students'][student_index]['name']
        student_school_grade = self.__term_object['term_students'][student_index]['school_grade']
        teacher_index = self.__best_answer['teacher_index']
        teacher_name = self.__term_object['term_teachers'][teacher_index]['name']
        tutorial_index = self.__best_answer['tutorial_index']
        tutorial_name = self.__term_object['term_tutorials'][tutorial_index]['name']
        date_index = self.__best_answer['date_index']
        new_date_index = self.__best_answer['new_date_index']
        period_index = self.__best_answer['period_index']
        new_period_index = self.__best_answer['new_period_index']
        [violation, cost] = self.__cost_evaluator.violation_and_cost(
            self.__tutorial_occupation_array)
        logger.info('================コマを移動しました================')
        logger.info(f'移動No：{swap_count}')
        logger.info(f'選択方式：ラウンドロビン シーケンス番号{round_robin_order}')
        logger.info(f'探索方式：第１近傍探索')
        logger.info(
            f'生徒/科目：{student_name}（{student_school_grade}）{tutorial_name}')
        logger.info(f'講師：{teacher_name}')
        logger.info(f'変更元日時：{date_index + 1}日目{period_index + 1}限')
        logger.info(f'変更先日時：{new_date_index + 1}日目{new_period_index + 1}限')
        logger.info(f'合計違反点数：{violation}')
        logger.info(f'合計コスト点数：{cost}')
        logger.info(f'経過時間：{elapsed_sec}秒')
        logger.info('==================================================')
