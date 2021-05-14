import itertools
import numpy


class SeatCombinationEvaluator():
    def __init__(self, array_size, single_cost, different_pair_cost):
        self.__array_size = array_size
        self.__single_cost = single_cost
        self.__different_pair_cost = different_pair_cost

    def violation_and_cost(self, tutorial_occupation):
        occupation = numpy.einsum('ijkml->jkml', tutorial_occupation)
        teacher_index_list = range(self.__array_size.teacher_count())
        date_index_list = range(self.__array_size.date_count())
        period_index_list = range(self.__array_size.period_count())
        product = itertools.product(
            teacher_index_list, date_index_list, period_index_list)
        cost_summation = 0
        teacher_occupation = numpy.sum(occupation, axis=1)
        for teacher_index, date_index, period_index in product:
            tutorials = occupation[teacher_index, :, date_index, period_index]
            sum = teacher_occupation[teacher_index, date_index, period_index]
            if sum == 1:
                cost_summation += self.__single_cost
            elif (sum == 2) and (1 in tutorials):
                cost_summation += self.__different_pair_cost
        return [0, cost_summation]
