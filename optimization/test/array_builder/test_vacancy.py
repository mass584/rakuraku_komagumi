import numpy
from unittest import TestCase
from test.test_data.normal_term import normal_term
from test.test_data.season_term import season_term
from test.test_data.exam_planning_term import exam_planning_term
from src.array_builder.array_size import ArraySize
from src.array_builder.vacancy import Vacancy

class TestTutorialOccupation(TestCase):
    def test_normal_term(self):
        array_size = ArraySize(normal_term)
        vacancy = Vacancy(normal_term, array_size)
        self.assertEqual(numpy.sum(vacancy.student_vacancy_array()), 840)
        self.assertEqual(numpy.sum(vacancy.teacher_vacancy_array()), 210)

    def test_season_term(self):
        array_size = ArraySize(season_term)
        vacancy = Vacancy(season_term, array_size)
        self.assertEqual(numpy.sum(vacancy.student_vacancy_array()), 1680)
        self.assertEqual(numpy.sum(vacancy.teacher_vacancy_array()), 420)

    def test_exam_planning_term(self):
        array_size = ArraySize(exam_planning_term)
        vacancy = Vacancy(exam_planning_term, array_size)
        self.assertEqual(numpy.sum(vacancy.student_vacancy_array()), 120)
        self.assertEqual(numpy.sum(vacancy.teacher_vacancy_array()), 60)
