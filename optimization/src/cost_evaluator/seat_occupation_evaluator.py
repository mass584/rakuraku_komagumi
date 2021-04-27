import numpy as np

class SeatOccupationEvaluator():
    def __init__(array_size):
        self.array_size = array_size

    def violation_and_cost(self, tutorial_occupation):
        teacher_occupation = np.einsum('ijkml->jml', tutorial_occupation)
        theta = lambda x: np.heaviside(x, 0).astype(int)
        seat_occupation = np.sum(np.apply_along_axis(theta, 1, teacher_occupation), axis=0)
        date_index_list = range(self.array_size.date_count)
        period_index_list = range(self.array_size.period_count)
        product = itertools.product(date_index_list, period_index_list)
        for date_index, period_index in product:
            excess = seat_occupation[date_index, period_index] - self.array_size.seat_count
            if excess > 0: violation_summation += excess
        return violation_summation
