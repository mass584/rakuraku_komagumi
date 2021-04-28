import numpy
from unittest import TestCase
from test.test_data.normal_term import normal_term
from test.test_data.season_term import season_term
from test.test_data.exam_planning_term import exam_planning_term
from src.array_builder.array_size import ArraySize
from src.array_builder.tutorial_occupation import TutorialOccupation

class TestTutorialOccupation(TestCase):
    def test_normal_term(self):
        array_size = ArraySize(normal_term)
        normal_term['tutorial_pieces'][0]['date_index'] = 1
        normal_term['tutorial_pieces'][0]['period_index'] = 1
        normal_term['tutorial_pieces'][0]['is_fixed'] = False
        normal_term['tutorial_pieces'][1]['date_index'] = 2
        normal_term['tutorial_pieces'][1]['period_index'] = 2
        normal_term['tutorial_pieces'][1]['is_fixed'] = True
        tutorial_occupation = TutorialOccupation(normal_term, array_size)
        self.assertEqual(numpy.sum(tutorial_occupation.tutorial_occupation()), 2)
        self.assertEqual(numpy.sum(tutorial_occupation.fixed_tutorial_occupation()), 1)
        self.assertEqual(numpy.sum(tutorial_occupation.floated_tutorial_occupation()), 1)
        self.assertEqual(numpy.shape(tutorial_occupation.tutorial_occupation()), (20, 5, 5, 7, 6))
        self.assertEqual(numpy.shape(tutorial_occupation.fixed_tutorial_occupation()), (20, 5, 5, 7, 6))
        self.assertEqual(numpy.shape(tutorial_occupation.floated_tutorial_occupation()), (20, 5, 5, 7, 6))
        self.assertEqual((tutorial_occupation.tutorial_occupation())[0, 0, 0, 0, 0], 1)
        self.assertEqual((tutorial_occupation.tutorial_occupation())[0, 1, 1, 1, 1], 1)
        self.assertEqual((tutorial_occupation.floated_tutorial_occupation())[0, 0, 0, 0, 0], 1)
        self.assertEqual((tutorial_occupation.fixed_tutorial_occupation())[0, 1, 1, 1, 1], 1)

    def test_season_term(self):
        array_size = ArraySize(season_term)
        season_term['tutorial_pieces'][0]['date_index'] = 1
        season_term['tutorial_pieces'][0]['period_index'] = 1
        season_term['tutorial_pieces'][0]['is_fixed'] = False
        season_term['tutorial_pieces'][1]['date_index'] = 2
        season_term['tutorial_pieces'][1]['period_index'] = 2
        season_term['tutorial_pieces'][1]['is_fixed'] = True
        tutorial_occupation = TutorialOccupation(season_term, array_size)
        self.assertEqual(numpy.sum(tutorial_occupation.tutorial_occupation()), 2)
        self.assertEqual(numpy.sum(tutorial_occupation.fixed_tutorial_occupation()), 1)
        self.assertEqual(numpy.sum(tutorial_occupation.floated_tutorial_occupation()), 1)
        self.assertEqual(numpy.shape(tutorial_occupation.tutorial_occupation()), (20, 5, 5, 14, 6))
        self.assertEqual(numpy.shape(tutorial_occupation.fixed_tutorial_occupation()), (20, 5, 5, 14, 6))
        self.assertEqual(numpy.shape(tutorial_occupation.floated_tutorial_occupation()), (20, 5, 5, 14, 6))
        self.assertEqual((tutorial_occupation.tutorial_occupation())[0, 0, 0, 0, 0], 1)
        self.assertEqual((tutorial_occupation.tutorial_occupation())[0, 0, 0, 1, 1], 1)
        self.assertEqual((tutorial_occupation.floated_tutorial_occupation())[0, 0, 0, 0, 0], 1)
        self.assertEqual((tutorial_occupation.fixed_tutorial_occupation())[0, 0, 0, 1, 1], 1)

    def test_exam_planning_term(self):
        array_size = ArraySize(exam_planning_term)
        exam_planning_term['tutorial_pieces'][0]['date_index'] = 1
        exam_planning_term['tutorial_pieces'][0]['period_index'] = 1
        exam_planning_term['tutorial_pieces'][0]['is_fixed'] = False
        exam_planning_term['tutorial_pieces'][1]['date_index'] = 2
        exam_planning_term['tutorial_pieces'][1]['period_index'] = 2
        exam_planning_term['tutorial_pieces'][1]['is_fixed'] = True
        tutorial_occupation = TutorialOccupation(exam_planning_term, array_size)
        self.assertEqual(numpy.sum(tutorial_occupation.tutorial_occupation()), 2)
        self.assertEqual(numpy.sum(tutorial_occupation.fixed_tutorial_occupation()), 1)
        self.assertEqual(numpy.sum(tutorial_occupation.floated_tutorial_occupation()), 1)
        self.assertEqual(numpy.shape(tutorial_occupation.tutorial_occupation()), (10, 5, 5, 3, 4))
        self.assertEqual(numpy.shape(tutorial_occupation.fixed_tutorial_occupation()), (10, 5, 5, 3, 4))
        self.assertEqual(numpy.shape(tutorial_occupation.floated_tutorial_occupation()), (10, 5, 5, 3, 4))
        self.assertEqual((tutorial_occupation.tutorial_occupation())[0, 1, 1, 0, 0], 1)
        self.assertEqual((tutorial_occupation.tutorial_occupation())[0, 2, 2, 1, 1], 1)
        self.assertEqual((tutorial_occupation.floated_tutorial_occupation())[0, 1, 1, 0, 0], 1)
        self.assertEqual((tutorial_occupation.fixed_tutorial_occupation())[0, 2, 2, 1, 1], 1)
