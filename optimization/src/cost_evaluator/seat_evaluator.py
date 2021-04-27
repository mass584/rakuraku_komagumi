import numpy as np

class SeatEvaluator():
    def __init__(self, single_cost, different_pair_cost):
        self.single_cost = single_cost
        self.different_pair_cost = different_pair_cost

    def violation_and_cost(self, seat_occupation):
        summation = sum(seat_occupation)
        if summation == 1:
            return [0, self.single_cost]
        elif (summation == 2) and (1 in seat_occupation):
            return [0, self.different_pair_cost]
        else:
            return [0, 0]
