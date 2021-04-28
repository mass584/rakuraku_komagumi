import numpy
from unittest import TestCase
from test.test_data.normal_term import normal_term
from test.test_data.season_term import season_term
from test.test_data.exam_planning_term import exam_planning_term
from src.array_builder.array_size import ArraySize
from src.array_builder.vacancy import Vacancy

class TestTutorialOccupation(TestCase):
    def test_normal_term(self):
        normal_term['student_vacancies'][0]['is_vacant'] = 0
        normal_term['teacher_vacancies'][0]['is_vacant'] = 0
        array_size = ArraySize(normal_term)
        vacancy = Vacancy(normal_term, array_size)
        self.assertEqual(numpy.sum(vacancy.student_vacancy_array()), 840 - 1)
        self.assertEqual(numpy.sum(vacancy.teacher_vacancy_array()), 210 - 1)
        self.assertEqual(numpy.shape(vacancy.student_vacancy_array()), (20, 7, 6))
        self.assertEqual(numpy.shape(vacancy.teacher_vacancy_array()), (5, 7, 6))
        self.assertEqual(vacancy.student_vacancy_array()[0, 0, 0], 0)
        self.assertEqual(vacancy.teacher_vacancy_array()[0, 0, 0], 0)

    def test_season_term(self):
        season_term['student_vacancies'][0]['is_vacant'] = 0
        season_term['teacher_vacancies'][0]['is_vacant'] = 0
        array_size = ArraySize(season_term)
        vacancy = Vacancy(season_term, array_size)
        self.assertEqual(numpy.sum(vacancy.student_vacancy_array()), 1680 - 1)
        self.assertEqual(numpy.sum(vacancy.teacher_vacancy_array()), 420 - 1)
        self.assertEqual(numpy.shape(vacancy.student_vacancy_array()), (20, 14, 6))
        self.assertEqual(numpy.shape(vacancy.teacher_vacancy_array()), (5, 14, 6))
        self.assertEqual(vacancy.student_vacancy_array()[0, 0, 0], 0)
        self.assertEqual(vacancy.teacher_vacancy_array()[0, 0, 0], 0)

    def test_exam_planning_term(self):
        exam_planning_term['student_vacancies'][0]['is_vacant'] = 0
        exam_planning_term['teacher_vacancies'][0]['is_vacant'] = 0
        array_size = ArraySize(exam_planning_term)
        vacancy = Vacancy(exam_planning_term, array_size)
        self.assertEqual(numpy.sum(vacancy.student_vacancy_array()), 120 - 1)
        self.assertEqual(numpy.sum(vacancy.teacher_vacancy_array()), 60 - 1)
        self.assertEqual(numpy.shape(vacancy.student_vacancy_array()), (10, 3, 4))
        self.assertEqual(numpy.shape(vacancy.teacher_vacancy_array()), (5, 3, 4))
        self.assertEqual(vacancy.student_vacancy_array()[0, 0, 0], 0)
        self.assertEqual(vacancy.teacher_vacancy_array()[0, 0, 0], 0)
