import numpy
from unittest import TestCase
from ..test_data.normal_term import normal_term
from ..test_data.season_term import season_term
from ..test_data.exam_planning_term import exam_planning_term
from src.array_builder.array_size import ArraySize
from src.array_builder.tutorial_contract import TutorialContract


class TestTutorialContract(TestCase):
    def test_normal_term(self):
        array_size = ArraySize(normal_term)
        tutorial_contract = TutorialContract(normal_term, array_size)
        self.assertEqual(
            numpy.sum(tutorial_contract.tutorial_contract_array()), 60)

    def test_season_term(self):
        array_size = ArraySize(season_term)
        tutorial_contract = TutorialContract(season_term, array_size)
        self.assertEqual(
            numpy.sum(tutorial_contract.tutorial_contract_array()), 240)

    def test_exam_planning_term(self):
        array_size = ArraySize(exam_planning_term)
        tutorial_contract = TutorialContract(exam_planning_term, array_size)
        self.assertEqual(
            numpy.sum(tutorial_contract.tutorial_contract_array()), 20)
