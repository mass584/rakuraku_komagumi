import itertools
import numpy


class TimetableEvaluator():
    def __init__(self, array_size):
        self.__array_size = array_size

    def violation_and_cost(self, tutorial_occupation, timetable):
        occupation_array = numpy.einsum('ijkml->ml', tutorial_occupation)
        date_index_list = range(self.__array_size.date_count())
        period_index_list = range(self.__array_size.period_count())
        product = itertools.product(date_index_list, period_index_list)
        violation_summation = 0
        for date_index, period_index in product:
            is_available = timetable[date_index, period_index]
            occupation = occupation_array[date_index, period_index]
            if (not is_available) and (occupation > 0):
                violation_summation += occupation
        return [violation_summation, 0]
