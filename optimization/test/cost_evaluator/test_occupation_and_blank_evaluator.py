import copy
from unittest import TestCase
from test.test_data.normal_term import normal_term
from test.test_data.season_term import season_term
from test.test_data.exam_planning_term import exam_planning_term
from src.array_builder.array_size import ArraySize
from src.array_builder.tutorial_occupation import TutorialOccupation
from src.array_builder.group_occupation import GroupOccupation
from src.cost_evaluator.occupation_and_blank_evaluator import OccupationAndBlankEvaluator

class TestOccupationAndBlankEvaluator(TestCase):
    def test_occupation_and_blank_evaluator(self):
        term = copy.deepcopy(season_term)
        term['tutorial_pieces'][0]['date_index'] = 1
        term['tutorial_pieces'][0]['period_index'] = 1
        term['tutorial_pieces'][1]['date_index'] = 1
        term['tutorial_pieces'][1]['period_index'] = 2
        array_size = ArraySize(term)
        tutorial_occupation = TutorialOccupation(term, array_size)
        group_occupation = GroupOccupation(term, array_size)
        student_optimization_rule = term['student_optimization_rules'][0]
        teacher_optimization_rule = term['teacher_optimization_rule']
        occupation_and_blank_evaluator = OccupationAndBlankEvaluator(
            array_size,
            student_optimization_rule,
            teacher_optimization_rule)
        # 1日2コマ空きの日 teacher_index == 1 1日
        teacher_violation = 1
        # 1日2コマ空きの日 student_index == 1 1日, 1日4コマの日 student_index == 1 1日
        student_violation = 2
        # 1日2コマの日 teacher_index == 1 3日
        teacher_cost = 18 * 4 - 18
        # 1日2コマの日 student_index == 1 3日, student_index != 1 4日
        student_cost = array_size.student_count() * 14 * 4 - 14
        self.assertEqual(occupation_and_blank_evaluator.violation_and_cost(
            tutorial_occupation.tutorial_occupation(),
            group_occupation.teacher_occupation_array(),
            group_occupation.student_occupation_array(),
        ), [teacher_violation + student_violation, teacher_cost + student_cost])
