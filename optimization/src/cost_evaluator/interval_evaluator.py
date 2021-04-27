import itertools
import numpy as np
import MathTool as math

class IntervalEvaluator():
    def __init__(array_size, interval_cutoff, interval_costs):
        self.array_size = array_size
        self.interval_cutoff = interval_cutoff
        self.interval_costs = interval_costs

    def violation_and_cost(self, tutorial_occupation):
        array = np.einsum('ijkml->ikml', tutorial_occupation)
        student_index_list = range(self.array_size.student_count)
        tutorial_index_list = range(self.array_size.tutorial_count)
        date_index_list = range(self.array_size.date_count)
        period_index_list = range(self.array_size.period_count)
        product1 = itertools.product(
            student_index_list,
            tutorial_index_list)
        product2 = itertools.product(
            date_index_list,
            period_index_list)
        for student_index, tutorial_index in product1:
            date_index_before = (-1) + (-self.interval_cutoff)
            for date_index, period_index in product1:
                if array[student_index, tutorial_index, date_index, period_index] > 0:
                    diff = date_index - date_index_before
                    if (diff <= self.interval_cutoff):
                        cost = self.interval_costs[diff]
                    else:
                        cost = 0
                    cost_summation += cost
                    date_index_before = date_index
        return [0, cost_summation]
