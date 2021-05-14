class ArraySize():
    def __init__(self, term):
        self.term = term
        self.__build_counts()

    def __build_counts(self):
        self.__teacher_count = len(self.term['term_teachers'])
        self.__student_count = len(self.term['term_students'])
        self.__tutorial_count = len(self.term['term_tutorials'])
        self.__group_count = len(self.term['term_groups'])
        self.__date_count = self.__get_date_count()
        self.__period_count = self.term['term']['period_count']
        self.__seat_count = self.term['term']['seat_count']
        self.__school_grade_count = 13

    def __get_date_count(self):
        is_normal = self.term['term']['term_type'] == 0
        date_count = (self.term['term']['end_at'] - self.term['term']['begin_at']).days + 1
        return 7 if is_normal else date_count

    def teacher_count(self):
        return self.__teacher_count

    def student_count(self):
        return self.__student_count

    def tutorial_count(self):
        return self.__tutorial_count

    def group_count(self):
        return self.__group_count

    def date_count(self):
        return self.__date_count

    def period_count(self):
        return self.__period_count

    def seat_count(self):
        return self.__seat_count

    def school_grade_count(self):
        return self.__school_grade_count
