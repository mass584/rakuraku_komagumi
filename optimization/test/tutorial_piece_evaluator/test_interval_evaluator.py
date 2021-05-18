import copy
import numpy
from unittest import TestCase
from test.test_data.season_term import season_term
from src.array_builder.array_size import ArraySize
from src.array_builder.school_grade import SchoolGrade
from src.array_builder.tutorial_occupation import TutorialOccupation
from src.tutorial_piece_evaluator.interval_evaluator import IntervalEvaluator


class TestIntervalEvaluator(TestCase):
    def test_interval_is_zero(self):
        term = copy.deepcopy(season_term)
        term['tutorial_pieces'][0]['date_index'] = 1
        term['tutorial_pieces'][0]['period_index'] = 1
        term['tutorial_pieces'][1]['date_index'] = 1
        term['tutorial_pieces'][1]['period_index'] = 2
        array_size = ArraySize(term)
        tutorial_occupation = TutorialOccupation(term, array_size)
        school_grade = SchoolGrade(term, array_size)
        student_optimization_rules = term['student_optimization_rules']
        interval_evaluator = IntervalEvaluator(
            array_size=array_size,
            school_grades=school_grade.school_grade_array(),
            student_optimization_rules=student_optimization_rules)
        cost_array = numpy.zeros(
            (array_size.student_count(), array_size.teacher_count(), array_size.tutorial_count(),
             array_size.date_count(), array_size.period_count()),
            dtype=int)
        interval_evaluator.get_violation_and_cost_array(
            tutorial_occupation.tutorial_occupation_array(), cost_array)
        self.assertEqual(cost_array[0, 0, 0, 0, 0], 70)
        self.assertEqual(cost_array[0, 0, 0, 0, 1], 70)
        self.assertEqual(numpy.sum(cost_array), 140)

    def test_interval_is_cutoff(self):
        term = copy.deepcopy(season_term)
        term['tutorial_pieces'][0]['date_index'] = 1
        term['tutorial_pieces'][0]['period_index'] = 1
        term['tutorial_pieces'][1]['date_index'] = 3
        term['tutorial_pieces'][1]['period_index'] = 1
        array_size = ArraySize(term)
        tutorial_occupation = TutorialOccupation(term, array_size)
        school_grade = SchoolGrade(term, array_size)
        student_optimization_rules = term['student_optimization_rules']
        interval_evaluator = IntervalEvaluator(
            array_size=array_size,
            school_grades=school_grade.school_grade_array(),
            student_optimization_rules=student_optimization_rules)
        cost_array = numpy.zeros(
            (array_size.student_count(), array_size.teacher_count(), array_size.tutorial_count(),
             array_size.date_count(), array_size.period_count()),
            dtype=int)
        interval_evaluator.get_violation_and_cost_array(
            tutorial_occupation.tutorial_occupation_array(), cost_array)
        self.assertEqual(cost_array[0, 0, 0, 0, 0], 14)
        self.assertEqual(cost_array[0, 0, 0, 2, 0], 14)
        self.assertEqual(numpy.sum(cost_array), 28)

    def test_interval_is_over_cutoff(self):
        term = copy.deepcopy(season_term)
        term['tutorial_pieces'][0]['date_index'] = 1
        term['tutorial_pieces'][0]['period_index'] = 1
        term['tutorial_pieces'][1]['date_index'] = 4
        term['tutorial_pieces'][1]['period_index'] = 1
        array_size = ArraySize(term)
        tutorial_occupation = TutorialOccupation(term, array_size)
        school_grade = SchoolGrade(term, array_size)
        student_optimization_rules = term['student_optimization_rules']
        interval_evaluator = IntervalEvaluator(
            array_size=array_size,
            school_grades=school_grade.school_grade_array(),
            student_optimization_rules=student_optimization_rules)
        cost_array = numpy.zeros(
            (array_size.student_count(), array_size.teacher_count(), array_size.tutorial_count(),
             array_size.date_count(), array_size.period_count()),
            dtype=int)
        interval_evaluator.get_violation_and_cost_array(
            tutorial_occupation.tutorial_occupation_array(), cost_array)
        self.assertEqual(cost_array[0, 0, 0, 0, 0], 0)
        self.assertEqual(cost_array[0, 0, 0, 3, 0], 0)
        self.assertEqual(numpy.sum(cost_array), 0)
