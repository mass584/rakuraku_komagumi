import itertools
import numpy


class Timetable():
    def __init__(self, term, array_size):
        self.term = term
        self.array_size = array_size
        self.__build_timetable()

    def __build_timetable(self):
        self.__timetable_array = numpy.zeros(
            (self.array_size.date_count(), self.array_size.period_count()),
            dtype=int)
        date_index_list = list(range(self.array_size.date_count()))
        period_index_list = list(range(self.array_size.period_count()))
        product = itertools.product(date_index_list, period_index_list)
        for date_index, period_index in product:
            is_matched = (lambda item:
                          item['date_index'] == date_index + 1 and
                          item['period_index'] == period_index + 1 and
                          item['is_closed'] is False and
                          item['term_group_id'] is None)
            is_available = True in [
                True for item in self.term['timetables']
                if is_matched(item)]
            if is_available:
                self.__timetable_array[date_index, period_index] = 1

    def timetable_array(self):
        return self.__timetable_array
