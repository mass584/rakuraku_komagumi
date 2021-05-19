import numpy
from logging import getLogger


logger = getLogger(__name__)


class Deletion():
    def __init__(self, term_object, tutorial_occupation_array, fixed_tutorial_occupation_array,
                 tutorial_piece_count_array, cost_evaluator, tutorial_piece_evaluator):
        self.__term_object = term_object
        self.__cost_evaluator = cost_evaluator
        self.__tutorial_piece_evaluator = tutorial_piece_evaluator
        self.__tutorial_occupation_array = tutorial_occupation_array
        self.__fixed_tutorial_occupation_array = fixed_tutorial_occupation_array
        self.__total_tutorial_piece_count = numpy.sum(
            tutorial_piece_count_array)
        self.__deleted_count = 0

    def __guard(
            self, student_index, teacher_index, tutorial_index, date_index, period_index):
        # コマが配置されていない場合は探索対象外
        if self.__tutorial_occupation_array[
                student_index, teacher_index, tutorial_index, date_index, period_index] == 0:
            return True
        # ロック中のコマは探索対象外
        if self.__fixed_tutorial_occupation_array[
                student_index, teacher_index, tutorial_index, date_index, period_index] == 1:
            return True

    def __get_violation_when_delete_one_tutorial_piece(
            self, student_index, teacher_index, tutorial_index, date_index, period_index):
        self.__tutorial_occupation_array[
            student_index, teacher_index, tutorial_index, date_index, period_index] = 0
        [violation, _] = self.__cost_evaluator.violation_and_cost(
            self.__tutorial_occupation_array)
        self.__tutorial_occupation_array[
            student_index, teacher_index, tutorial_index, date_index, period_index] = 0
        return violation

    def __logging_when_delete_one_tutorial_piece(
            self, student_index, teacher_index, tutorial_index, date_index, period_index):
        student_name = self.__term_object['term_students'][student_index]['name']
        student_school_grade = self.__term_object['term_students'][student_index]['school_grade']
        teacher_name = self.__term_object['term_teachers'][teacher_index]['name']
        tutorial_name = self.__term_object['term_tutorials'][tutorial_index]['name']
        [violation, cost] = self.__cost_evaluator.violation_and_cost(
            self.__tutorial_occupation_array)
        logger.info('================コマを削除しました================')
        logger.info(f'削除No：{self.__deleted_count}')
        logger.info(f'生徒：{student_name}（{student_school_grade}）')
        logger.info(f'講師：{teacher_name}')
        logger.info(f'科目：{tutorial_name}')
        logger.info(f'日時：{date_index + 1}日目{period_index + 1}限')
        logger.info(f'合計違反点数：{violation}')
        logger.info(f'合計コスト点数：{cost}')
        logger.info('==================================================')

    def __delete(self, student_index, teacher_index,
                 tutorial_index, date_index, period_index):
        self.__tutorial_occupation_array[
            student_index, teacher_index, tutorial_index, date_index, period_index] = 0
        self.__deleted_count += 1
        self.__logging_when_delete_one_tutorial_piece(
            student_index, teacher_index, tutorial_index, date_index, period_index)

    def __delete_one_tutorial_piece_if_improved(self):
        [violation_before, _] = self.__cost_evaluator.violation_and_cost(
            self.__tutorial_occupation_array)
        self.__tutorial_piece_evaluator.get_violation_and_cost_array(
            self.__tutorial_occupation_array)
        is_deleted = False
        for order in range(self.__total_tutorial_piece_count):
            [student_index, teacher_index, tutorial_index, date_index, period_index] = \
                self.__tutorial_piece_evaluator.get_nth_tutorial_piece_indexes_from_worst(
                    order)
            [violation_for_tutorial_piece, _] = \
                self.__tutorial_piece_evaluator.get_nth_tutorial_piece_violation_and_cost_from_worst(
                    order)
            if self.__guard(student_index, teacher_index,
                            tutorial_index, date_index, period_index):
                continue
            # 違反ウェイトを持たないコマはスキップする
            if violation_for_tutorial_piece == 0:
                continue
            violation_after = self.__get_violation_when_delete_one_tutorial_piece(
                student_index, teacher_index, tutorial_index, date_index, period_index)
            # 違反が減らない、もしくは変化しない場合は、スキップする
            if violation_after >= violation_before:
                continue
            self.__delete(
                student_index,
                teacher_index,
                tutorial_index,
                date_index,
                period_index)
            is_deleted = True
            break
        return is_deleted

    def __delete_one_tutorial_piece_forcibly(self):
        self.__tutorial_piece_evaluator.get_violation_and_cost_array(
            self.__tutorial_occupation_array)
        is_deleted = False
        for order in range(self.__total_tutorial_piece_count):
            [student_index, teacher_index, tutorial_index, date_index, period_index] = \
                self.__tutorial_piece_evaluator.get_nth_tutorial_piece_indexes_from_worst(
                    order)
            [violation_for_tutorial_piece, _] = \
                self.__tutorial_piece_evaluator.get_nth_tutorial_piece_violation_and_cost_from_worst(
                    order)
            if self.__guard(student_index, teacher_index,
                            tutorial_index, date_index, period_index):
                continue
            # 違反ウェイトを持たないコマはスキップする
            if violation_for_tutorial_piece == 0:
                continue
            self.__delete(
                student_index,
                teacher_index,
                tutorial_index,
                date_index,
                period_index)
            is_deleted = True
            break
        return is_deleted

    def execute(self):
        while True:
            [violation, _] = self.__cost_evaluator.violation_and_cost(
                self.__tutorial_occupation_array)
            if violation == 0:
                break
            # 違反ウェイトをもつコマを削除して、違反を減少させる。
            if self.__delete_one_tutorial_piece_if_improved():
                continue
            # どのコマを削除したとしても違反が減らない場合、
            # 違反の増減に関わらず最も大きい違反ウェイトをもつコマを削除する。
            if self.__delete_one_tutorial_piece_forcibly():
                continue
            # 以下の処理は異常系
            logger.error('違反ウェイトをもつコマを削除できませんでした。')

    def deleted_count(self):
        return self.__deleted_count
