import copy
from unittest import TestCase
from test.test_data.season_term import season_term
from src.array_builder.array_size import ArraySize
from src.array_builder.tutorial_occupation import TutorialOccupation
from src.array_builder.vacancy import Vacancy
from src.cost_evaluator.vacancy_and_double_booking_evaluator import VacancyAndDoubleBookingEvaluator


class TestVacancyAndDoubleBookingEvaluator(TestCase):
    def test_no_violation(self):
        term = copy.deepcopy(season_term)
        term['tutorial_pieces'][0]['date_index'] = 1
        term['tutorial_pieces'][0]['period_index'] = 1
        term['tutorial_pieces'][1]['date_index'] = 1
        term['tutorial_pieces'][1]['period_index'] = 2
        array_size = ArraySize(term)
        vacancy = Vacancy(term, array_size)
        tutorial_occupation = TutorialOccupation(term, array_size)
        evaluator = VacancyAndDoubleBookingEvaluator()
        self.assertEqual(evaluator.violation_and_cost(
            tutorial_occupation.tutorial_occupation(),
            vacancy.teacher_vacancy_array(),
            vacancy.student_vacancy_array(),
        ), [0, 0])

    def test_double_booking_violation(self):
        term = copy.deepcopy(season_term)
        term['tutorial_pieces'][0]['date_index'] = 1
        term['tutorial_pieces'][0]['period_index'] = 1
        term['tutorial_pieces'][0]['term_teacher_id'] = 1
        term['tutorial_pieces'][4]['date_index'] = 1
        term['tutorial_pieces'][4]['period_index'] = 1
        term['tutorial_pieces'][4]['term_teacher_id'] = 1
        term['tutorial_pieces'][8]['date_index'] = 1
        term['tutorial_pieces'][8]['period_index'] = 1
        term['tutorial_pieces'][8]['term_teacher_id'] = 1
        array_size = ArraySize(term)
        vacancy = Vacancy(term, array_size)
        tutorial_occupation = TutorialOccupation(term, array_size)
        evaluator = VacancyAndDoubleBookingEvaluator()
        self.assertEqual(evaluator.violation_and_cost(
            tutorial_occupation.tutorial_occupation(),
            vacancy.teacher_vacancy_array(),
            vacancy.student_vacancy_array(),
        ), [3, 0])

    def test_unvacant_violation(self):
        term = copy.deepcopy(season_term)
        term['student_vacancies'][0]['is_vacant'] = False
        term['teacher_vacancies'][0]['is_vacant'] = False
        term['tutorial_pieces'][0]['date_index'] = 1
        term['tutorial_pieces'][0]['period_index'] = 1
        array_size = ArraySize(term)
        vacancy = Vacancy(term, array_size)
        tutorial_occupation = TutorialOccupation(term, array_size)
        evaluator = VacancyAndDoubleBookingEvaluator()
        self.assertEqual(evaluator.violation_and_cost(
            tutorial_occupation.tutorial_occupation(),
            vacancy.teacher_vacancy_array(),
            vacancy.student_vacancy_array(),
        ), [2, 0])
