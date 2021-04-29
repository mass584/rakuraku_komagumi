from unittest import TestCase
from test.test_data.normal_term import normal_term
from test.test_data.season_term import season_term
from test.test_data.exam_planning_term import exam_planning_term
from src.array_builder.array_size import ArraySize
from src.array_builder.tutorial_occupation import TutorialOccupation
from src.cost_evaluator.interval_evaluator import IntervalEvaluator

class TestIntervalEvaluator(TestCase):
    def test_interval_is_zero(self):
        season_term['tutorial_pieces'][0]['date_index'] = 1
        season_term['tutorial_pieces'][0]['period_index'] = 1
        season_term['tutorial_pieces'][1]['date_index'] = 1
        season_term['tutorial_pieces'][1]['period_index'] = 2
        array_size = ArraySize(season_term)
        tutorial_occupation = TutorialOccupation(season_term, array_size)
        interval_cutoff = 2
        interval_costs = [70, 35, 14]
        interval_evaluator = IntervalEvaluator(array_size, interval_cutoff, interval_costs)
        self.assertEqual(interval_evaluator.violation_and_cost(tutorial_occupation.tutorial_occupation()), [0, 70])

    def test_interval_is_cutoff(self):
        season_term['tutorial_pieces'][0]['date_index'] = 1
        season_term['tutorial_pieces'][0]['period_index'] = 1
        season_term['tutorial_pieces'][1]['date_index'] = 3
        season_term['tutorial_pieces'][1]['period_index'] = 1
        array_size = ArraySize(season_term)
        tutorial_occupation = TutorialOccupation(season_term, array_size)
        interval_cutoff = 2
        interval_costs = [70, 35, 14]
        interval_evaluator = IntervalEvaluator(array_size, interval_cutoff, interval_costs)
        self.assertEqual(interval_evaluator.violation_and_cost(tutorial_occupation.tutorial_occupation()), [0, 14])

    def test_interval_is_over_cutoff(self):
        season_term['tutorial_pieces'][0]['date_index'] = 1
        season_term['tutorial_pieces'][0]['period_index'] = 1
        season_term['tutorial_pieces'][1]['date_index'] = 4
        season_term['tutorial_pieces'][1]['period_index'] = 1
        array_size = ArraySize(season_term)
        tutorial_occupation = TutorialOccupation(season_term, array_size)
        interval_cutoff = 2
        interval_costs = [70, 35, 14]
        interval_evaluator = IntervalEvaluator(array_size, interval_cutoff, interval_costs)
        self.assertEqual(interval_evaluator.violation_and_cost(tutorial_occupation.tutorial_occupation()), [0, 0])
