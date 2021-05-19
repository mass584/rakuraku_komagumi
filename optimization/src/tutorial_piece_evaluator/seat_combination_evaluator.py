import itertools
import numpy


class SeatCombinationEvaluator():
    def __init__(self, array_size, single_cost, different_pair_cost):
        self.__array_size = array_size
        self.__single_cost = single_cost
        self.__different_pair_cost = different_pair_cost

    def get_violation_and_cost_array(self, tutorial_occupation, cost_array):
        occupation = numpy.einsum('ijkml->jkml', tutorial_occupation)
        teacher_occupation = numpy.sum(occupation, axis=1)
        teacher_index_list = range(self.__array_size.teacher_count())
        date_index_list = range(self.__array_size.date_count())
        period_index_list = range(self.__array_size.period_count())
        product = itertools.product(
            teacher_index_list, date_index_list, period_index_list)
        for teacher_index, date_index, period_index in product:
            sum = teacher_occupation[teacher_index, date_index, period_index]
            student_and_tutorial_index = numpy.array(numpy.where(
                tutorial_occupation[:, teacher_index, :, date_index, period_index])).transpose()
            if sum == 1:
                for student_index, tutorial_index in student_and_tutorial_index:
                    cost_array[student_index, teacher_index, tutorial_index, date_index, period_index] += \
                        self.__single_cost
            elif (sum == 2) and (1 in occupation[teacher_index, :, date_index, period_index]):
                for student_index, tutorial_index in student_and_tutorial_index:
                    cost_array[student_index, teacher_index, tutorial_index, date_index, period_index] += \
                        self.__different_pair_cost
