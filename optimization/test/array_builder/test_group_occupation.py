import numpy
from unittest import TestCase
from test.test_data.normal_term import normal_term
from test.test_data.season_term import season_term
from test.test_data.exam_planning_term import exam_planning_term
from src.array_builder.array_size import ArraySize
from src.array_builder.group_occupation import GroupOccupation

class TestGroupOccupation(TestCase):
    def test_normal_term(self):
        array_size = ArraySize(normal_term)
        group_occupation = GroupOccupation(normal_term, array_size)
        self.assertEqual(numpy.sum(group_occupation.teacher_occupation_array()), 2)
        self.assertEqual(numpy.sum(group_occupation.student_occupation_array()), 40)

    def test_season_term(self):
        array_size = ArraySize(season_term)
        group_occupation = GroupOccupation(season_term, array_size)
        self.assertEqual(numpy.sum(group_occupation.teacher_occupation_array()), 8)
        self.assertEqual(numpy.sum(group_occupation.student_occupation_array()), 160)

    def test_exam_planning_term(self):
        array_size = ArraySize(exam_planning_term)
        group_occupation = GroupOccupation(exam_planning_term, array_size)
        self.assertEqual(numpy.sum(group_occupation.teacher_occupation_array()), 2)
        self.assertEqual(numpy.sum(group_occupation.student_occupation_array()), 20)
