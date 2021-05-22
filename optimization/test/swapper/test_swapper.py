import copy
import numpy
from unittest import TestCase
from test.test_data.season_term import season_term
from src.array_builder.array_builder import ArrayBuilder
from src.cost_evaluator.cost_evaluator import CostEvaluator
from src.swapper.swapper import Swapper
from src.tutorial_piece_evaluator.tutorial_piece_evaluator import TutorialPieceEvaluator


class TestSwapper(TestCase):
    def test_swapper_on_unfixed_state(self):
        term_object = copy.deepcopy(season_term)
        term_object['tutorial_pieces'][0]['date_index'] = 1
        term_object['tutorial_pieces'][0]['period_index'] = 1
        term_object['tutorial_pieces'][1]['date_index'] = 2
        term_object['tutorial_pieces'][1]['period_index'] = 1
        term_object['tutorial_pieces'][2]['date_index'] = 3
        term_object['tutorial_pieces'][2]['period_index'] = 1
        term_object['tutorial_pieces'][3]['date_index'] = 4
        term_object['tutorial_pieces'][3]['period_index'] = 1
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
        swapper = Swapper(
            process_count=4,
            term_object=term_object,
            array_size=array_builder.array_size(),
            timetable_array=array_builder.timetable_array(),
            tutorial_occupation_array=array_builder.tutorial_occupation_array(),
            fixed_tutorial_occupation_array=array_builder.fixed_tutorial_occupation_array(),
            tutorial_piece_count_array=array_builder.tutorial_piece_count_array(),
            cost_evaluator=cost_evaluator,
            tutorial_piece_evaluator=tutorial_piece_evaluator,
            optimization_log=None)
        swapper.execute()
        tutorial_occupation_array = swapper.tutorial_occupation_array()
        tutorial_occupation_sum = numpy.sum(tutorial_occupation_array)
        self.assertEqual(tutorial_occupation_sum, 4)
        self.assertEqual(swapper.swap_count(), 4)

    def test_swapper_on_fixed_state(self):
        term_object = copy.deepcopy(season_term)
        term_object['tutorial_pieces'][0]['date_index'] = 1
        term_object['tutorial_pieces'][0]['period_index'] = 1
        term_object['tutorial_pieces'][0]['is_fixed'] = True
        term_object['tutorial_pieces'][1]['date_index'] = 2
        term_object['tutorial_pieces'][1]['period_index'] = 1
        term_object['tutorial_pieces'][1]['is_fixed'] = True
        term_object['tutorial_pieces'][2]['date_index'] = 3
        term_object['tutorial_pieces'][2]['period_index'] = 1
        term_object['tutorial_pieces'][2]['is_fixed'] = True
        term_object['tutorial_pieces'][3]['date_index'] = 4
        term_object['tutorial_pieces'][3]['period_index'] = 1
        term_object['tutorial_pieces'][3]['is_fixed'] = True
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
        swapper = Swapper(
            process_count=4,
            term_object=term_object,
            array_size=array_builder.array_size(),
            timetable_array=array_builder.timetable_array(),
            tutorial_occupation_array=array_builder.tutorial_occupation_array(),
            fixed_tutorial_occupation_array=array_builder.fixed_tutorial_occupation_array(),
            tutorial_piece_count_array=array_builder.tutorial_piece_count_array(),
            cost_evaluator=cost_evaluator,
            tutorial_piece_evaluator=tutorial_piece_evaluator,
            optimization_log=None)
        swapper.execute()
        tutorial_occupation_array = swapper.tutorial_occupation_array()
        tutorial_occupation_sum = numpy.sum(tutorial_occupation_array)
        self.assertEqual(tutorial_occupation_array[0, 0, 0, 0, 0], 1)
        self.assertEqual(tutorial_occupation_array[0, 0, 0, 1, 0], 1)
        self.assertEqual(tutorial_occupation_array[0, 0, 0, 2, 0], 1)
        self.assertEqual(tutorial_occupation_array[0, 0, 0, 3, 0], 1)
        self.assertEqual(tutorial_occupation_sum, 4)
        self.assertEqual(swapper.swap_count(), 1)
