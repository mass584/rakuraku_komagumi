import itertools
import math
import multiprocessing
import numpy
import time
from .installer_process import InstallerProcess
from logging import getLogger


logger = getLogger(__name__)

class Installer():
    def __init__(self, process_count, term_object, array_builder, cost_evaluator):
        self.__process_count = process_count
        self.__term_object = term_object
        self.__array_size = array_builder.array_size()
        self.__uninstalled_tutorial_piece_count = \
            self.__get_uninstalled_tutorial_piece_count(
                tutorial_piece_count=array_builder.tutorial_piece_count_array(),
                tutorial_occupation_array=array_builder.tutorial_occupation_array())
        self.__cost_evaluator = cost_evaluator
        self.__timetable_array = array_builder.timetable_array()
        self.__tutorial_occupation_array = array_builder.tutorial_occupation_array()
        self.__installed_count = 0

    def __get_uninstalled_tutorial_piece_count(
            self, tutorial_piece_count, tutorial_occupation_array):
        installed_tutorial_piece_count = numpy.einsum(
            'ijkml->ijk', tutorial_occupation_array)
        return tutorial_piece_count - installed_tutorial_piece_count

    def __get_best_position(self, student_index,
                            teacher_index, tutorial_index):
        # TODO: INTEGERの最大値を環境からとる
        initial_cost_array = [1215752191] * (
            self.__array_size.date_count() * self.__array_size.period_count())
        cost_array = multiprocessing.Array('i', initial_cost_array)
        process = [
            multiprocessing.Process(
                target=InstallerProcess(
                    proc_num,
                    self.__process_count,
                    self.__array_size,
                    self.__cost_evaluator,
                    self.__tutorial_occupation_array,
                    self.__timetable_array).run,
                args=[cost_array, student_index, teacher_index, tutorial_index])
            for proc_num in range(self.__process_count)]
        for proc_num in range(self.__process_count):
            process[proc_num].start()
        for proc_num in range(self.__process_count):
            process[proc_num].join()
        cost_ndarray = numpy.array(cost_array).reshape([
            self.__array_size.date_count(), self.__array_size.period_count()])
        return numpy.unravel_index(cost_ndarray.argmin(), cost_ndarray.shape)

    # line_profilerによるチューニングの際に使用する
    def __get_best_position_sequential(
            self, student_index, teacher_index, tutorial_index):
        # TODO: INTEGERの最大値を環境からとる
        cost_array = [1215752191] * (
            self.__array_size.date_count() * self.__array_size.period_count())
        installer_process = InstallerProcess(
            1, self.__process_count,
            self.__array_size,
            self.__cost_evaluator,
            self.__tutorial_occupation_array,
            self.__timetable_array)
        installer_process.run(
            cost_array, student_index, teacher_index, tutorial_index)
        cost_ndarray = numpy.array(cost_array).reshape([
            self.__array_size.date_count(), self.__array_size.period_count()])
        return numpy.unravel_index(cost_ndarray.argmin(), cost_ndarray.shape)

    def __add_tutorial_piece(
            self, student_index, teacher_index, tutorial_index):
        start = time.time()
        [date_index, period_index] = self.__get_best_position(
            student_index, teacher_index, tutorial_index)
        end = time.time()
        elapsed_sec = math.floor((end - start) * 1000000) / 1000000
        self.__uninstalled_tutorial_piece_count[
            student_index,
            teacher_index,
            tutorial_index] -= 1
        self.__tutorial_occupation_array[
            student_index,
            teacher_index,
            tutorial_index,
            date_index,
            period_index] = 1
        self.__installed_count += 1
        self.__logging(
            student_index,
            teacher_index,
            tutorial_index,
            date_index,
            period_index,
            elapsed_sec)

    def __logging(self, student_index, teacher_index,
                  tutorial_index, date_index, period_index, elapsed_sec):
        student_name = self.__term_object['term_students'][student_index]['name']
        student_school_grade = self.__term_object['term_students'][student_index]['school_grade']
        teacher_name = self.__term_object['term_teachers'][teacher_index]['name']
        tutorial_name = self.__term_object['term_tutorials'][tutorial_index]['name']
        [violation, cost] = self.__cost_evaluator.violation_and_cost(
            self.__tutorial_occupation_array)
        logger.info('================コマを配置しました================')
        logger.info(f'配置No：{self.__installed_count}')
        logger.info(f'生徒：{student_name}（{student_school_grade}）')
        logger.info(f'講師：{teacher_name}')
        logger.info(f'科目：{tutorial_name}')
        logger.info(f'日時：{date_index + 1}日目{period_index + 1}限')
        logger.info(f'合計違反点数：{violation}')
        logger.info(f'合計コスト点数：{cost}')
        logger.info(f'経過時間：{elapsed_sec}秒')
        logger.info('==================================================')

    def execute(self):
        student_index_list = range(self.__array_size.student_count())
        teacher_index_list = range(self.__array_size.teacher_count())
        tutorial_index_list = range(self.__array_size.tutorial_count())
        max_tutorial_piece_count = numpy.amax(
            self.__uninstalled_tutorial_piece_count)
        # 公平になるように各生徒、各科目のコマを１つずつ配置していく
        for _ in range(max_tutorial_piece_count):
            product = itertools.product(
                tutorial_index_list, student_index_list, teacher_index_list)
            # 公平になるように生徒インデックスのループを先に回す
            for tutorial_index, student_index, teacher_index in product:
                have_uninstalled_pieces = self.__uninstalled_tutorial_piece_count[
                    student_index, teacher_index, tutorial_index] > 0
                if have_uninstalled_pieces:
                    self.__add_tutorial_piece(
                        student_index, teacher_index, tutorial_index)

    def installed_count(self):
        return self.__installed_count

    def tutorial_occupation_array(self):
        return self.__tutorial_occupation_array
