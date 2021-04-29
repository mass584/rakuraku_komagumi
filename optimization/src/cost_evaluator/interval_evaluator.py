import itertools
import numpy

class IntervalEvaluator():
    def __init__(self, array_size, interval_cutoff, interval_costs):
        self.__array_size = array_size
        self.__interval_cutoff = interval_cutoff
        self.__interval_costs = interval_costs

    def violation_and_cost(self, tutorial_pieces):
        array = numpy.einsum('ijkml->ikml', tutorial_pieces)
        student_index_list = range(self.__array_size.student_count())
        tutorial_index_list = range(self.__array_size.tutorial_count())
        date_index_list = range(self.__array_size.date_count())
        period_index_list = range(self.__array_size.period_count())
        product1 = itertools.product(
            student_index_list,
            tutorial_index_list)
        product2 = itertools.product(
            date_index_list,
            period_index_list)
        cost_summation = 0
        for student_index, tutorial_index in product1:
            date_index_before = (-1) + (-self.__interval_cutoff)
            for date_index, period_index in product2:
                if array[student_index, tutorial_index, date_index, period_index] > 0:
                    diff = date_index - date_index_before
                    if (diff <= self.__interval_cutoff):
                        cost = self.__interval_costs[diff]
                    else:
                        cost = 0
                    cost_summation += cost
                    date_index_before = date_index
        return [0, cost_summation]
