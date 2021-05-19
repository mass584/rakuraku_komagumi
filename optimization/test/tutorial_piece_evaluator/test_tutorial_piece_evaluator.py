import copy
from unittest import TestCase
from test.test_data.season_term import season_term
from src.array_builder.array_builder import ArrayBuilder
from src.array_builder.array_size import ArraySize
from src.array_builder.tutorial_occupation import TutorialOccupation
from src.tutorial_piece_evaluator.tutorial_piece_evaluator import TutorialPieceEvaluator


class TestCostEvaluator(TestCase):
    def test_cost_evaluator(self):
        term = copy.deepcopy(season_term)
        term['tutorial_pieces'][0]['date_index'] = 2
        term['tutorial_pieces'][0]['period_index'] = 1
        term['tutorial_pieces'][1]['date_index'] = 3
        term['tutorial_pieces'][1]['period_index'] = 1
        term['tutorial_pieces'][2]['date_index'] = 3
        term['tutorial_pieces'][2]['period_index'] = 4
        term['student_vacancies'][12]['is_vacant'] = False
        array_builder = ArrayBuilder(term)
        array_size = ArraySize(term)
        evaluator = TutorialPieceEvaluator(
            array_size=array_builder.array_size(),
            student_optimization_rules=term['student_optimization_rules'],
            teacher_optimization_rule=term['teacher_optimization_rule'],
            student_group_occupation=array_builder.student_group_occupation_array(),
            teacher_group_occupation=array_builder.teacher_group_occupation_array(),
            student_vacancy=array_builder.student_vacancy_array(),
            teacher_vacancy=array_builder.teacher_vacancy_array(),
            school_grades=array_builder.school_grade_array())
        tutorial_occupation = TutorialOccupation(term, array_size)
        evaluator.get_violation_and_cost_array(
            tutorial_occupation.tutorial_occupation_array())
        self.assertEqual(
            evaluator.get_nth_tutorial_piece_indexes_from_worst(0), [
                0, 0, 0, 2, 0])
        self.assertEqual(
            evaluator.get_nth_tutorial_piece_indexes_from_worst(1), [
                0, 0, 0, 2, 3])
        self.assertEqual(
            evaluator.get_nth_tutorial_piece_indexes_from_worst(2), [
                0, 0, 0, 1, 0])
        self.assertEqual(
            evaluator.get_nth_tutorial_piece_violation_and_cost_from_worst(0), [
                3, 100 + 18 + 14 + 105])
        self.assertEqual(
            evaluator.get_nth_tutorial_piece_violation_and_cost_from_worst(1), [
                2, 100 + 18 + 14 + 105])
        self.assertEqual(
            evaluator.get_nth_tutorial_piece_violation_and_cost_from_worst(2), [
                0, 100 + 30 + 105])
