import copy
from unittest import TestCase
from ..test_data.season_term import season_term
from src.array_builder.array_size import ArraySize
from src.array_builder.school_grade import SchoolGrade
from src.array_builder.tutorial_occupation import TutorialOccupation
from src.cost_evaluator.interval_evaluator import IntervalEvaluator


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
        self.assertEqual(interval_evaluator.violation_and_cost(
            tutorial_occupation.tutorial_occupation_array()), [0, 70])

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
        self.assertEqual(interval_evaluator.violation_and_cost(
            tutorial_occupation.tutorial_occupation_array()), [0, 14])

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
        self.assertEqual(interval_evaluator.violation_and_cost(
            tutorial_occupation.tutorial_occupation_array()), [0, 0])
