import copy
import numpy
from unittest import TestCase
from test.test_data.normal_term import normal_term
from test.test_data.season_term import season_term
from test.test_data.exam_planning_term import exam_planning_term
from src.array_builder.array_size import ArraySize
from src.array_builder.school_grade import SchoolGrade


class TestSchoolGrade(TestCase):
    def test_normal_term(self):
        term = copy.deepcopy(normal_term)
        array_size = ArraySize(term)
        school_grade = SchoolGrade(term, array_size)
        self.assertEqual(
            list(school_grade.school_grade_array()),
            ['j3' for _ in range(20)])

    def test_season_term(self):
        term = copy.deepcopy(season_term)
        array_size = ArraySize(term)
        school_grade = SchoolGrade(term, array_size)
        self.assertEqual(
            list(school_grade.school_grade_array()),
            ['j3' for _ in range(20)])

    def test_exam_planning_term(self):
        term = copy.deepcopy(exam_planning_term)
        array_size = ArraySize(term)
        school_grade = SchoolGrade(term, array_size)
        self.assertEqual(
            list(school_grade.school_grade_array()),
            ['j3' for _ in range(10)])
