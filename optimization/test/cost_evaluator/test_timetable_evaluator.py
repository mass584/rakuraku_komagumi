import copy
from unittest import TestCase
from ..test_data.season_term import season_term
from src.array_builder.array_size import ArraySize
from src.array_builder.timetable import Timetable
from src.array_builder.tutorial_occupation import TutorialOccupation
from src.cost_evaluator.timetable_evaluator import TimetableEvaluator


class TestTimetableEvaluator(TestCase):
    def test_timetable_violation(self):
        term = copy.deepcopy(season_term)
        term['timetables'][0]['is_closed'] = True
        term['timetables'][1]['term_group_id'] = 1
        term['tutorial_pieces'][0]['date_index'] = 1
        term['tutorial_pieces'][0]['period_index'] = 1
        term['tutorial_pieces'][1]['date_index'] = 1
        term['tutorial_pieces'][1]['period_index'] = 2
        array_size = ArraySize(term)
        tutorial_occupation = TutorialOccupation(term, array_size)
        timetable = Timetable(term, array_size)
        evaluator = TimetableEvaluator(array_size, timetable.timetable_array())
        self.assertEqual(evaluator.violation_and_cost(
            tutorial_occupation.tutorial_occupation_array(),
        ), [2, 0])
