import numpy
from .interval_evaluator import IntervalEvaluator
from .occupation_and_blank_evaluator import OccupationAndBlankEvaluator
from .seat_occupation_evaluator import SeatOccupationEvaluator
from .seat_combination_evaluator import SeatCombinationEvaluator
from .vacancy_and_double_booking_evaluator import VacancyAndDoubleBookingEvaluator

COST_PER_VIOLATION = 1000000


class TutorialPieceEvaluator():
    def __init__(
            self,
            array_size,
            student_optimization_rules,
            teacher_optimization_rule,
            student_group_occupation,
            teacher_group_occupation,
            student_vacancy,
            teacher_vacancy,
            school_grades):
        self.__interval_evaluator = IntervalEvaluator(
            array_size=array_size,
            student_optimization_rules=student_optimization_rules,
            school_grades=school_grades)
        self.__occupation_and_blank_evaluator = OccupationAndBlankEvaluator(
            array_size=array_size,
            student_optimization_rules=student_optimization_rules,
            teacher_optimization_rule=teacher_optimization_rule,
            student_group_occupation=student_group_occupation,
            teacher_group_occupation=teacher_group_occupation,
            school_grades=school_grades)
        self.__seat_occupation_evaluator = SeatOccupationEvaluator(
            array_size=array_size)
        self.__seat_combination_evaluator = SeatCombinationEvaluator(
            array_size=array_size,
            single_cost=teacher_optimization_rule['single_cost'],
            different_pair_cost=teacher_optimization_rule['different_pair_cost'])
        self.__vacancy_and_double_booking_evaluator = VacancyAndDoubleBookingEvaluator(
            student_vacancy=student_vacancy,
            teacher_vacancy=teacher_vacancy)
        self.__violation_array = numpy.zeros(
            (array_size.student_count(), array_size.teacher_count(), array_size.tutorial_count(),
             array_size.date_count(), array_size.period_count()),
            dtype=int)
        self.__cost_array = numpy.zeros(
            (array_size.student_count(), array_size.teacher_count(), array_size.tutorial_count(),
             array_size.date_count(), array_size.period_count()),
            dtype=int)

    def get_violation_and_cost_array(self, tutorial_pieces):
        self.__interval_evaluator.get_violation_and_cost_array(
            tutorial_pieces, self.__cost_array)
        self.__occupation_and_blank_evaluator.get_violation_and_cost_array(
            tutorial_pieces, self.__violation_array, self.__cost_array)
        self.__seat_occupation_evaluator.get_violation_and_cost_array(
            tutorial_pieces, self.__violation_array)
        self.__seat_combination_evaluator.get_violation_and_cost_array(
            tutorial_pieces, self.__cost_array)
        self.__vacancy_and_double_booking_evaluator.get_violation_and_cost_array(
            tutorial_pieces, self.__violation_array)
        violation_and_cost_array = self.__violation_array * COST_PER_VIOLATION + self.__cost_array
        flattened_violation_and_cost_array = violation_and_cost_array.flatten()
        flattened_and_sorted_violation_and_cost_index_array = numpy.argsort(-flattened_violation_and_cost_array)
        self.__sort_result = numpy.unravel_index(
            flattened_and_sorted_violation_and_cost_index_array,
            violation_and_cost_array.shape)

    def get_nth_tutorial_piece_indexes_from_worst(self, nth):
        return [
            self.__sort_result[0][nth],
            self.__sort_result[1][nth],
            self.__sort_result[2][nth],
            self.__sort_result[3][nth],
            self.__sort_result[4][nth]]

    def get_nth_tutorial_piece_violation_and_cost_from_worst(self, nth):
        student_index = self.__sort_result[0][nth]
        teacher_index = self.__sort_result[1][nth]
        tutorial_index = self.__sort_result[2][nth]
        date_index = self.__sort_result[3][nth]
        period_index = self.__sort_result[4][nth]
        violation = self.__violation_array[student_index, teacher_index, tutorial_index, date_index, period_index]
        cost = self.__cost_array[student_index, teacher_index, tutorial_index, date_index, period_index]
        return [violation, cost]
