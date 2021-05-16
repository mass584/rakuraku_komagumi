import itertools
import math
import multiprocessing
import numpy
import os
import time
from cost_evaluator.cost_evaluator import CostEvaluator
from logging import getLogger


logger = getLogger(__name__)
PROCESS_NUM = 4


class Installer():
    def __init__(self, term_object, array_builder,
                 student_optimization_rules, teacher_optimization_rule):
        self.__term_object = term_object
        self.__array_size = array_builder.array_size()
        self.__uninstalled_tutorial_piece_count = \
            self.__get_uninstalled_tutorial_piece_count(
                tutorial_piece_count=array_builder.tutorial_piece_count_array(),
                tutorial_occupation_array=array_builder.tutorial_occupation_array())
        self.__cost_evaluator = CostEvaluator(
            array_size=array_builder.array_size(),
            timetable=array_builder.timetable_array(),
            student_optimization_rules=student_optimization_rules,
            teacher_optimization_rule=teacher_optimization_rule,
            student_group_occupation=array_builder.student_group_occupation_array(),
            teacher_group_occupation=array_builder.teacher_group_occupation_array(),
            student_vacancy=array_builder.student_vacancy_array(),
            teacher_vacancy=array_builder.teacher_vacancy_array(),
            school_grades=array_builder.school_grade_array())
        self.__timetable_array = array_builder.timetable_array()
        self.__tutorial_occupation_array = array_builder.tutorial_occupation_array()
        self.__installed_count = 0

    def __get_uninstalled_tutorial_piece_count(
            self, tutorial_piece_count, tutorial_occupation_array):
        installed_tutorial_piece_count = numpy.einsum(
            'ijkml->ijk', tutorial_occupation_array)
        return tutorial_piece_count - installed_tutorial_piece_count

    def __search_guard(self, student_index, teacher_index,
                       tutorial_index, date_index, period_index):
        # 個別科目が配置済みの所は探索しない
        if self.__tutorial_occupation_array[
                student_index, teacher_index, tutorial_index, date_index, period_index] == 1:
            return True
        # 集団科目が配置済みか休講の所は探索しない
        if self.__timetable_array[date_index, period_index] == 0:
            return True

    def __run_process(
            self,
            proc_num,
            student_index,
            teacher_index,
            tutorial_index):
        logger.debug(f"プロセス開始：PID{os.getpid()}")
        date_index_list = range(self.__array_size.date_count())
        period_index_list = range(self.__array_size.period_count())
        date_and_period_index_list = list(
            itertools.product(date_index_list, period_index_list))
        list_length = math.ceil(len(date_and_period_index_list) / PROCESS_NUM)
        begin_index_for_list = proc_num * list_length
        end_index_for_list = (proc_num  + 1) * list_length
        date_and_period_index_list_for_proc = date_and_period_index_list[
            begin_index_for_list:end_index_for_list]
        for date_index, period_index in date_and_period_index_list_for_proc:
            if self.__search_guard(
                    student_index,
                    teacher_index,
                    tutorial_index,
                    date_index,
                    period_index):
                return numpy.inf
            self.__tutorial_occupation_array[
                student_index,
                teacher_index,
                tutorial_index,
                date_index,
                period_index] += 1
            cost = self.__cost_evaluator.cost(self.__tutorial_occupation_array)
            print(cost) # TODO:共有メモリに書き込む
        logger.debug(f"プロセス終了：PID{os.getpid()}")

    def __get_best_date_and_period(
            self, student_index, teacher_index, tutorial_index):
        cost_array = numpy.full(
            (self.__array_size.date_count(), self.__array_size.period_count()),
            numpy.inf)
        process = [None] * PROCESS_NUM
        for proc_num in range(PROCESS_NUM):
            process[proc_num] = multiprocessing.Process(
                target=self.__run_process,
                args=[proc_num, student_index, teacher_index, tutorial_index])
        for proc_num in range(PROCESS_NUM): process[proc_num].start()
        for proc_num in range(PROCESS_NUM): process[proc_num].join()
        return numpy.unravel_index(cost_array.argmin(), cost_array.shape)

    def __add_tutorial_piece(
            self, student_index, teacher_index, tutorial_index):
        start = time.time()
        [date_index, period_index] = self.__get_best_date_and_period(
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
