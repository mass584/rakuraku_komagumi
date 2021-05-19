import copy
import numpy
from unittest import TestCase
from test.test_data.season_term import season_term
from src.array_builder.array_size import ArraySize
from src.array_builder.tutorial_occupation import TutorialOccupation
from src.array_builder.group_occupation import GroupOccupation
from src.array_builder.school_grade import SchoolGrade
from src.tutorial_piece_evaluator.occupation_and_blank_evaluator \
    import OccupationAndBlankEvaluator


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
        school_grade = SchoolGrade(term, array_size)
        student_optimization_rules = term['student_optimization_rules']
        teacher_optimization_rule = term['teacher_optimization_rule']
        occupation_and_blank_evaluator = OccupationAndBlankEvaluator(
            array_size=array_size,
            student_optimization_rules=student_optimization_rules,
            teacher_optimization_rule=teacher_optimization_rule,
            student_group_occupation=group_occupation.student_occupation_array(),
            teacher_group_occupation=group_occupation.teacher_occupation_array(),
            school_grades=school_grade.school_grade_array())
        violation_array = numpy.zeros(
            (array_size.student_count(), array_size.teacher_count(), array_size.tutorial_count(),
             array_size.date_count(), array_size.period_count()),
            dtype=int)
        cost_array = numpy.zeros(
            (array_size.student_count(), array_size.teacher_count(), array_size.tutorial_count(),
             array_size.date_count(), array_size.period_count()),
            dtype=int)
        occupation_and_blank_evaluator.get_violation_and_cost_array(
            tutorial_occupation.tutorial_occupation_array(),
            violation_array, cost_array)
        # 1日2コマ空きの日 teacher_index == 1 1日
        teacher_violation = 1
        # 1日2コマ空きの日 student_index == 1 1日, 1日4コマの日 student_index == 1 1日
        student_violation = 2
        self.assertEqual(
            violation_array[0, 0, 0, 0, 0], teacher_violation + student_violation)
        self.assertEqual(
            violation_array[0, 0, 0, 0, 1], teacher_violation + student_violation)
        self.assertEqual(
            numpy.sum(violation_array),
            (teacher_violation + student_violation) * 2)
        self.assertEqual(cost_array[0, 0, 0, 0, 0], 0)
        self.assertEqual(cost_array[0, 0, 0, 0, 1], 0)
        self.assertEqual(numpy.sum(cost_array), 0)
