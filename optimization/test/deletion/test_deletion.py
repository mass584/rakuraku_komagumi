import copy
import numpy
from unittest import TestCase
from test.test_data.normal_term import normal_term
from test.test_data.season_term import season_term
from test.test_data.exam_planning_term import exam_planning_term
from src.array_builder.array_builder import ArrayBuilder
from src.cost_evaluator.cost_evaluator import CostEvaluator
from src.deletion.deletion import Deletion
from src.tutorial_piece_evaluator.tutorial_piece_evaluator import TutorialPieceEvaluator


class TestDeletion(TestCase):
    def test_deletion_result(self):
        term_object = copy.deepcopy(season_term)
        term_object['student_vacancies'][0]['is_vacant'] = False
        term_object['tutorial_pieces'][0]['date_index'] = 1
        term_object['tutorial_pieces'][0]['period_index'] = 1
        term_object['tutorial_pieces'][1]['date_index'] = 2
        term_object['tutorial_pieces'][1]['period_index'] = 1
        term_object['tutorial_pieces'][2]['date_index'] = 3
        term_object['tutorial_pieces'][2]['period_index'] = 1
        array_builder = ArrayBuilder(term_object=term_object)
        cost_evaluator = CostEvaluator(
            array_size=array_builder.array_size(),
            student_optimization_rules=term_object['student_optimization_rules'],
            teacher_optimization_rule=term_object['teacher_optimization_rules'][0],
            student_group_occupation=array_builder.student_group_occupation_array(),
            teacher_group_occupation=array_builder.teacher_group_occupation_array(),
            student_vacancy=array_builder.student_vacancy_array(),
            teacher_vacancy=array_builder.teacher_vacancy_array(),
            school_grades=array_builder.school_grade_array())
        tutorial_piece_evaluator = TutorialPieceEvaluator(
            array_size=array_builder.array_size(),
            student_optimization_rules=term_object['student_optimization_rules'],
            teacher_optimization_rule=term_object['teacher_optimization_rules'][0],
            student_group_occupation=array_builder.student_group_occupation_array(),
            teacher_group_occupation=array_builder.teacher_group_occupation_array(),
            student_vacancy=array_builder.student_vacancy_array(),
            teacher_vacancy=array_builder.teacher_vacancy_array(),
            school_grades=array_builder.school_grade_array())
        deletion = Deletion(
            term_object=term_object,
            tutorial_occupation_array=array_builder.tutorial_occupation_array(),
            fixed_tutorial_occupation_array=array_builder.fixed_tutorial_occupation_array(),
            tutorial_piece_count_array=array_builder.tutorial_piece_count_array(),
            cost_evaluator=cost_evaluator,
            tutorial_piece_evaluator=tutorial_piece_evaluator,
            optimization_log=None)
        tutorial_pieces_count_before = numpy.sum(
            array_builder.tutorial_occupation_array())
        deletion.execute()
        tutorial_pieces_count_after = numpy.sum(
            array_builder.tutorial_occupation_array())
        self.assertEqual(deletion.deleted_count(), 1)
        self.assertEqual(tutorial_pieces_count_before, 3)
        self.assertEqual(tutorial_pieces_count_after, 2)
