import itertools
import numpy


class VacancyAndDoubleBookingEvaluator():
    def __init__(self, teacher_vacancy, student_vacancy):
        self.__teacher_vacancy = teacher_vacancy
        self.__student_vacancy = student_vacancy

    def __student_violation_and_cost(
            self, tutorial_occupation, violation_array):
        student_occupation = numpy.einsum('ijkml->iml', tutorial_occupation)
        excess = numpy.apply_along_axis(
            lambda x: numpy.maximum(0, x).astype(int),
            1, student_occupation - self.__student_vacancy)
        excess_indexes = numpy.array(numpy.where(excess > 0)).transpose()
        for student_index, date_index, period_index in excess_indexes:
            teacher_and_tutorial_indexes = numpy.array(numpy.where(
                tutorial_occupation[student_index, :, :, date_index, period_index] > 0)).transpose()
            for teacher_index, tutorial_index in teacher_and_tutorial_indexes:
                violation_array[student_index, teacher_index, tutorial_index, date_index, period_index] += \
                    excess[student_index, date_index, period_index]

    def __teacher_violation_and_cost(
            self, tutorial_occupation, violation_array):
        teacher_occupation = numpy.einsum('ijkml->jml', tutorial_occupation)
        excess = numpy.apply_along_axis(
            lambda x: numpy.maximum(0, x).astype(int),
            1, teacher_occupation - 2 * self.__teacher_vacancy)
        excess_indexes = numpy.array(numpy.where(excess > 0)).transpose()
        for teacher_index, date_index, period_index in excess_indexes:
            student_and_tutorial_indexes = numpy.array(numpy.where(
                tutorial_occupation[:, teacher_index, :, date_index, period_index] > 0)).transpose()
            for student_index, tutorial_index in student_and_tutorial_indexes:
                violation_array[student_index, teacher_index, tutorial_index, date_index, period_index] += \
                    excess[teacher_index, date_index, period_index]

    def get_violation_and_cost_array(
            self, tutorial_occupation, violation_array):
        self.__teacher_violation_and_cost(tutorial_occupation, violation_array)
        self.__student_violation_and_cost(tutorial_occupation, violation_array)
