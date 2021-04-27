import numpy as np

class VacancyAndDoubleBookingEvaluator():
    def student_evaluation(self, tutorial_occupation, student_vacancy):
        student_occupation = np.einsum('ijkml->iml', tutorial_occupation)
        relu = lambda x: np.maximum(0, x).astype(int)
        excess = np.apply_along_axis(relu, 1, student_occupation - student_vacancy)
        violation = np.sum(excess)
        return [violation, 0]

    def teacher_evaluation(self, tutorial_occupation, teacher_vacancy):
        teacher_occupation = np.einsum('ijkml->jml', tutorial_occupation)
        relu = lambda x: np.maximum(0, x).astype(int)
        excess = np.apply_along_axis(relu, 1, teacher_occupation - 2 * teacher_vacancy)
        violation = np.sum(excess)
        return [violation, 0]
