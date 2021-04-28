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
        tutorial_occupation = TutorialOccupation(normal_term, array_size)
        self.assertEqual(numpy.sum(tutorial_occupation.tutorial_occupation()), 0)
        self.assertEqual(numpy.sum(tutorial_occupation.fixed_tutorial_occupation()), 0)
        self.assertEqual(numpy.sum(tutorial_occupation.floated_tutorial_occupation()), 0)

    def test_season_term(self):
        array_size = ArraySize(season_term)
        tutorial_occupation = TutorialOccupation(season_term, array_size)
        self.assertEqual(numpy.sum(tutorial_occupation.tutorial_occupation()), 0)
        self.assertEqual(numpy.sum(tutorial_occupation.fixed_tutorial_occupation()), 0)
        self.assertEqual(numpy.sum(tutorial_occupation.floated_tutorial_occupation()), 0)

    def test_exam_planning_term(self):
        array_size = ArraySize(exam_planning_term)
        tutorial_occupation = TutorialOccupation(exam_planning_term, array_size)
        self.assertEqual(numpy.sum(tutorial_occupation.tutorial_occupation()), 0)
        self.assertEqual(numpy.sum(tutorial_occupation.fixed_tutorial_occupation()), 0)
        self.assertEqual(numpy.sum(tutorial_occupation.floated_tutorial_occupation()), 0)
