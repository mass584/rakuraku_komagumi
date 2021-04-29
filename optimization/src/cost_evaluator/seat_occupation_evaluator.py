import itertools
import numpy


class SeatOccupationEvaluator():
    def __init__(self, array_size):
        self.__array_size = array_size

    def violation_and_cost(self, tutorial_occupation):
        occupation1 = numpy.einsum('ijkml->jml', tutorial_occupation)
        occupation2 = numpy.sum(
            numpy.apply_along_axis(
                lambda x: numpy.heaviside(x, 0).astype(int),
                1, occupation1), axis=0)
        date_index_list = range(self.__array_size.date_count())
        period_index_list = range(self.__array_size.period_count())
        product = itertools.product(date_index_list, period_index_list)
        violation_summation = 0
        for date_index, period_index in product:
            excess = occupation2[date_index, period_index] - \
                self.__array_size.seat_count()
            if excess > 0:
                violation_summation += excess
        return [violation_summation, 0]
