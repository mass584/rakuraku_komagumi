import copy
import numpy
from unittest import TestCase
from test.test_data.season_term import season_term
from src.array_builder.array_size import ArraySize
from src.array_builder.tutorial_occupation import TutorialOccupation
from src.tutorial_piece_evaluator.seat_occupation_evaluator \
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
        violation_array = numpy.zeros(
            (array_size.student_count(), array_size.teacher_count(), array_size.tutorial_count(),
            array_size.date_count(), array_size.period_count()),
            dtype=int)
        evaluator.get_violation_and_cost_array(
            tutorial_occupation.tutorial_occupation_array(), violation_array)
        self.assertEqual(violation_array[0, 0, 0, 0, 0], 0)
        self.assertEqual(violation_array[0, 0, 1, 0, 0], 0)
        self.assertEqual(violation_array[0, 0, 2, 0, 0], 0)
        self.assertEqual(numpy.sum(violation_array), 0)

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
        violation_array = numpy.zeros(
            (array_size.student_count(), array_size.teacher_count(), array_size.tutorial_count(),
            array_size.date_count(), array_size.period_count()),
            dtype=int)
        evaluator.get_violation_and_cost_array(
            tutorial_occupation.tutorial_occupation_array(), violation_array)
        self.assertEqual(violation_array[0, 0, 0, 0, 0], 1)
        self.assertEqual(violation_array[0, 1, 1, 0, 0], 1)
        self.assertEqual(violation_array[0, 2, 2, 0, 0], 1)
        self.assertEqual(numpy.sum(violation_array), 3)

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
        violation_array = numpy.zeros(
            (array_size.student_count(), array_size.teacher_count(), array_size.tutorial_count(),
            array_size.date_count(), array_size.period_count()),
            dtype=int)
        evaluator.get_violation_and_cost_array(
            tutorial_occupation.tutorial_occupation_array(), violation_array)
        self.assertEqual(violation_array[0, 0, 0, 0, 0], 2)
        self.assertEqual(violation_array[0, 1, 1, 0, 0], 2)
        self.assertEqual(violation_array[0, 2, 2, 0, 0], 2)
        self.assertEqual(violation_array[1, 3, 0, 0, 0], 2)
        self.assertEqual(numpy.sum(violation_array), 8)
