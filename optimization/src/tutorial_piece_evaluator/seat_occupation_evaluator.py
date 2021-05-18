import numpy


class SeatOccupationEvaluator():
    def __init__(self, array_size):
        self.__array_size = array_size

    def get_violation_and_cost_array(
            self, tutorial_occupation, violation_array):
        teacher_occupation = numpy.einsum('ijkml->jml', tutorial_occupation)
        seat_occupation = numpy.sum(
            numpy.apply_along_axis(
                lambda x: numpy.heaviside(x, 0).astype(int),
                1, teacher_occupation), axis=0)
        date_and_period_indexes = numpy.array(numpy.where(
            seat_occupation > self.__array_size.seat_count())).transpose()
        for date_index, period_index in date_and_period_indexes:
            student_and_teacher_and_tutorial_indexes = numpy.array(numpy.where(
                tutorial_occupation[:, :, :, date_index, period_index] > 0)).transpose()
            for student_index, teacher_index, tutorial_index in student_and_teacher_and_tutorial_indexes:
                excess = seat_occupation[date_index,
                                         period_index] - self.__array_size.seat_count()
                violation_array[student_index,
                                teacher_index,
                                tutorial_index,
                                date_index,
                                period_index] += excess
