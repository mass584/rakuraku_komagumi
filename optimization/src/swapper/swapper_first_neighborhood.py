import itertools
from cost_evaluator.cost_evaluator import CostEvaluator
from logging import getLogger


logger = getLogger(__name__)

# 第１近傍の最適解取得クラス(対象のコマを、空いている時間枠に移動するパターン)
class SwapperFirstNeighborhood():
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
        self.__best_answer = self.__initial_best_answer()
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
            if violation_and_cost < self.__best_answer['min_violation_and_cost']:
                self.__best_answer = {
                    'min_violation_and_cost': violation_and_cost,
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
        return self.__best_answer

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
        [violation, cost] = self.__cost_evaluator.violation_and_cost(self.__tutorial_occupation_array)
        logger.info('================コマを移動しました================')
        logger.info(f'移動No：{swap_count}')
        logger.info(f'選択方式：ラウンドロビン シーケンス番号{round_robin_order}')
        logger.info(f'探索方式：第１近傍探索')
        logger.info(f'生徒/科目：{student_name}（{student_school_grade}）{tutorial_name}')
        logger.info(f'講師：{teacher_name}')
        logger.info(f'変更元日時：{date_index + 1}日目{period_index + 1}限')
        logger.info(f'変更先日時：{new_date_index + 1}日目{new_period_index + 1}限')
        logger.info(f'合計違反点数：{violation}')
        logger.info(f'合計コスト点数：{cost}')
        logger.info(f'経過時間：{elapsed_sec}秒')
        logger.info('==================================================')
