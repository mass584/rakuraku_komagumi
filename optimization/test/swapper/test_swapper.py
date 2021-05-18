import copy
import numpy
from unittest import TestCase
from test.test_data.normal_term import normal_term
from test.test_data.season_term import season_term
from test.test_data.exam_planning_term import exam_planning_term
from src.array_builder.array_builder import ArrayBuilder
from src.installer.installer import Installer
from src.swapper.swapper import Swapper


class TestSwapper(TestCase):
    def test_normal_term_installer(self):
        term_object = copy.deepcopy(normal_term)
        array_builder = ArrayBuilder(term_object=term_object)
        installer = Installer(
            term_object=term_object,
            array_builder=array_builder,
            student_optimization_rules=term_object['student_optimization_rules'],
            teacher_optimization_rule=term_object['teacher_optimization_rule'])
        installer.execute()
        swapper = Swapper(
            term_object=term_object,
            array_builder=array_builder,
            student_optimization_rules=term_object['student_optimization_rules'],
            teacher_optimization_rule=term_object['teacher_optimization_rule'])
        swapper.execute()
        tutorial_occupation_array = swapper.tutorial_occupation_array()
        tutorial_occupation_sum = numpy.sum(tutorial_occupation_array)
        self.assertEqual(tutorial_occupation_sum, 60)

    def test_normal_term_installer_on_additional(self):
        term_object = copy.deepcopy(normal_term)
        # 生徒1を手動で設定済み
        term_object['tutorial_pieces'][0]['date_index'] = 1
        term_object['tutorial_pieces'][0]['period_index'] = 1
        term_object['tutorial_pieces'][1]['date_index'] = 2
        term_object['tutorial_pieces'][1]['period_index'] = 1
        term_object['tutorial_pieces'][2]['date_index'] = 3
        term_object['tutorial_pieces'][2]['period_index'] = 1
        array_builder = ArrayBuilder(term_object=term_object)
        installer = Installer(
            term_object=term_object,
            array_builder=array_builder,
            student_optimization_rules=term_object['student_optimization_rules'],
            teacher_optimization_rule=term_object['teacher_optimization_rule'])
        installer.execute()
        swapper = Swapper(
            term_object=term_object,
            array_builder=array_builder,
            student_optimization_rules=term_object['student_optimization_rules'],
            teacher_optimization_rule=term_object['teacher_optimization_rule'])
        swapper.execute()
        tutorial_occupation_array = swapper.tutorial_occupation_array()
        tutorial_occupation_sum = numpy.sum(tutorial_occupation_array)
        self.assertEqual(tutorial_occupation_sum, 60)

    def test_season_term_installer(self):
        term_object = copy.deepcopy(season_term)
        array_builder = ArrayBuilder(term_object=term_object)
        installer = Installer(
            term_object=term_object,
            array_builder=array_builder,
            student_optimization_rules=term_object['student_optimization_rules'],
            teacher_optimization_rule=term_object['teacher_optimization_rule'])
        installer.execute()
        swapper = Swapper(
            term_object=term_object,
            array_builder=array_builder,
            student_optimization_rules=term_object['student_optimization_rules'],
            teacher_optimization_rule=term_object['teacher_optimization_rule'])
        swapper.execute()
        tutorial_occupation_array = swapper.tutorial_occupation_array()
        tutorial_occupation_sum = numpy.sum(tutorial_occupation_array)
        self.assertEqual(tutorial_occupation_sum, 240)

    def test_season_term_installer_on_additional(self):
        term_object = copy.deepcopy(season_term)
        # 生徒1の国語を手動で設定済み
        term_object['tutorial_pieces'][0]['date_index'] = 1
        term_object['tutorial_pieces'][0]['period_index'] = 1
        term_object['tutorial_pieces'][1]['date_index'] = 2
        term_object['tutorial_pieces'][1]['period_index'] = 1
        term_object['tutorial_pieces'][2]['date_index'] = 3
        term_object['tutorial_pieces'][2]['period_index'] = 1
        term_object['tutorial_pieces'][3]['date_index'] = 4
        term_object['tutorial_pieces'][3]['period_index'] = 1
        array_builder = ArrayBuilder(term_object=term_object)
        installer = Installer(
            term_object=term_object,
            array_builder=array_builder,
            student_optimization_rules=term_object['student_optimization_rules'],
            teacher_optimization_rule=term_object['teacher_optimization_rule'])
        installer.execute()
        swapper = Swapper(
            term_object=term_object,
            array_builder=array_builder,
            student_optimization_rules=term_object['student_optimization_rules'],
            teacher_optimization_rule=term_object['teacher_optimization_rule'])
        swapper.execute()
        tutorial_occupation_array = swapper.tutorial_occupation_array()
        tutorial_occupation_sum = numpy.sum(tutorial_occupation_array)
        self.assertEqual(tutorial_occupation_sum, 240)

    def test_exam_planning_term_installer(self):
        term_object = copy.deepcopy(exam_planning_term)
        array_builder = ArrayBuilder(term_object=term_object)
        installer = Installer(
            term_object=term_object,
            array_builder=array_builder,
            student_optimization_rules=term_object['student_optimization_rules'],
            teacher_optimization_rule=term_object['teacher_optimization_rule'])
        installer.execute()
        swapper = Swapper(
            term_object=term_object,
            array_builder=array_builder,
            student_optimization_rules=term_object['student_optimization_rules'],
            teacher_optimization_rule=term_object['teacher_optimization_rule'])
        swapper.execute()
        tutorial_occupation_array = swapper.tutorial_occupation_array()
        tutorial_occupation_sum = numpy.sum(tutorial_occupation_array)
        self.assertEqual(tutorial_occupation_sum, 20)

    def test_exam_planning_term_installer_on_additional(self):
        term_object = copy.deepcopy(exam_planning_term)
        # 生徒1を手動で設定済み
        term_object['tutorial_pieces'][0]['date_index'] = 1
        term_object['tutorial_pieces'][0]['period_index'] = 1
        term_object['tutorial_pieces'][1]['date_index'] = 2
        term_object['tutorial_pieces'][1]['period_index'] = 1
        array_builder = ArrayBuilder(term_object=term_object)
        installer = Installer(
            term_object=term_object,
            array_builder=array_builder,
            student_optimization_rules=term_object['student_optimization_rules'],
            teacher_optimization_rule=term_object['teacher_optimization_rule'])
        installer.execute()
        swapper = Swapper(
            term_object=term_object,
            array_builder=array_builder,
            student_optimization_rules=term_object['student_optimization_rules'],
            teacher_optimization_rule=term_object['teacher_optimization_rule'])
        swapper.execute()
        tutorial_occupation_array = swapper.tutorial_occupation_array()
        tutorial_occupation_sum = numpy.sum(tutorial_occupation_array)
        self.assertEqual(tutorial_occupation_sum, 20)
