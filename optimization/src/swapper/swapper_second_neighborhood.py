import itertools
import numpy
from cost_evaluator.cost_evaluator import CostEvaluator
from logging import getLogger


logger = getLogger(__name__)

# 第２近傍の最適解取得クラス(対象のコマを、対になるコマと一緒に空いている時間枠に移動するパターン)
class SwapperSecondNeighborhood():
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
        self.__timetable_array = array_builder.timetable_array()
        self.__tutorial_occupation_array = array_builder.tutorial_occupation_array()
        self.__fixed_tutorial_occupation_array = array_builder.fixed_tutorial_occupation_array()
        self.__best_answer = self.__initial_best_answer()

    def __initial_best_answer(self):
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
        if pair_student_index == None or pair_tutorial_index == None:
            return self.__best_answer['min_violation_and_cost']
        # 対になるコマがロック中の場合は探索しない
        if self.__fixed_tutorial_occupation_array[
            pair_student_index, teacher_index, pair_tutorial_index, date_index, period_index]:
                return self.__best_answer['min_violation_and_cost']
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
            if violation_and_cost < self.__best_answer['min_violation_and_cost']:
                self.__best_answer = {
                    'min_violation_and_cost': violation_and_cost,
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
        return self.__best_answer['min_violation_and_cost']

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
        [violation, cost] = self.__cost_evaluator.violation_and_cost(self.__tutorial_occupation_array)
        logger.info('================コマを移動しました================')
        logger.info(f'移動No：{swap_count}')
        logger.info(f'選択方式：ラウンドロビン シーケンス番号{round_robin_order}')
        logger.info(f'探索方式：第２近傍探索')
        logger.info(f'生徒/科目１：{student_1_name}（{student_1_school_grade}）{tutorial_1_name}')
        logger.info(f'生徒/科目２：{student_2_name}（{student_2_school_grade}）{tutorial_2_name}')
        logger.info(f'講師：{teacher_name}')
        logger.info(f'変更元日時：{date_index + 1}日目{period_index + 1}限')
        logger.info(f'変更先日時：{new_date_index + 1}日目{new_period_index + 1}限')
        logger.info(f'合計違反点数：{violation}')
        logger.info(f'合計コスト点数：{cost}')
        logger.info(f'経過時間：{elapsed_sec}秒')
        logger.info('==================================================')
