import itertools
import numpy as np

class SeatOccupationEvaluator():
    def __init__(self, array_size):
        self.array_size = array_size

    def violation_and_cost(self, tutorial_occupation):
        occupation1 = np.einsum('ijkml->jml', tutorial_occupation)
        theta = lambda x: np.heaviside(x, 0).astype(int)
        occupation2 = np.sum(np.apply_along_axis(theta, 1, occupation1), axis=0)
        date_index_list = range(self.array_size.date_count)
        period_index_list = range(self.array_size.period_count)
        product = itertools.product(date_index_list, period_index_list)
        for date_index, period_index in product:
            excess = occupation2[date_index, period_index] - self.array_size.seat_count
            if excess > 0: violation_summation += excess
        return [violation_summation, 0]
