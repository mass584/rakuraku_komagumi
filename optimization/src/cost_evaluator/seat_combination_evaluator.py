import itertools
import numpy as np

class SeatCombinationEvaluator():
    def __init__(self, array_size, single_cost, different_pair_cost):
        self.array_size = array_size
        self.single_cost = single_cost
        self.different_pair_cost = different_pair_cost

    def violation_and_cost(self, tutorial_occupation):
        occupation = np.einsum('ijkml->jkml', tutorial_occupation)
        teacher_index_list = range(self.array_size.teacher_count)
        date_index_list = range(self.array_size.date_count)
        period_index_list = range(self.array_size.period_count)
        product = itertools.product(teacher_index_list, date_index_list, period_index_list)
        for teacher_index, date_index, period_index in product:
            vector = occupation[teacher_index, :, date_index, period_index]
            summation = sum(vector)
            if summation == 1:
                cost_summation += self.single_cost
            elif (summation == 2) and (1 in seat_occupation):
                cost_summation += self.different_pair_cost
        return [0, cost_summation]
