import numpy as np

class OccupationAndBlankVectorEvaluator():
    def __init__(self, period_count, occupation_limit, blank_limit, occupation_costs, blank_costs):
        self.occupation_limit = occupation_limit
        self.blank_limit = blank_limit
        self.occupation_costs = occupation_costs
        self.blank_costs = blank_costs
        self.cost_vector = np.zeros(2**period_count, dtype='int32')
        self.__set_cost_vector(period_count)
        self.violation_vector = np.zeros(2**period_count, dtype='int32')
        self.__set_violation_vector(period_count)
        self.exponentiation_vector = np.logspace(0, period_count, num=period_count, endpoint=False, base=2, dtype='int32')

    def __set_cost_vector(self, period_count):
        for binary in range(2**period_count):
            occupation_count = 0
            blank_count = 0
            blank_count_buf = 0
            blank_count_flag = False
            for period_index in range(period_count):
                if (binary >> period_index & 0b1):
                    occupation_count += 1
                    if blank_buf_flag: blank_count += blank_count_buf
                    blank_count_flag = True
                    blank_count_buf = 0
                else:
                    blank_count_buf += 1
            if occupation_count <= self.occupation_limit:
                self.cost_vector[binary] += self.occupation_costs[occupation_count]
            if blank_count <= self.blank_limit:
                self.cost_vector[binary] += self.blank_costs[blank_count]

    def __set_violation_vector(self, period_count):
        for binary in range(2**period_count):
            occupation_count = 0
            blank_count = 0
            blank_count_buf = 0
            blank_count_flag = False
            for period_index in range(period_count):
                if (binary >> period_index & 0b1):
                    occupation_count += 1
                    if blank_count_flag: blank_count += blank_count_buf
                    blank_count_flag = True
                    blank_count_buf = 0
                else:
                    blank_coubt_buf += 1
            if occupation_count > self.occupation_limit:
                self.violation_vector[binary] += occupation_count - self.occupation_limit
            if blank_count > self.blank_limit:
                self.violation_vector[binary] += blank_count - self.blank_limit

    def violation_and_cost(self, one_day_vector):
        binary = np.dot(self.exponentiation_vector, one_day_vector)
        return [self.violation_vector[binary], self.cost_vector[binary]]
