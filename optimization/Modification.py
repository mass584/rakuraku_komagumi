import numpy as np
import CostAndViolation as cv
import logging
logger = logging.getLogger('Modification')

ALERT_DELETION = "(生徒){}{}さん(講師){}{}さんの{}の授業は配置できるコマがありませんでした。\n"

class Modification():

    def __init__(self, database):
        self.database = database
        self.cv1 = cv.CostAndViolation(database)
        self.cv2 = cv.CostAndViolation(database)
        self.messages = []

    def getScheduleDeletedOne(self, schedule, candidateIndex):
        schedule[candidateIndex[0],candidateIndex[1],candidateIndex[2],candidateIndex[3],candidateIndex[4]] = 0
        self.cv2.getCostAndViolation(schedule)
        value = self.cv2.violation
        schedule[candidateIndex[0],candidateIndex[1],candidateIndex[2],candidateIndex[3],candidateIndex[4]] = 1
        return value

    def getScheduleDeletedTwo(self, schedule, candidate1Index, candidate2Index):
        schedule[candidate1Index[0],candidate1Index[1],candidate1Index[2],candidate1Index[3],candidate1Index[4]] = 0
        schedule[candidate2Index[0],candidate2Index[1],candidate2Index[2],candidate2Index[3],candidate2Index[4]] = 0
        self.cv2.getCostAndViolation(schedule)
        value = self.cv2.violation
        schedule[candidate1Index[0],candidate1Index[1],candidate1Index[2],candidate1Index[3],candidate1Index[4]] = 1
        schedule[candidate2Index[0],candidate2Index[1],candidate2Index[2],candidate2Index[3],candidate2Index[4]] = 1
        return value

    def deleteOneSchedule(self, schedule):
        self.cv1.tableEn = True
        self.cv1.getCostAndViolation(schedule)
        originalValue = self.cv1.violation
        totalScheduleNumber = int(np.sum(self.database.classnumber))
        for n in range(totalScheduleNumber):
            candidateIndex = self.cv1.getNthElementFromWorst(n)
            if self.database.schedule_fixonly[candidateIndex[0],candidateIndex[1],candidateIndex[2],candidateIndex[3],candidateIndex[4]]: continue
            if schedule[candidateIndex[0],candidateIndex[1],candidateIndex[2],candidateIndex[3],candidateIndex[4]] == 0: continue
            candidateValue = self.getScheduleDeletedOne(schedule, candidateIndex)
            if candidateValue >= originalValue: continue
            # 削除処理が行われる場合の処理
            schedule[candidateIndex[0],candidateIndex[1],candidateIndex[2],candidateIndex[3],candidateIndex[4]] = 0
            self.database.classnumber[candidateIndex[0]][candidateIndex[1]][candidateIndex[2]] -= 1
            self.isDeleted = True
            logger.debug(f"DeleteSchedule: Student:{candidateIndex[0]}, Teacher:{candidateIndex[1]}, Subject:{candidateIndex[2]}")
            self.messages.append(ALERT_DELETION.format(
                self.database.students[candidateIndex[0]]['lastname'],
                self.database.students[candidateIndex[0]]['firstname'],
                self.database.teachers[candidateIndex[1]]['lastname'],
                self.database.teachers[candidateIndex[1]]['firstname'],
                self.database.personal_subjects[candidateIndex[2]]['name']))
            break

    def deleteTwoSchedule(self, schedule):
        self.cv1.tableEn = True
        self.cv1.getCostAndViolation(schedule)
        originalValue = self.cv1.violation
        totalScheduleNumber = int(np.sum(self.database.classnumber))
        for n in range(totalScheduleNumber):
            candidate1Index = self.cv1.getNthElementFromWorst(n)
            if self.database.schedule_fixonly[candidate1Index[0],candidate1Index[1],candidate1Index[2],candidate1Index[3],candidate1Index[4]]: continue
            if schedule[candidate1Index[0],candidate1Index[1],candidate1Index[2],candidate1Index[3],candidate1Index[4]] == 0: continue
            candidateValue = np.inf
            for student_index in range(self.database.student_count):
                for tutorial_index in range(self.database.personal_subject_count):
                    if schedule[student_index,candidate1Index[1],tutorial_index,candidate1Index[3],candidate1Index[4]] == 0: continue
                    if self.database.schedule_fixonly[student_index,candidate1Index[1],tutorial_index,candidate1Index[3],candidate1Index[4]]: continue
                    if student_index == candidate1Index[0] and tutorial_index == candidate1Index[2]: continue
                    candidate2Index = [student_index,candidate1Index[1],tutorial_index,candidate1Index[3],candidate1Index[4]]
                    candidateValue = self.getScheduleDeletedTwo(schedule, candidate1Index, candidate2Index)
            if candidateValue >= originalValue: continue
            # 削除処理が行われる場合の処理
            schedule[candidate1Index[0],candidate1Index[1],candidate1Index[2],candidate1Index[3],candidate1Index[4]] = 0
            schedule[candidate2Index[0],candidate2Index[1],candidate2Index[2],candidate2Index[3],candidate2Index[4]] = 0
            self.database.classnumber[candidate1Index[0]][candidate1Index[1]][candidate1Index[2]] -= 1
            self.database.classnumber[candidate2Index[0]][candidate2Index[1]][candidate2Index[2]] -= 1
            self.isDeleted = True
            logger.debug(f"DeleteSchedule: Student:{candidate1Index[0]}, Teacher:{candidate1Index[1]}, Subject:{candidate1Index[2]}")
            logger.debug(f"DeleteSchedule: Student:{candidate2Index[0]}, Teacher:{candidate2Index[1]}, Subject:{candidate2Index[2]}")
            self.messages.append(ALERT_DELETION.format(
                self.database.students[candidate1Index[0]]['lastname'],
                self.database.students[candidate1Index[0]]['firstname'],
                self.database.teachers[candidate1Index[1]]['lastname'],
                self.database.teachers[candidate1Index[1]]['firstname'],
                self.database.personal_subjects[candidate1Index[2]]['name']))
            self.messages.append(ALERT_DELETION.format(
                self.database.students[candidate2Index[0]]['lastname'],
                self.database.students[candidate2Index[0]]['firstname'],
                self.database.teachers[candidate2Index[1]]['lastname'],
                self.database.teachers[candidate2Index[1]]['firstname'],
                self.database.personal_subjects[candidate2Index[2]]['name']))
            break

    def runModification(self, schedule):
        self.cv2.getCostAndViolation(schedule)
        violation = self.cv2.violation
        if violation == 0: return True
        while True:
            self.isDeleted = False
            if not self.isDeleted: self.deleteOneSchedule(schedule)
            if not self.isDeleted: self.deleteTwoSchedule(schedule)
            if not self.isDeleted: return False

    def writeDeleteMessage(self):
        if len(self.messages) > 0:
            message = ''.join(self.messages)
            self.database.write_result(message)
