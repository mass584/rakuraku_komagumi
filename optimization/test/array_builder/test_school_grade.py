import copy
import numpy
from unittest import TestCase
from test.test_data.season_term import season_term
from src.array_builder.array_size import ArraySize
from src.array_builder.school_grade import SchoolGrade


class TestSchoolGrade(TestCase):
    def test_season_term(self):
        term = copy.deepcopy(season_term)
        array_size = ArraySize(term)
        school_grade = SchoolGrade(term, array_size)
        self.assertEqual(
            list(school_grade.school_grade_array()),
            [23 for grade in range(20)])
