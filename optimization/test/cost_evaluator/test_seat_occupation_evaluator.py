import copy
from unittest import TestCase
from ..test_data.season_term import season_term
from src.array_builder.array_size import ArraySize
from src.array_builder.tutorial_occupation import TutorialOccupation
from src.cost_evaluator.seat_occupation_evaluator \
    import SeatOccupationEvaluator


class TestSeatOccupationEvaluator(TestCase):
    def test_fully_occupied_seat(self):
        term = copy.deepcopy(season_term)
        term['term']['seat_count'] = 2
        term['tutorial_pieces'][0]['date_index'] = 1
        term['tutorial_pieces'][0]['period_index'] = 1
        term['tutorial_pieces'][0]['term_teacher_id'] = 1
        term['tutorial_pieces'][4]['date_index'] = 1
        term['tutorial_pieces'][4]['period_index'] = 1
        term['tutorial_pieces'][4]['term_teacher_id'] = 2
        term['tutorial_pieces'][8]['date_index'] = 1
        term['tutorial_pieces'][8]['period_index'] = 1
        term['tutorial_pieces'][8]['term_teacher_id'] = 2
        array_size = ArraySize(term)
        tutorial_occupation = TutorialOccupation(term, array_size)
        evaluator = SeatOccupationEvaluator(array_size)
        self.assertEqual(evaluator.violation_and_cost(
            tutorial_occupation.tutorial_occupation_array()
        ), [0, 0])

    def test_lack_of_one_seat(self):
        term = copy.deepcopy(season_term)
        term['term']['seat_count'] = 2
        term['tutorial_pieces'][0]['date_index'] = 1
        term['tutorial_pieces'][0]['period_index'] = 1
        term['tutorial_pieces'][0]['term_teacher_id'] = 1
        term['tutorial_pieces'][4]['date_index'] = 1
        term['tutorial_pieces'][4]['period_index'] = 1
        term['tutorial_pieces'][4]['term_teacher_id'] = 2
        term['tutorial_pieces'][8]['date_index'] = 1
        term['tutorial_pieces'][8]['period_index'] = 1
        term['tutorial_pieces'][8]['term_teacher_id'] = 3
        array_size = ArraySize(term)
        tutorial_occupation = TutorialOccupation(term, array_size)
        evaluator = SeatOccupationEvaluator(array_size)
        self.assertEqual(evaluator.violation_and_cost(
            tutorial_occupation.tutorial_occupation_array()
        ), [1, 0])

    def test_lack_of_two_seat(self):
        term = copy.deepcopy(season_term)
        term['term']['seat_count'] = 2
        term['tutorial_pieces'][0]['date_index'] = 1
        term['tutorial_pieces'][0]['period_index'] = 1
        term['tutorial_pieces'][0]['term_teacher_id'] = 1
        term['tutorial_pieces'][4]['date_index'] = 1
        term['tutorial_pieces'][4]['period_index'] = 1
        term['tutorial_pieces'][4]['term_teacher_id'] = 2
        term['tutorial_pieces'][8]['date_index'] = 1
        term['tutorial_pieces'][8]['period_index'] = 1
        term['tutorial_pieces'][8]['term_teacher_id'] = 3
        term['tutorial_pieces'][12]['date_index'] = 1
        term['tutorial_pieces'][12]['period_index'] = 1
        term['tutorial_pieces'][12]['term_teacher_id'] = 4
        array_size = ArraySize(term)
        tutorial_occupation = TutorialOccupation(term, array_size)
        evaluator = SeatOccupationEvaluator(array_size)
        self.assertEqual(evaluator.violation_and_cost(
            tutorial_occupation.tutorial_occupation_array()
        ), [2, 0])
