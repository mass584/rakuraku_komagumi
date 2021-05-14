import copy
import numpy
from unittest import TestCase
from test.test_data.normal_term import normal_term
from test.test_data.season_term import season_term
from test.test_data.exam_planning_term import exam_planning_term
from src.array_builder.array_builder import ArrayBuilder
from src.installer.installer import Installer


class TestInstaller(TestCase):
    def test_normal_term_installer(self):
        term_object = copy.deepcopy(normal_term)
        array_builder = ArrayBuilder(term_object=term_object)
        installer = Installer(
            term_object=term_object,
            array_builder=array_builder,
            student_optimization_rules=term_object['student_optimization_rules'],
            teacher_optimization_rule=term_object['teacher_optimization_rule'])
        installer.execute()
        tutorial_occupation_array = installer.tutorial_occupation_array()
        tutorial_occupation_sum = numpy.sum(tutorial_occupation_array)
        tutorial_occupation_sum_per_student = numpy.einsum('ijklm->i', tutorial_occupation_array)
        self.assertEqual(tutorial_occupation_sum, 60)
        self.assertEqual(installer.installed_count(), 60)
        numpy.testing.assert_equal(tutorial_occupation_sum_per_student, numpy.ones(20) * 3)

    def test_season_term_installer(self):
        term_object = copy.deepcopy(season_term)
        array_builder = ArrayBuilder(term_object=term_object)
        installer = Installer(
            term_object=term_object,
            array_builder=array_builder,
            student_optimization_rules=term_object['student_optimization_rules'],
            teacher_optimization_rule=term_object['teacher_optimization_rule'])
        installer.execute()
        tutorial_occupation_array = installer.tutorial_occupation_array()
        tutorial_occupation_sum = numpy.sum(tutorial_occupation_array)
        tutorial_occupation_sum_per_student = numpy.einsum('ijklm->i', tutorial_occupation_array)
        self.assertEqual(tutorial_occupation_sum, 240)
        self.assertEqual(installer.installed_count(), 240)
        numpy.testing.assert_equal(tutorial_occupation_sum_per_student, numpy.ones(20) * 12)

    def test_exam_planning_term_installer(self):
        term_object = copy.deepcopy(exam_planning_term)
        array_builder = ArrayBuilder(term_object=term_object)
        installer = Installer(
            term_object=term_object,
            array_builder=array_builder,
            student_optimization_rules=term_object['student_optimization_rules'],
            teacher_optimization_rule=term_object['teacher_optimization_rule'])
        installer.execute()
        tutorial_occupation_array = installer.tutorial_occupation_array()
        tutorial_occupation_sum = numpy.sum(tutorial_occupation_array)
        tutorial_occupation_sum_per_student = numpy.einsum('ijklm->i', tutorial_occupation_array)
        self.assertEqual(tutorial_occupation_sum, 20)
        self.assertEqual(installer.installed_count(), 20)
        numpy.testing.assert_equal(tutorial_occupation_sum_per_student, numpy.ones(10) * 2)
