import itertools
import math
import numpy
import time
from cost_evaluator.cost_evaluator import CostEvaluator
from tutorial_piece_evaluator.tutorial_piece_evaluator import TutorialPieceEvaluator
from logging import getLogger


logger = getLogger(__name__)


class Swapper():
    def __init__(self, term_object, array_builder,
                 student_optimization_rules, teacher_optimization_rule):
        self.__term_object = term_object
        self.__array_size = array_builder.array_size()
        self.__cost_evaluator = CostEvaluator(
            array_size=array_builder.array_size(),
            student_optimization_rules=student_optimization_rules,
            teacher_optimization_rule=teacher_optimization_rule,
            student_group_occupation=array_builder.student_group_occupation_array(),
            teacher_group_occupation=array_builder.teacher_group_occupation_array(),
            student_vacancy=array_builder.student_vacancy_array(),
            teacher_vacancy=array_builder.teacher_vacancy_array(),
            school_grades=array_builder.school_grade_array())
        self.__tutorial_piece_evaluator = TutorialPieceEvaluator(
            array_size=array_builder.array_size(),
            student_optimization_rules=student_optimization_rules,
            teacher_optimization_rule=teacher_optimization_rule,
            student_group_occupation=array_builder.student_group_occupation_array(),
            teacher_group_occupation=array_builder.teacher_group_occupation_array(),
            student_vacancy=array_builder.student_vacancy_array(),
            teacher_vacancy=array_builder.teacher_vacancy_array(),
            school_grades=array_builder.school_grade_array())
        self.__timetable_array = array_builder.timetable_array()
        self.__tutorial_occupation_array = array_builder.tutorial_occupation_array()
        self.__fixed_tutorial_occupation_array = array_builder.fixed_tutorial_occupation_array()
        self.__round_robin_order_before = 0
        self.__total_tutorial_piece_count = numpy.sum(
            array_builder.tutorial_piece_count_array())
        self.__reset_best_nth_neighborhood()

    def __reset_best_nth_neighborhood(self):
        self.__best_first_neighborhood = self.__initial_best_first_neighborhood()
        self.__best_second_neighborhood = self.__initial_best_second_neighborhood()
        self.__best_third_neighborhood = self.__initial_best_third_neighborhood()

    def __initial_best_first_neighborhood(self):
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

    def __initial_best_second_neighborhood(self):
        return {
            'min_violation_and_cost': 1215752191,
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

    def __initial_best_third_neighborhood(self):
        return {
            'min_violation_and_cost': 1215752191,
            'student1_index': None,
            'student2_index': None,
            'teacher_index': None,
            'tutorial1_index': None,
            'tutorial2_index': None,
            'date_index': None,
            'new_date_index': None,
            'period_index': None,
            'new_period_index': None
        }

    # 第１近傍の最適解取得(対象のコマを、空いている時間枠に移動するパターン)
    def __get_best_first_neighborhood(
        self, student_index, teacher_index, tutorial_index, date_index, period_index):
        # 日付と時限の探索
        date_index_list = range(self.__array_size.date_count())
        period_index_list = range(self.__array_size.period_count())
        date_and_period_index_list = list(
            itertools.product(date_index_list, period_index_list))
        for new_date_index, new_period_index in date_and_period_index_list:
            # 集団科目が配置済みか休講の所は探索しない
            if self.__timetable_array[new_date_index, new_period_index] == 0: continue
            # 同種のコマが配置済みの所は探索しない
            if self.__tutorial_occupation_array[
                student_index, teacher_index, tutorial_index, new_date_index, new_period_index] == 1: continue
            # 配置を変更する
            self.__tutorial_occupation_array[
                student_index, teacher_index, tutorial_index, date_index, period_index] = 0
            self.__tutorial_occupation_array[
                student_index, teacher_index, tutorial_index, new_date_index, new_period_index] = 1
            # 違反+コストが最小値を下回れば、更新する
            violation_and_cost = self.__cost_evaluator.cost(self.__tutorial_occupation_array)
            if violation_and_cost < self.__best_first_neighborhood['min_violation_and_cost']:
                self.__best_first_neighborhood = {
                    'violation_and_cost': violation_and_cost,
                    'student_index': student_index,
                    'teacher_index': teacher_index,
                    'tutorial_index': tutorial_index,
                    'date_index': date_index,
                    'new_date_index': new_date_index,
                    'period_index': period_index,
                    'new_period_index': new_period_index,
                }
            # 配置の変更を元に戻す
            self.__tutorial_occupation_array[
                student_index, teacher_index, tutorial_index, date_index, period_index] = 1
            self.__tutorial_occupation_array[
                student_index, teacher_index, tutorial_index, new_date_index, new_period_index] = 0

    # 第２近傍の最適解取得(対象のコマを、対になるコマと一緒に空いている時間枠に移動するパターン)
    def __get_best_second_neighborhood(
        self, student_index, teacher_index, tutorial_index, date_index, period_index):
        # 対になるコマのインデックスを探す
        [pair_student_index, pair_tutorial_index] = next((
            [pair_student_index, pair_tutorial_index]
            for [pair_student_index, pair_tutorial_index]
            in numpy.array(numpy.where(self.__tutorial_occupation_array[
                :, teacher_index, :, date_index, period_index] == 1)).transpose()
            if not (pair_student_index == student_index and pair_tutorial_index == tutorial_index)), [None, None])
        # 対になるコマが存在しない場合は探索しない
        if pair_student_index == None or pair_tutorial_index == None: return
        # 対になるコマがロック中の場合は探索しない
        if self.__fixed_tutorial_occupation_array[
            pair_student_index, teacher_index, pair_tutorial_index, date_index, period_index]: return
        # 日付と時限の探索
        date_index_list = range(self.__array_size.date_count())
        period_index_list = range(self.__array_size.period_count())
        date_and_period_index_list = list(
            itertools.product(date_index_list, period_index_list))
        for new_date_index, new_period_index in date_and_period_index_list:
            # 集団科目が配置済みか休講の所は探索しない
            if self.__timetable_array[new_date_index, new_period_index] == 0: continue
            # 同種のコマが配置済みの所は探索しない
            if self.__tutorial_occupation_array[
                student_index, teacher_index, tutorial_index, new_date_index, new_period_index] == 1: continue
            if self.__tutorial_occupation_array[
                pair_student_index, teacher_index, pair_tutorial_index, new_date_index, new_period_index] == 1: continue
            # 配置を変更する
            self.__tutorial_occupation_array[
                student_index, teacher_index, tutorial_index, date_index, period_index] = 0
            self.__tutorial_occupation_array[
                pair_student_index, teacher_index, pair_tutorial_index, date_index, period_index] = 0
            self.__tutorial_occupation_array[
                student_index, teacher_index, tutorial_index, new_date_index, new_period_index] = 1
            self.__tutorial_occupation_array[
                pair_student_index, teacher_index, pair_tutorial_index, new_date_index, new_period_index] = 1
            # 違反+コストが最小値を下回れば、更新する
            violation_and_cost = self.__cost_evaluator.cost(self.__tutorial_occupation_array)
            if violation_and_cost < self.__best_second_neighborhood['min_violation_and_cost']:
                self.__best_second_neighborhood = {
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
                }
            # 配置の変更を元に戻す
            self.__tutorial_occupation_array[
                student_index, teacher_index, tutorial_index, date_index, period_index] = 1
            self.__tutorial_occupation_array[
                pair_student_index, teacher_index, pair_tutorial_index, date_index, period_index] = 1
            self.__tutorial_occupation_array[
                student_index, teacher_index, tutorial_index, new_date_index, new_period_index] = 0
            self.__tutorial_occupation_array[
                pair_student_index, teacher_index, pair_tutorial_index, new_date_index, new_period_index] = 0

    # 第３近傍の最適解取得(対象のコマを、他の時間枠のコマと入れ替えるパターン)
    def __get_best_third_neighborhood(
        self, student_index, teacher_index, tutorial_index, date_index, period_index):
        # 日付と時限の探索
        date_index_list = range(self.__array_size.date_count())
        period_index_list = range(self.__array_size.period_count())
        date_and_period_index_list = list(
            itertools.product(date_index_list, period_index_list))
        for new_date_index, new_period_index in date_and_period_index_list:
            # 入れ替える相手となるコマのインデックスを探す
            pair_student_and_tutorial_index_list = [
                [pair_student_index, pair_tutorial_index]
                for [pair_student_index, pair_tutorial_index]
                in numpy.array(numpy.where(self.__tutorial_occupation_array[
                    :, teacher_index, :, new_date_index, new_period_index] == 1)).transpose()
                if not (pair_student_index == student_index and pair_tutorial_index == tutorial_index)]
            # 集団科目が配置済みか休講の所は探索しない
            if self.__timetable_array[new_date_index, new_period_index] == 0: continue
            # 同種のコマが配置済みの所は探索しない
            if self.__tutorial_occupation_array[
                student_index, teacher_index, tutorial_index, new_date_index, new_period_index] == 1: continue
            for pair_student_index, pair_tutorial_index in pair_student_and_tutorial_index_list:
                # 入れ替える相手となるコマがロック中の場合は探索しない
                if self.__fixed_tutorial_occupation_array[
                    pair_student_index, teacher_index, pair_tutorial_index, date_index, period_index] == 1: continue
                # 入れ替える相手のコマと同種のコマが、入れ替える元のコマの日時にすでに割り当て済みの場合は探索しない
                if self.__tutorial_occupation_array[
                    pair_student_index, teacher_index, pair_tutorial_index, date_index, period_index] == 1: continue
                # 入れ替える元のコマと同種のコマが、入れ替える相手のコマの日時にすでに割り当て済みの場合は探索しない
                if self.__tutorial_occupation_array[
                    student_index, teacher_index, tutorial_index, new_date_index, new_period_index] == 1: continue
                # 配置を変更する
                self.__tutorial_occupation_array[
                    student_index, teacher_index, tutorial_index, date_index, period_index] = 0
                self.__tutorial_occupation_array[
                    pair_student_index, teacher_index, pair_tutorial_index, new_date_index, new_period_index] = 0
                self.__tutorial_occupation_array[
                    pair_student_index, teacher_index, pair_tutorial_index, date_index, period_index] = 1
                self.__tutorial_occupation_array[
                    student_index, teacher_index, tutorial_index, new_date_index, new_period_index] = 1
                # 違反+コストが最小値を下回れば、更新する
                violation_and_cost = self.__cost_evaluator.cost(self.__tutorial_occupation_array)
                if violation_and_cost < self.__best_third_neighborhood['min_violation_and_cost']:
                    self.__best_third_neighborhood = {
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
                    }
                # 配置の変更を元に戻す
                self.__tutorial_occupation_array[
                    student_index, teacher_index, tutorial_index, date_index, period_index] = 1
                self.__tutorial_occupation_array[
                    pair_student_index, teacher_index, pair_tutorial_index, new_date_index, new_period_index] = 1
                self.__tutorial_occupation_array[
                    pair_student_index, teacher_index, pair_tutorial_index, date_index, period_index] = 0
                self.__tutorial_occupation_array[
                    student_index, teacher_index, tutorial_index, new_date_index, new_period_index] = 0

    def __improve_one_time_by_first_neighborhoods(self):
        self.__tutorial_occupation_array[
            self.__best_first_neighborhood['student_index'],
            self.__best_first_neighborhood['teacher_index'],
            self.__best_first_neighborhood['tutorial_index'],
            self.__best_first_neighborhood['date_index'],
            self.__best_first_neighborhood['period_index']] = 0
        self.__tutorial_occupation_array[
            self.__best_first_neighborhood['student_index'],
            self.__best_first_neighborhood['teacher_index'],
            self.__best_first_neighborhood['tutorial_index'],
            self.__best_first_neighborhood['new_date_index'],
            self.__best_first_neighborhood['new_period_index']] = 1

    def __improve_one_time_by_second_neighborhoods(self):
        self.__tutorial_occupation_array[
            self.__best_first_neighborhood['student_1_index'],
            self.__best_first_neighborhood['teacher_index'],
            self.__best_first_neighborhood['tutorial_1_index'],
            self.__best_first_neighborhood['date_index'],
            self.__best_first_neighborhood['period_index']] = 0
        self.__tutorial_occupation_array[
            self.__best_first_neighborhood['student_2_index'],
            self.__best_first_neighborhood['teacher_index'],
            self.__best_first_neighborhood['tutorial_2_index'],
            self.__best_first_neighborhood['date_index'],
            self.__best_first_neighborhood['period_index']] = 0
        self.__tutorial_occupation_array[
            self.__best_first_neighborhood['student_1_index'],
            self.__best_first_neighborhood['teacher_index'],
            self.__best_first_neighborhood['tutorial_1_index'],
            self.__best_first_neighborhood['new_date_index'],
            self.__best_first_neighborhood['new_period_index']] = 1
        self.__tutorial_occupation_array[
            self.__best_first_neighborhood['student_2_index'],
            self.__best_first_neighborhood['teacher_index'],
            self.__best_first_neighborhood['tutorial_2_index'],
            self.__best_first_neighborhood['new_date_index'],
            self.__best_first_neighborhood['new_period_index']] = 1

    def __improve_one_time_by_third_neighborhoods(self):
        self.__tutorial_occupation_array[
            self.__best_first_neighborhood['student_1_index'],
            self.__best_first_neighborhood['teacher_index'],
            self.__best_first_neighborhood['tutorial_1_index'],
            self.__best_first_neighborhood['date_index'],
            self.__best_first_neighborhood['period_index']] = 0
        self.__tutorial_occupation_array[
            self.__best_first_neighborhood['student_2_index'],
            self.__best_first_neighborhood['teacher_index'],
            self.__best_first_neighborhood['tutorial_2_index'],
            self.__best_first_neighborhood['new_date_index'],
            self.__best_first_neighborhood['new_period_index']] = 0
        self.__tutorial_occupation_array[
            self.__best_first_neighborhood['student_1_index'],
            self.__best_first_neighborhood['teacher_index'],
            self.__best_first_neighborhood['tutorial_1_index'],
            self.__best_first_neighborhood['new_date_index'],
            self.__best_first_neighborhood['new_period_index']] = 1
        self.__tutorial_occupation_array[
            self.__best_first_neighborhood['student_2_index'],
            self.__best_first_neighborhood['teacher_index'],
            self.__best_first_neighborhood['tutorial_2_index'],
            self.__best_first_neighborhood['date_index'],
            self.__best_first_neighborhood['period_index']] = 1

    def __logging_by_first_neighborhoods(self, elapsed_sec):
        student_index = self.__best_third_neighborhood['student_index']
        student_name = self.__term_object['term_students'][student_index]['name']
        student_school_grade = self.__term_object['term_students'][student_index]['school_grade']
        teacher_index = self.__best_third_neighborhood['teacher_index']
        teacher_name = self.__term_object['term_teachers'][teacher_index]['name']
        tutorial_index = self.__best_third_neighborhood['tutorial_index']
        tutorial_name = self.__term_object['term_tutorials'][tutorial_index]['name']
        date_index = self.__best_third_neighborhood['date_index']
        new_date_index = self.__best_third_neighborhood['new_date_index']
        period_index = self.__best_third_neighborhood['period_index']
        new_period_index = self.__best_third_neighborhood['new_period_index']
        [violation, cost] = self.__cost_evaluator.violation_and_cost(self.__tutorial_occupation_array)
        logger.info('================コマを移動しました================')
        logger.info(f'改善方式：第１近傍')
        logger.info(f'生徒/科目：{student_name}（{student_school_grade}）{tutorial_name}')
        logger.info(f'講師：{teacher_name}')
        logger.info(f'変更元日時：{date_index + 1}日目{period_index + 1}限')
        logger.info(f'変更先日時：{new_date_index + 1}日目{new_period_index + 1}限')
        logger.info(f'合計違反点数：{violation}')
        logger.info(f'合計コスト点数：{cost}')
        logger.info(f'経過時間：{elapsed_sec}秒')
        logger.info('==================================================')

    def __logging_by_second_neighborhoods(self, elapsed_sec):
        student_1_index = self.__best_third_neighborhood['student_1_index']
        student_1_name = self.__term_object['term_students'][student_1_index]['name']
        student_1_school_grade = self.__term_object['term_students'][student_1_index]['school_grade']
        student_2_index = self.__best_third_neighborhood['student_2_index']
        student_2_name = self.__term_object['term_students'][student_2_index]['name']
        student_2_school_grade = self.__term_object['term_students'][student_2_index]['school_grade']
        teacher_index = self.__best_third_neighborhood['teacher_index']
        teacher_name = self.__term_object['term_teachers'][teacher_index]['name']
        tutorial_1_index = self.__best_third_neighborhood['tutorial_1_index']
        tutorial_1_name = self.__term_object['term_tutorials'][tutorial_1_index]['name']
        tutorial_2_index = self.__best_third_neighborhood['tutorial_2_index']
        tutorial_2_name = self.__term_object['term_tutorials'][tutorial_2_index]['name']
        date_index = self.__best_third_neighborhood['date_index']
        new_date_index = self.__best_third_neighborhood['new_date_index']
        period_index = self.__best_third_neighborhood['period_index']
        new_period_index = self.__best_third_neighborhood['new_period_index']
        [violation, cost] = self.__cost_evaluator.violation_and_cost(self.__tutorial_occupation_array)
        logger.info('================コマを移動しました================')
        logger.info(f'改善方式：第２近傍')
        logger.info(f'生徒/科目１：{student_1_name}（{student_1_school_grade}）{tutorial_1_name}')
        logger.info(f'生徒/科目２：{student_2_name}（{student_2_school_grade}）{tutorial_2_name}')
        logger.info(f'講師：{teacher_name}')
        logger.info(f'変更元日時：{date_index + 1}日目{period_index + 1}限')
        logger.info(f'変更先日時：{new_date_index + 1}日目{new_period_index + 1}限')
        logger.info(f'合計違反点数：{violation}')
        logger.info(f'合計コスト点数：{cost}')
        logger.info(f'経過時間：{elapsed_sec}秒')
        logger.info('==================================================')

    def __logging_by_third_neighborhoods(self, elapsed_sec):
        student_1_index = self.__best_third_neighborhood['student_1_index']
        student_1_name = self.__term_object['term_students'][student_1_index]['name']
        student_1_school_grade = self.__term_object['term_students'][student_1_index]['school_grade']
        student_2_index = self.__best_third_neighborhood['student_2_index']
        student_2_name = self.__term_object['term_students'][student_2_index]['name']
        student_2_school_grade = self.__term_object['term_students'][student_2_index]['school_grade']
        teacher_index = self.__best_third_neighborhood['teacher_index']
        teacher_name = self.__term_object['term_teachers'][teacher_index]['name']
        tutorial_1_index = self.__best_third_neighborhood['tutorial_1_index']
        tutorial_1_name = self.__term_object['term_tutorials'][tutorial_1_index]['name']
        tutorial_2_index = self.__best_third_neighborhood['tutorial_2_index']
        tutorial_2_name = self.__term_object['term_tutorials'][tutorial_2_index]['name']
        date_index = self.__best_third_neighborhood['date_index']
        new_date_index = self.__best_third_neighborhood['new_date_index']
        period_index = self.__best_third_neighborhood['period_index']
        new_period_index = self.__best_third_neighborhood['new_period_index']
        [violation, cost] = self.__cost_evaluator.violation_and_cost(self.__tutorial_occupation_array)
        logger.info('================コマを移動しました================')
        logger.info(f'改善方式：第３近傍')
        logger.info(f'生徒/科目１：{student_1_name}（{student_1_school_grade}）{tutorial_1_name}')
        logger.info(f'生徒/科目２：{student_2_name}（{student_2_school_grade}）{tutorial_2_name}')
        logger.info(f'講師：{teacher_name}')
        logger.info(f'変更元日時：{date_index + 1}日目{period_index + 1}限')
        logger.info(f'変更先日時：{new_date_index + 1}日目{new_period_index + 1}限')
        logger.info(f'合計違反点数：{violation}')
        logger.info(f'合計コスト点数：{cost}')
        logger.info(f'経過時間：{elapsed_sec}秒')
        logger.info('==================================================')

    def __improve_one_time(
        self, student_index, teacher_index, tutorial_index, date_index, period_index):
        start = time.time()
        self.__get_best_first_neighborhood(
            student_index, teacher_index, tutorial_index, date_index, period_index)
        self.__get_best_second_neighborhood(
            student_index, teacher_index, tutorial_index, date_index, period_index)
        self.__get_best_third_neighborhood(
            student_index, teacher_index, tutorial_index, date_index, period_index)
        violation_and_cost_for_nth_neighborhoods = [
            self.__best_first_neighborhood['min_violation_and_cost'],
            self.__best_second_neighborhood['min_violation_and_cost'],
            self.__best_third_neighborhood['min_violation_and_cost']]
        best_nth_neighborhood = violation_and_cost_for_nth_neighborhoods.index(
            min(violation_and_cost_for_nth_neighborhoods))
        end = time.time()
        elapsed_sec = math.floor((end - start) * 1000000) / 1000000
        if best_nth_neighborhood == 0:
            self.__improve_one_time_by_first_neighborhoods()
            self.__logging_by_first_neighborhoods(elapsed_sec)
        elif best_nth_neighborhood == 1:
            self.__improve_one_time_by_second_neighborhoods()
            self.__logging_by_second_neighborhoods(elapsed_sec)
        elif best_nth_neighborhood == 2:
            self.__improve_one_time_by_third_neighborhoods()
            self.__logging_by_third_neighborhoods(elapsed_sec)
        self.__reset_best_nth_neighborhood()

    def __guard_improvement(
        self, student_index, teacher_index, tutorial_index, date_index, period_index):
        # コマが配置されていない場合は探索対象外
        if self.__tutorial_occupation_array[
            student_index, teacher_index, tutorial_index, date_index, period_index] == 1: return True
        # ロック中のコマは探索対象外
        if self.__fixed_tutorial_occupation_array[
            student_index, teacher_index, tutorial_index, date_index, period_index]: return True

    def __improve_by_round_robin(self):
        round_robin_orders_first_half = list(
            range(self.__round_robin_order_before, self.__total_tutorial_piece_count))
        round_robin_orders_latter_half = list(
            range(0, self.__round_robin_order_before))
        round_robin_orders = round_robin_orders_first_half + round_robin_orders_latter_half
        is_improved = False
        for round_robin_order in round_robin_orders:
            [student_index, teacher_index, tutorial_index, date_index, period_index] = \
                self.__tutorial_piece_evaluator.get_nth_tutorial_piece_indexes_from_worst(round_robin_order)
            if self.__guard_improvement(
                student_index, teacher_index, tutorial_index, date_index, period_index): continue
            if self.__improve_one_time(
                student_index, teacher_index, tutorial_index, date_index, period_index):
                self.__round_robin_order_before = round_robin_order
                is_improved = True
                break
        return is_improved
                
    def execute(self):
        print('TODO')
