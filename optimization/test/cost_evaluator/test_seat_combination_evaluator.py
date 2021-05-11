import copy
from unittest import TestCase
from ..test_data.season_term import season_term
from src.array_builder.array_size import ArraySize
from src.array_builder.tutorial_occupation import TutorialOccupation
from src.cost_evaluator.seat_combination_evaluator \
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
        self.assertEqual(occupation_and_blank_evaluator.violation_and_cost(
            tutorial_occupation.tutorial_occupation_array()
        ), [0, 100])

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
        self.assertEqual(occupation_and_blank_evaluator.violation_and_cost(
            tutorial_occupation.tutorial_occupation_array()
        ), [0, 0])

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
        self.assertEqual(occupation_and_blank_evaluator.violation_and_cost(
            tutorial_occupation.tutorial_occupation_array()
        ), [0, 15])
