import copy
import numpy
from unittest import TestCase
from test.test_data.normal_term import normal_term
from test.test_data.season_term import season_term
from test.test_data.exam_planning_term import exam_planning_term
from src.array_builder.array_size import ArraySize
from src.array_builder.tutorial_occupation import TutorialOccupation


class TestTutorialOccupation(TestCase):
    def test_normal_term(self):
        term = copy.deepcopy(normal_term)
        array_size = ArraySize(term)
        term['tutorial_pieces'][0]['date_index'] = 1
        term['tutorial_pieces'][0]['period_index'] = 1
        term['tutorial_pieces'][0]['is_fixed'] = False
        term['tutorial_pieces'][1]['date_index'] = 2
        term['tutorial_pieces'][1]['period_index'] = 2
        term['tutorial_pieces'][1]['is_fixed'] = True
        tutorial_occupation = TutorialOccupation(term, array_size)
        self.assertEqual(
            numpy.sum(tutorial_occupation.tutorial_occupation_array()), 2)
        self.assertEqual(
            numpy.sum(tutorial_occupation.fixed_tutorial_occupation_array()), 1)
        self.assertEqual(
            numpy.sum(tutorial_occupation.floated_tutorial_occupation_array()), 1)
        self.assertEqual(
            numpy.shape(tutorial_occupation.tutorial_occupation_array()),
            (20, 5, 5, 7, 6))
        self.assertEqual(
            numpy.shape(tutorial_occupation.fixed_tutorial_occupation_array()),
            (20, 5, 5, 7, 6))
        self.assertEqual(
            numpy.shape(tutorial_occupation.floated_tutorial_occupation_array()),
            (20, 5, 5, 7, 6))
        self.assertEqual(
            (tutorial_occupation.tutorial_occupation_array())[0, 0, 0, 0, 0], 1)
        self.assertEqual(
            (tutorial_occupation.tutorial_occupation_array())[0, 1, 1, 1, 1], 1)
        self.assertEqual(
            (tutorial_occupation.floated_tutorial_occupation_array())[
                0, 0, 0, 0, 0], 1)
        self.assertEqual(
            (tutorial_occupation.fixed_tutorial_occupation_array())[
                0, 1, 1, 1, 1], 1)

    def test_season_term(self):
        term = copy.deepcopy(season_term)
        array_size = ArraySize(term)
        term['tutorial_pieces'][0]['date_index'] = 1
        term['tutorial_pieces'][0]['period_index'] = 1
        term['tutorial_pieces'][0]['is_fixed'] = False
        term['tutorial_pieces'][1]['date_index'] = 2
        term['tutorial_pieces'][1]['period_index'] = 2
        term['tutorial_pieces'][1]['is_fixed'] = True
        tutorial_occupation = TutorialOccupation(term, array_size)
        self.assertEqual(
            numpy.sum(tutorial_occupation.tutorial_occupation_array()), 2)
        self.assertEqual(
            numpy.sum(tutorial_occupation.fixed_tutorial_occupation_array()), 1)
        self.assertEqual(
            numpy.sum(tutorial_occupation.floated_tutorial_occupation_array()), 1)
        self.assertEqual(
            numpy.shape(tutorial_occupation.tutorial_occupation_array()),
            (20, 5, 5, 14, 6))
        self.assertEqual(
            numpy.shape(tutorial_occupation.fixed_tutorial_occupation_array()),
            (20, 5, 5, 14, 6))
        self.assertEqual(
            numpy.shape(tutorial_occupation.floated_tutorial_occupation_array()),
            (20, 5, 5, 14, 6))
        self.assertEqual(
            (tutorial_occupation.tutorial_occupation_array())[0, 0, 0, 0, 0], 1)
        self.assertEqual(
            (tutorial_occupation.tutorial_occupation_array())[0, 0, 0, 1, 1], 1)
        self.assertEqual(
            (tutorial_occupation.floated_tutorial_occupation_array())[
                0, 0, 0, 0, 0], 1)
        self.assertEqual(
            (tutorial_occupation.fixed_tutorial_occupation_array())[
                0, 0, 0, 1, 1], 1)

    def test_exam_planning_term(self):
        term = copy.deepcopy(exam_planning_term)
        array_size = ArraySize(term)
        term['tutorial_pieces'][0]['date_index'] = 1
        term['tutorial_pieces'][0]['period_index'] = 1
        term['tutorial_pieces'][0]['is_fixed'] = False
        term['tutorial_pieces'][1]['date_index'] = 2
        term['tutorial_pieces'][1]['period_index'] = 2
        term['tutorial_pieces'][1]['is_fixed'] = True
        tutorial_occupation = TutorialOccupation(term, array_size)
        self.assertEqual(
            numpy.sum(tutorial_occupation.tutorial_occupation_array()), 2)
        self.assertEqual(
            numpy.sum(tutorial_occupation.fixed_tutorial_occupation_array()), 1)
        self.assertEqual(
            numpy.sum(tutorial_occupation.floated_tutorial_occupation_array()), 1)
        self.assertEqual(
            numpy.shape(tutorial_occupation.tutorial_occupation_array()),
            (10, 5, 5, 3, 4))
        self.assertEqual(
            numpy.shape(tutorial_occupation.fixed_tutorial_occupation_array()),
            (10, 5, 5, 3, 4))
        self.assertEqual(
            numpy.shape(tutorial_occupation.floated_tutorial_occupation_array()),
            (10, 5, 5, 3, 4))
        self.assertEqual(
            (tutorial_occupation.tutorial_occupation_array())[0, 1, 1, 0, 0], 1)
        self.assertEqual(
            (tutorial_occupation.tutorial_occupation_array())[0, 2, 2, 1, 1], 1)
        self.assertEqual(
            (tutorial_occupation.floated_tutorial_occupation_array())[
                0, 1, 1, 0, 0], 1)
        self.assertEqual(
            (tutorial_occupation.fixed_tutorial_occupation_array())[
                0, 2, 2, 1, 1], 1)
