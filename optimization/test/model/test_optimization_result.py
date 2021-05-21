import copy
from unittest import TestCase
from test.test_data.normal_term import normal_term
from test.test_data.season_term import season_term
from test.test_data.exam_planning_term import exam_planning_term
from src.array_builder.array_builder import ArrayBuilder
from src.model.optimization_result import OptimizationResult
from src.http.update_optimization_result import UpdateOptimizationResult


class TestOptimizationResult(TestCase):
    def test_normal_term(self):
        term_object = copy.deepcopy(normal_term)
        term_object['tutorial_pieces'][0]['date_index'] = 1
        term_object['tutorial_pieces'][0]['period_index'] = 1
        array_builder = ArrayBuilder(term_object=term_object)
        update_optimization_result = UpdateOptimizationResult(
            token='token', domain='domain', term_id=1)
        optimization_result = OptimizationResult(
            update_optimization_result=update_optimization_result,
            term_object=term_object,
            array_size=array_builder.array_size(),
            tutorial_occupation_array=array_builder.tutorial_occupation_array())
        tutorial_pieces = optimization_result.tutorial_pieces()
        seats = optimization_result.seats()
        installed_tutorial_pieces_count = len([
            tutorial_piece for tutorial_piece in tutorial_pieces
            if tutorial_piece['is_fixed'] != None])
        installed_seats_count = len([
            seat for seat in seats
            if seat['term_teacher_id'] != None])
        self.assertEqual(installed_tutorial_pieces_count, 1)
        self.assertEqual(installed_seats_count, 1)

    def test_season_term(self):
        term_object = copy.deepcopy(season_term)
        term_object['tutorial_pieces'][0]['date_index'] = 1
        term_object['tutorial_pieces'][0]['period_index'] = 1
        array_builder = ArrayBuilder(term_object=term_object)
        update_optimization_result = UpdateOptimizationResult(
            token='token', domain='domain', term_id=1)
        optimization_result = OptimizationResult(
            update_optimization_result=update_optimization_result,
            term_object=term_object,
            array_size=array_builder.array_size(),
            tutorial_occupation_array=array_builder.tutorial_occupation_array())
        tutorial_pieces = optimization_result.tutorial_pieces()
        seats = optimization_result.seats()
        installed_tutorial_pieces_count = len([
            tutorial_piece for tutorial_piece in tutorial_pieces
            if tutorial_piece['is_fixed'] != None])
        installed_seats_count = len([
            seat for seat in seats
            if seat['term_teacher_id'] != None])
        self.assertEqual(installed_tutorial_pieces_count, 1)
        self.assertEqual(installed_seats_count, 1)

    def test_exam_planning_term(self):
        term_object = copy.deepcopy(exam_planning_term)
        term_object['tutorial_pieces'][0]['date_index'] = 1
        term_object['tutorial_pieces'][0]['period_index'] = 1
        array_builder = ArrayBuilder(term_object=term_object)
        update_optimization_result = UpdateOptimizationResult(
            token='token', domain='domain', term_id=1)
        optimization_result = OptimizationResult(
            update_optimization_result=update_optimization_result,
            term_object=term_object,
            array_size=array_builder.array_size(),
            tutorial_occupation_array=array_builder.tutorial_occupation_array())
        tutorial_pieces = optimization_result.tutorial_pieces()
        seats = optimization_result.seats()
        installed_tutorial_pieces_count = len([
            tutorial_piece for tutorial_piece in tutorial_pieces
            if tutorial_piece['is_fixed'] != None])
        installed_seats_count = len([
            seat for seat in seats
            if seat['term_teacher_id'] != None])
        self.assertEqual(installed_tutorial_pieces_count, 1)
        self.assertEqual(installed_seats_count, 1)
