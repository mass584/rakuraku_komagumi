import copy
import numpy
from unittest import TestCase
from test.test_data.normal_term import normal_term
from test.test_data.season_term import season_term
from test.test_data.exam_planning_term import exam_planning_term
from src.array_builder.array_size import ArraySize
from src.array_builder.timetable import Timetable


class TestTimetable(TestCase):
    def test_normal_term(self):
        term = copy.deepcopy(normal_term)
        array_size = ArraySize(term)
        term['timetables'][0]['is_closed'] = True
        term['timetables'][1]['term_group_id'] = 1
        timetable = Timetable(term, array_size)
        self.assertEqual(
            numpy.shape(timetable.timetable_array()), (7, 6))
        self.assertEqual(
            (timetable.timetable_array())[0, 0], 0)
        self.assertEqual(
            (timetable.timetable_array())[0, 1], 0)
        self.assertEqual(
            (timetable.timetable_array())[0, 2], 1)

    def test_season_term(self):
        term = copy.deepcopy(season_term)
        array_size = ArraySize(term)
        term['timetables'][0]['is_closed'] = True
        term['timetables'][1]['term_group_id'] = 1
        timetable = Timetable(term, array_size)
        self.assertEqual(
            numpy.shape(timetable.timetable_array()), (14, 6))
        self.assertEqual(
            (timetable.timetable_array())[0, 0], 0)
        self.assertEqual(
            (timetable.timetable_array())[0, 1], 0)
        self.assertEqual(
            (timetable.timetable_array())[0, 2], 1)

    def test_exam_planning_term(self):
        term = copy.deepcopy(exam_planning_term)
        array_size = ArraySize(term)
        term['timetables'][0]['is_closed'] = True
        term['timetables'][1]['term_group_id'] = 1
        timetable = Timetable(term, array_size)
        self.assertEqual(
            numpy.shape(timetable.timetable_array()), (3, 4))
        self.assertEqual(
            (timetable.timetable_array())[0, 0], 0)
        self.assertEqual(
            (timetable.timetable_array())[0, 1], 0)
        self.assertEqual(
            (timetable.timetable_array())[0, 2], 1)
