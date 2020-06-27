import numpy as np
import CostAndViolation as cv
import logging
logger = logging.getLogger('InitialState')

class InitialState():

    def __init__(self, database, progress):
        self.database = database
        self.progress = progress
        self.cv = cv.CostAndViolation(database)
        self.schedule = database.schedule
        expectedClassNumber = database.classnumber
        currentClassNumber = np.einsum('ijkml->ijk', database.schedule)
        self.addClassNumber = expectedClassNumber - currentClassNumber

    def addSchedule(self, nStu, nTea, nSub):
        array = np.full((self.database.day_count, self.database.class_count), np.inf)
        for i in range(self.database.day_count):
            for j in range(self.database.class_count):
                if self.schedule[nStu, nTea, nSub, i, j] == 0 and self.database.timetable[i, j] == 0:
                    self.schedule[nStu, nTea, nSub, i, j] = 1
                    array[i, j] = self.cv.getCostAndViolation(self.schedule)
                    self.schedule[nStu, nTea, nSub, i, j] = 0
        ans = np.unravel_index(array.argmin(), array.shape)
        self.schedule[nStu, nTea, nSub, ans[0], ans[1]] = 1
        logger.debug(f"Add Schedule: Student:{nStu}, Teacher:{nTea}, Subject:{nSub}, Day:{ans[0]}, Class:{ans[1]}")
        return 0

    def getNewSchedule(self):
        loop = 1
        self.progress.startInitialize(np.sum(self.addClassNumber))
        while loop:
            loop = 0
            for i in range(self.database.student_count):
                for j in range(self.database.teacher_count):
                    for k in range(self.database.personal_subject_count):
                        if self.addClassNumber[i,j,k] > 0:
                            self.addSchedule(i, j, k)
                            self.addClassNumber[i,j,k] -= 1
                            loop = 1
                            self.progress.advanceInitialize()
        self.progress.endInitialize()
        final = self.cv.getCostAndViolation(self.schedule)
        logger.info(f"Evaluation value:{final}")
        return self.schedule


