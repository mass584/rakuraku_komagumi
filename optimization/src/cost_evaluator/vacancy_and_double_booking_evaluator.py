import numpy


class VacancyAndDoubleBookingEvaluator():
    def __student_violation_and_cost(
            self, tutorial_occupation, student_vacancy):
        student_occupation = numpy.einsum('ijkml->iml', tutorial_occupation)
        excess = numpy.apply_along_axis(
            lambda x: numpy.maximum(0, x).astype(int),
            1, student_occupation - student_vacancy)
        violation = numpy.sum(excess)
        return [violation, 0]

    def __teacher_violation_and_cost(
            self, tutorial_occupation, teacher_vacancy):
        teacher_occupation = numpy.einsum('ijkml->jml', tutorial_occupation)
        excess = numpy.apply_along_axis(
            lambda x: numpy.maximum(0, x).astype(int),
            1, teacher_occupation - 2 * teacher_vacancy)
        violation = numpy.sum(excess)
        return [violation, 0]

    def violation_and_cost(self, tutorial_occupation,
                           teacher_vacancy, student_vacancy):
        teacher_violation_and_cost = self.__teacher_violation_and_cost(
            tutorial_occupation, teacher_vacancy)
        student_violation_and_cost = self.__student_violation_and_cost(
            tutorial_occupation, student_vacancy)
        return [teacher + student for teacher,
                student in zip(
                    teacher_violation_and_cost,
                    student_violation_and_cost)]
