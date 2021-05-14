import copy
from unittest import TestCase
from test.test_data.season_term import season_term
from src.array_builder.array_builder import ArrayBuilder
from src.cost_evaluator.cost_evaluator import CostEvaluator


class TestCostEvaluator(TestCase):
    def test_cost_evaluator(self):
        term = copy.deepcopy(season_term)
        array_builder = ArrayBuilder(term_object=term)
        cost_evaluator = CostEvaluator(
            array_size=array_builder.array_size(),
            timetable=array_builder.timetable_array(),
            student_optimization_rules=term['student_optimization_rules'],
            teacher_optimization_rule=term['teacher_optimization_rule'],
            student_group_occupation=array_builder.student_group_occupation_array(),
            teacher_group_occupation=array_builder.teacher_group_occupation_array(),
            student_vacancy=array_builder.student_vacancy_array(),
            teacher_vacancy=array_builder.teacher_vacancy_array(),
            school_grades=array_builder.school_grade_array())
        self.assertEqual(cost_evaluator.cost(
            array_builder.tutorial_occupation_array()), 1192)
