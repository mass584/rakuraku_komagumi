import numpy
from unittest import TestCase
from ..test_data.normal_term import normal_term
from ..test_data.season_term import season_term
from ..test_data.exam_planning_term import exam_planning_term
from src.array_builder.array_size import ArraySize
from src.array_builder.tutorial_piece_count import TutorialPieceCount


class TestTutorialPieceCount(TestCase):
    def test_normal_term(self):
        array_size = ArraySize(normal_term)
        tutorial_piece_count = TutorialPieceCount(normal_term, array_size)
        self.assertEqual(
            numpy.sum(tutorial_piece_count.tutorial_piece_count_array()), 60)

    def test_season_term(self):
        array_size = ArraySize(season_term)
        tutorial_piece_count = TutorialPieceCount(season_term, array_size)
        self.assertEqual(
            numpy.sum(tutorial_piece_count.tutorial_piece_count_array()), 240)

    def test_exam_planning_term(self):
        array_size = ArraySize(exam_planning_term)
        tutorial_piece_count = TutorialPieceCount(exam_planning_term, array_size)
        self.assertEqual(
            numpy.sum(tutorial_piece_count.tutorial_piece_count_array()), 20)
