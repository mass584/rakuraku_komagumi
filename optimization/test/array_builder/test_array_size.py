from unittest import TestCase
from test.test_data.normal_term import normal_term
from test.test_data.season_term import season_term
from test.test_data.exam_planning_term import exam_planning_term
from src.array_builder.array_size import ArraySize

class TestArraySize(TestCase):
    def test_normal_term(self):
        array_builder = ArraySize(normal_term)
        self.assertEqual(array_builder.student_count(), 20)
        self.assertEqual(array_builder.teacher_count(), 5)
        self.assertEqual(array_builder.tutorial_count(), 5)
        self.assertEqual(array_builder.group_count(), 2)
        self.assertEqual(array_builder.date_count(), 7)
        self.assertEqual(array_builder.period_count(), 6)
        self.assertEqual(array_builder.seat_count(), 7)

    def test_season_term(self):
        array_builder = ArraySize(season_term)
        self.assertEqual(array_builder.student_count(), 20)
        self.assertEqual(array_builder.teacher_count(), 5)
        self.assertEqual(array_builder.tutorial_count(), 5)
        self.assertEqual(array_builder.group_count(), 2)
        self.assertEqual(array_builder.date_count(), 14)
        self.assertEqual(array_builder.period_count(), 6)
        self.assertEqual(array_builder.seat_count(), 7)

    def test_exam_planning_term(self):
        array_builder = ArraySize(exam_planning_term)
        self.assertEqual(array_builder.student_count(), 10)
        self.assertEqual(array_builder.teacher_count(), 5)
        self.assertEqual(array_builder.tutorial_count(), 5)
        self.assertEqual(array_builder.group_count(), 2)
        self.assertEqual(array_builder.date_count(), 3)
        self.assertEqual(array_builder.period_count(), 4)
        self.assertEqual(array_builder.seat_count(), 7)
