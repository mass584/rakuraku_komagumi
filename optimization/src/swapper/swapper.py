import math
import numpy
import time
from .swapper_first_neighborhood import SwapperFirstNeighborhood
from .swapper_second_neighborhood import SwapperSecondNeighborhood
from .swapper_third_neighborhood import SwapperThirdNeighborhood
from tutorial_piece_evaluator.tutorial_piece_evaluator import TutorialPieceEvaluator
from logging import getLogger


logger = getLogger(__name__)
SWAPPING_PROCESS_MAX_COUNT = 1000


class Swapper():
    def __init__(self, process_count, term_object, array_builder,
                 cost_evaluator, tutorial_piece_evaluator):
        self.__swapper_first_neighborhood = SwapperFirstNeighborhood(
            process_count=process_count,
            term_object=term_object,
            array_builder=array_builder,
            cost_evaluator=cost_evaluator,
        )
        self.__swapper_second_neighborhood = SwapperSecondNeighborhood(
            process_count=process_count,
            term_object=term_object,
            array_builder=array_builder,
            cost_evaluator=cost_evaluator,
        )
        self.__swapper_third_neighborhood = SwapperThirdNeighborhood(
            process_count=process_count,
            term_object=term_object,
            array_builder=array_builder,
            cost_evaluator=cost_evaluator,
        )
        self.__cost_evaluator = cost_evaluator
        self.__tutorial_piece_evaluator = tutorial_piece_evaluator
        self.__tutorial_occupation_array = array_builder.tutorial_occupation_array()
        self.__fixed_tutorial_occupation_array = array_builder.fixed_tutorial_occupation_array()
        self.__round_robin_order_before = 0
        self.__swap_count = 0
        self.__total_tutorial_piece_count = numpy.sum(
            array_builder.tutorial_piece_count_array())

    def __improve_one_time(
            self, student_index, teacher_index, tutorial_index,
            date_index, period_index, round_robin_order):
        start = time.time()
        cost_before = self.__cost_evaluator.cost(
            self.__tutorial_occupation_array)
        first_neighborhood_best_answer = self.__swapper_first_neighborhood.get_best_answer(
            student_index, teacher_index, tutorial_index, date_index, period_index)
        second_neighborhood_best_answer = self.__swapper_second_neighborhood.get_best_answer(
            student_index, teacher_index, tutorial_index, date_index, period_index)
        third_neighborhood_best_answer = self.__swapper_third_neighborhood.get_best_answer(
            student_index, teacher_index, tutorial_index, date_index, period_index)
        violation_and_cost_for_nth_neighborhoods = [
            first_neighborhood_best_answer,
            second_neighborhood_best_answer,
            third_neighborhood_best_answer]
        cost_after = min(violation_and_cost_for_nth_neighborhoods)
        end = time.time()
        elapsed_sec = math.floor((end - start) * 1000000) / 1000000
        if cost_after >= cost_before:
            return False
        best_nth_neighborhood = violation_and_cost_for_nth_neighborhoods.index(
            cost_after)
        if best_nth_neighborhood == 0:
            self.__swapper_first_neighborhood.execute()
            self.__swapper_first_neighborhood.logging(
                elapsed_sec, round_robin_order, self.__swap_count)
        elif best_nth_neighborhood == 1:
            self.__swapper_second_neighborhood.execute()
            self.__swapper_second_neighborhood.logging(
                elapsed_sec, round_robin_order, self.__swap_count)
        elif best_nth_neighborhood == 2:
            self.__swapper_third_neighborhood.execute()
            self.__swapper_third_neighborhood.logging(
                elapsed_sec, round_robin_order, self.__swap_count)
        self.__round_robin_order_before = round_robin_order
        return True

    def __guard_improvement(
            self, student_index, teacher_index, tutorial_index, date_index, period_index):
        # コマが配置されていない場合は探索対象外
        if self.__tutorial_occupation_array[
                student_index, teacher_index, tutorial_index, date_index, period_index] == 0:
            return True
        # ロック中のコマは探索対象外
        if self.__fixed_tutorial_occupation_array[
                student_index, teacher_index, tutorial_index, date_index, period_index] == 1:
            return True

    def __improve_by_round_robin(self):
        round_robin_orders_first_half = list(
            range(self.__round_robin_order_before, self.__total_tutorial_piece_count))
        round_robin_orders_latter_half = list(
            range(0, self.__round_robin_order_before))
        round_robin_orders = round_robin_orders_first_half + round_robin_orders_latter_half
        is_improved = False
        self.__tutorial_piece_evaluator.get_violation_and_cost_array(
            self.__tutorial_occupation_array)
        for round_robin_order in round_robin_orders:
            [student_index, teacher_index, tutorial_index, date_index, period_index] = \
                self.__tutorial_piece_evaluator.get_nth_tutorial_piece_indexes_from_worst(
                    round_robin_order)
            if self.__guard_improvement(
                    student_index, teacher_index, tutorial_index, date_index, period_index):
                continue
            if self.__improve_one_time(
                    student_index, teacher_index, tutorial_index, date_index, period_index, round_robin_order):
                is_improved = True
                break
        return is_improved

    def execute(self):
        while True:
            self.__swap_count += 1
            is_improved = self.__improve_by_round_robin()
            if not is_improved:
                break
            if self.__swap_count == SWAPPING_PROCESS_MAX_COUNT:
                break

    def tutorial_occupation_array(self):
        return self.__tutorial_occupation_array
