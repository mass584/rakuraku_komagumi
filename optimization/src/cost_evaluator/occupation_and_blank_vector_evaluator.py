import numpy as np

class OccupationAndBlankVectorEvaluator():
    def __init__(self, period_count, occupation_limit, blank_limit, occupation_costs, blank_costs):
        self.__occupation_limit = occupation_limit
        self.__blank_limit = blank_limit
        self.__occupation_costs = occupation_costs
        self.__blank_costs = blank_costs
        self.__cost_vector = np.zeros(2**period_count, dtype='int32')
        self.__set_cost_vector(period_count)
        self.__violation_vector = np.zeros(2**period_count, dtype='int32')
        self.__set_violation_vector(period_count)
        self.__exponentiation_vector = np.logspace(0, period_count, num=period_count, endpoint=False, base=2, dtype='int32')

    def __set_cost_vector(self, period_count):
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
                    blank_count_buf += 1
            if occupation_count <= self.__occupation_limit:
                self.__cost_vector[binary] += self.__occupation_costs[occupation_count]
            if blank_count <= self.__blank_limit:
                self.__cost_vector[binary] += self.__blank_costs[blank_count]

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
                    blank_count_buf += 1
            if occupation_count > self.__occupation_limit:
                self.__violation_vector[binary] += occupation_count - self.__occupation_limit
            if blank_count > self.__blank_limit:
                self.__violation_vector[binary] += blank_count - self.__blank_limit

    def violation_and_cost(self, one_day_vector):
        binary = np.dot(self.__exponentiation_vector, one_day_vector)
        return [self.__violation_vector[binary], self.__cost_vector[binary]]
