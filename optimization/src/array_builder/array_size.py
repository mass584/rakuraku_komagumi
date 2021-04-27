import logging

logger = logging.getLogger('Term')

class ArraySize():
    def __init__(self, term):
        self.term = term
        self.__build_counts()

    def __build_counts(self):
        self.teacher_count = len(self.term.term_teachers)
        self.student_count = len(self.term.term_students)
        self.tutorial_count = len(self.term.term_tutorials)
        self.group_count = len(self.term.term_groups)
        self.date_count = (self.term.term['end_at'] - self.term.term['begin_at']).days + 1
        self.period_count = self.term.term['period_count']
        self.seat_count = self.term.term['seat_count']
