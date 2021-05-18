import copy
import numpy
from unittest import TestCase
from test.test_data.season_term import season_term
from src.array_builder.array_size import ArraySize
from src.array_builder.tutorial_occupation import TutorialOccupation
from src.tutorial_piece_evaluator.seat_combination_evaluator \
    import SeatCombinationEvaluator


class TestSeatCombinationEvaluator(TestCase):
    def test_single(self):
        term = copy.deepcopy(season_term)
        term['tutorial_pieces'][0]['date_index'] = 1
        term['tutorial_pieces'][0]['period_index'] = 1
        array_size = ArraySize(term)
        tutorial_occupation = TutorialOccupation(term, array_size)
        occupation_and_blank_evaluator = SeatCombinationEvaluator(
            array_size, 100, 15)
        cost_array = numpy.zeros(
            (array_size.student_count(), array_size.teacher_count(), array_size.tutorial_count(),
             array_size.date_count(), array_size.period_count()),
            dtype=int)
        occupation_and_blank_evaluator.get_violation_and_cost_array(
            tutorial_occupation.tutorial_occupation_array(),
            cost_array)
        self.assertEqual(cost_array[0, 0, 0, 0, 0], 100)
        self.assertEqual(numpy.sum(cost_array), 100)

    def test_same_tutorial_pair(self):
        term = copy.deepcopy(season_term)
        term['tutorial_pieces'][0]['date_index'] = 1
        term['tutorial_pieces'][0]['period_index'] = 1
        term['tutorial_pieces'][12]['date_index'] = 1
        term['tutorial_pieces'][12]['period_index'] = 1
        array_size = ArraySize(term)
        tutorial_occupation = TutorialOccupation(term, array_size)
        occupation_and_blank_evaluator = SeatCombinationEvaluator(
            array_size, 100, 15)
        cost_array = numpy.zeros(
            (array_size.student_count(), array_size.teacher_count(), array_size.tutorial_count(),
             array_size.date_count(), array_size.period_count()),
            dtype=int)
        occupation_and_blank_evaluator.get_violation_and_cost_array(
            tutorial_occupation.tutorial_occupation_array(),
            cost_array)
        self.assertEqual(cost_array[0, 0, 0, 0, 0], 0)
        self.assertEqual(cost_array[1, 0, 0, 0, 0], 0)
        self.assertEqual(numpy.sum(cost_array), 0)

    def test_different_tutorial_pair(self):
        term = copy.deepcopy(season_term)
        term['tutorial_pieces'][0]['date_index'] = 1
        term['tutorial_pieces'][0]['period_index'] = 1
        term['tutorial_pieces'][0]['term_teacher_id'] = 1
        term['tutorial_pieces'][16]['date_index'] = 1
        term['tutorial_pieces'][16]['period_index'] = 1
        term['tutorial_pieces'][16]['term_teacher_id'] = 1
        array_size = ArraySize(term)
        tutorial_occupation = TutorialOccupation(term, array_size)
        occupation_and_blank_evaluator = SeatCombinationEvaluator(
            array_size, 100, 15)
        cost_array = numpy.zeros(
            (array_size.student_count(), array_size.teacher_count(), array_size.tutorial_count(),
             array_size.date_count(), array_size.period_count()),
            dtype=int)
        occupation_and_blank_evaluator.get_violation_and_cost_array(
            tutorial_occupation.tutorial_occupation_array(),
            cost_array)
        self.assertEqual(cost_array[0, 0, 0, 0, 0], 15)
        self.assertEqual(cost_array[1, 0, 1, 0, 0], 15)
        self.assertEqual(numpy.sum(cost_array), 30)
