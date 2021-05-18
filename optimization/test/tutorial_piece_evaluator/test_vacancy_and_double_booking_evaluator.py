import copy
import numpy
from unittest import TestCase
from test.test_data.season_term import season_term
from src.array_builder.array_size import ArraySize
from src.array_builder.tutorial_occupation import TutorialOccupation
from src.array_builder.vacancy import Vacancy
from src.tutorial_piece_evaluator.vacancy_and_double_booking_evaluator \
    import VacancyAndDoubleBookingEvaluator


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
        evaluator = VacancyAndDoubleBookingEvaluator(
            teacher_vacancy=vacancy.teacher_vacancy_array(),
            student_vacancy=vacancy.student_vacancy_array())
        violation_array = numpy.zeros(
            (array_size.student_count(), array_size.teacher_count(), array_size.tutorial_count(),
            array_size.date_count(), array_size.period_count()),
            dtype=int)
        evaluator.get_violation_and_cost_array(
            tutorial_occupation.tutorial_occupation_array(), violation_array)
        self.assertEqual(violation_array[0, 0, 0, 0, 0], 0)
        self.assertEqual(violation_array[0, 0, 0, 0, 1], 0)
        self.assertEqual(numpy.sum(violation_array), 0)

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
        evaluator = VacancyAndDoubleBookingEvaluator(
            teacher_vacancy=vacancy.teacher_vacancy_array(),
            student_vacancy=vacancy.student_vacancy_array())
        violation_array = numpy.zeros(
            (array_size.student_count(), array_size.teacher_count(), array_size.tutorial_count(),
            array_size.date_count(), array_size.period_count()),
            dtype=int)
        evaluator.get_violation_and_cost_array(
            tutorial_occupation.tutorial_occupation_array(), violation_array)
        self.assertEqual(violation_array[0, 0, 0, 0, 0], 3)
        self.assertEqual(violation_array[0, 0, 1, 0, 0], 3)
        self.assertEqual(violation_array[0, 0, 2, 0, 0], 3)
        self.assertEqual(numpy.sum(violation_array), 9)

    def test_unvacant_violation(self):
        term = copy.deepcopy(season_term)
        term['student_vacancies'][0]['is_vacant'] = False
        term['teacher_vacancies'][0]['is_vacant'] = False
        term['tutorial_pieces'][0]['date_index'] = 1
        term['tutorial_pieces'][0]['period_index'] = 1
        array_size = ArraySize(term)
        vacancy = Vacancy(term, array_size)
        tutorial_occupation = TutorialOccupation(term, array_size)
        evaluator = VacancyAndDoubleBookingEvaluator(
            teacher_vacancy=vacancy.teacher_vacancy_array(),
            student_vacancy=vacancy.student_vacancy_array())
        violation_array = numpy.zeros(
            (array_size.student_count(), array_size.teacher_count(), array_size.tutorial_count(),
            array_size.date_count(), array_size.period_count()),
            dtype=int)
        evaluator.get_violation_and_cost_array(
            tutorial_occupation.tutorial_occupation_array(), violation_array)
        self.assertEqual(violation_array[0, 0, 0, 0, 0], 1)
        self.assertEqual(numpy.sum(violation_array), 1)
