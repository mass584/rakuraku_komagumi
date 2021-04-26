import numpy as np
import MathTool as math
import ClassPatternEvaluation as ce
import SubjectCombinationEvaluation as se

import logging
logger = logging.getLogger('CostAndViolation')

VIOLATION_WEIGHT = 100000000

VIOLATION_STUDENT_AVAILABLE_CHECK = "(生徒){}{}さんの{}、{}限のコマが欠席コマに割り当てられている、もしくは、ダブルブッキングになっています。"
VIOLATION_TEACHER_AVAILABLE_CHECK = "(講師){}{}さんの{}、{}限のコマが欠席コマに割り当てられている、もしくは、オーバーブッキングになっています。"
VIOLATION_TEACHER_RULE_CHECK = "(講師){}{}さんの{}の授業が禁止されたパターンになっています。"
VIOLATION_STUDENT_RULE_CHECK = "(生徒){}{}さんの{}の授業が禁止されたパターンになっています。"
VIOLATION_OCCUPATION_CHECK = "{},{}限の座席数が上限を超えています。"

VALIDATION_CLASSNUMBER_CHECK = "(生徒){}{}さんの{}のコマ数が誤っています。"
VALIDATION_TIMETABLE_CHECK = "休講の{}、{}限に授業が割り当てられています。"

class CostAndViolation():

    def __init__(self, database):
        self.database = database
        self.teacherEval = ce.ClassPatternEvaluation(
                database.class_count,
                database.teacher_total_class_max,
                database.teacher_total_class_cost,
                database.teacher_blank_class_max,
                database.teacher_blank_class_cost)
        self.studentEval = ce.ClassPatternEvaluation(
                database.class_count,
                database.student_total_class_max,
                database.student_total_class_cost,
                database.student_blank_class_max,
                database.student_blank_class_cost)
        self.student3GEval = ce.ClassPatternEvaluation(
                database.class_count,
                database.student3g_total_class_max,
                database.student3g_total_class_cost,
                database.student3g_blank_class_max,
                database.student3g_blank_class_cost)
        self.subjectEval = se.SubjectCombinationEvaluation(
                database.personal_subject_count,
                database.single_cost,
                database.different_pair_cost)
        self.teacherEval.setViolationCost()
        self.studentEval.setViolationCost()
        self.student3GEval.setViolationCost()
        self.messageEn = False
        self.totalViolation = 0
        self.totalCost = 0
        self.tableEn = False
        self.violationTable = {}
        self.costTable = {}
        self.sorted = False
        self.sortResult = {}

    def validation(self, schedule):
        ret = True
        if not self.classnumberCheck(schedule): ret = False
        if not self.timetableCheck(schedule): ret = False
        return ret

    def getCostAndViolation(self, schedule):
        self.violation = 0
        self.cost = 0
        self.violationTable = np.zeros((self.database.student_count, self.database.teacher_count, self.database.personal_subject_count, self.database.day_count, self.database.class_count))
        self.costTable = np.zeros((self.database.student_count, self.database.teacher_count, self.database.personal_subject_count, self.database.day_count, self.database.class_count))
        self.sorted = False
        self.sortResult = {}
        self.studentAvailableCheck(schedule)
        self.teacherAvailableCheck(schedule)
        self.teacherRuleCheck(schedule)
        self.studentRuleCheck(schedule)
        self.combinationCheck(schedule)
        self.classIntervalCheck(schedule)
        self.occupationCheck(schedule)
        ret = self.violation * VIOLATION_WEIGHT + self.cost
        return ret

    def sortCostAndViolationTable(self):
        sumTable = self.violationTable * VIOLATION_WEIGHT + self.costTable
        flattenedSumTable = sumTable.flatten()
        flattenedAndSortedSumTable = np.argsort(-flattenedSumTable)
        self.sortResult = np.unravel_index(flattenedAndSortedSumTable, sumTable.shape)
        self.sorted = True

    def getNthElementFromWorst(self, n):
        if not self.sorted:
            self.sortCostAndViolationTable()
        return [self.sortResult[0][n], self.sortResult[1][n], self.sortResult[2][n], self.sortResult[3][n], self.sortResult[4][n]]

    # 生徒が来られない日に授業が割り当てられていないか
    # 生徒がダブルブッキングされていないか
    def studentAvailableLogger(self, exceed):
        idx = np.where(exceed > 0)
        for i in range(idx[0].size):
            logger.info(VIOLATION_STUDENT_AVAILABLE_CHECK.format(
                self.database.students[idx[0][i]]['lastname'],
                self.database.students[idx[0][i]]['firstname'],
                self.database.days[idx[1][i]],
                idx[2][i]+1
                ))
            logger.debug(f"Student:{idx[0][i]} Day:{idx[1][i]} Class:{idx[2][i]}")

    def studentAvailableTable(self, exceed, schedule):
        idx1 = np.where(exceed > 0)
        for i in range(idx1[0].size):
            idx2 = np.where(schedule[idx1[0][i],:,:,idx1[1][i],idx1[2][i]] > 0)
            for j in range(idx2[0].size):
                self.violationTable[idx1[0][i],idx2[0][j],idx2[1][j],idx1[1][i],idx1[2][i]] += exceed[idx1[0][i],idx1[1][i],idx1[2][i]]

    def studentAvailableCheck(self, schedule):
        studentOccupation = np.einsum('ijkml->iml', schedule)
        exceed = np.apply_along_axis(math.ReLU, 1, studentOccupation - self.database.studentrequest)
        self.violation += np.sum(exceed)
        if self.messageEn: self.studentAvailableLogger(exceed)
        if self.tableEn: self.studentAvailableTable(exceed, schedule)

    # 講師が来られない日に授業が割り当てられていないか
    # 講師がオーバーブッキングされていないか
    def teacherAvailableLogger(self, exceed):
        idx = np.where(exceed > 0)
        for i in range(idx[0].size):
            logger.info(VIOLATION_TEACHER_AVAILABLE_CHECK.format(
                self.database.teachers[idx[0][i]]['lastname'],
                self.database.teachers[idx[0][i]]['firstname'],
                self.database.days[idx[1][i]],
                idx[2][i]+1
                ))
            logger.debug(f"Teacher:{idx[0][i]} Day:{idx[1][i]} Class:{idx[2][i]}")

    def teacherAvailableTable(self, exceed, schedule):
        idx1 = np.where(exceed > 0)
        for i in range(idx1[0].size):
            idx2 = np.where(schedule[:,idx1[0][i],:,idx1[1][i],idx1[2][i]] > 0)
            for j in range(idx2[0].size):
                self.violationTable[idx2[0][j],idx1[0][i],idx2[1][j],idx1[1][i],idx1[2][i]] += exceed[idx1[0][i],idx1[1][i],idx1[2][i]]

    def teacherAvailableCheck(self, schedule):
        teacherOccupation = np.einsum('ijkml->jml', schedule)
        exceed = np.apply_along_axis(math.ReLU, 1, teacherOccupation - 2 * self.database.teacherrequest)
        self.violation += np.sum( exceed )
        if self.messageEn: self.teacherAvailableLogger(exceed)
        if self.tableEn: self.teacherAvailableTable(exceed, schedule)

    # 生徒の授業パターン評価
    def studentRuleTable(self, nStudent, nDay, violation, cost, schedule):
        idx = np.where(schedule[nStudent,:,:,nDay,:] > 0)
        for i in range(idx[0].size):
            self.violationTable[nStudent,idx[0][i],idx[1][i],nDay,idx[2][i]] += violation
            self.costTable[nStudent,idx[0][i],idx[1][i],nDay,idx[2][i]] += cost

    def studentRuleCheck(self, schedule):
        studentOccupation = (np.einsum('ikjml->iml', schedule) > 0 ).astype(np.int)
        studentOccupation += self.database.student_group_reshaped
        for i in range(self.database.student_count):
            for j in range(self.database.day_count):
                if self.database.students[i]['grade'] == '中3':
                    [violation, cost] = self.student3GEval.getViolationCost(studentOccupation[i,j,:])
                else:
                    [violation, cost] = self.studentEval.getViolationCost(studentOccupation[i,j,:])
                self.violation += violation
                self.cost += cost
                if self.tableEn: self.studentRuleTable(i, j, violation, cost, schedule)
                if (violation > 0) and self.messageEn:
                    logger.info(VIOLATION_STUDENT_RULE_CHECK.format(
                        self.database.students[i]['lastname'],
                        self.database.students[i]['firstname'],
                        self.database.days[j]
                        ))
                    logger.debug(f"Student:{i} Day:{j}")

    # 講師の授業パターン評価
    def teacherRuleTable(self, nTeacher, nDay, violation, cost, schedule):
        idx = np.where(schedule[:,nTeacher,:,nDay,:] > 0)
        for i in range(idx[0].size):
            self.violationTable[idx[0][i],nTeacher,idx[1][i],nDay,idx[2][i]] += violation
            self.costTable[idx[0][i],nTeacher,idx[1][i],nDay,idx[2][i]] += cost

    def teacherRuleCheck(self, schedule):
        teacherOccupation = (np.einsum('ijkml->jml', schedule) > 0).astype(np.int)
        teacherOccupation += self.database.teacher_group_reshaped
        for i in range(self.database.teacher_count):
            for j in range(self.database.day_count):
                [violation, cost] = self.teacherEval.getViolationCost(teacherOccupation[i,j,:])
                self.violation += violation
                self.cost += cost
                if self.tableEn: self.teacherRuleTable(i, j, violation, cost, schedule)
                if (violation > 0) and self.messageEn:
                    logger.info(VIOLATION_TEACHER_RULE_CHECK.format(
                        self.database.teachers[i]['lastname'],
                        self.database.teachers[i]['firstname'],
                        self.database.days[j]
                        ))
                    logger.debug(f"Teacher:{i} Day:{j}")

    # 科目組み合わせ評価
    def combinationTable(self, nTeacher, nDay, nClass, cost, schedule):
        idx = np.where(schedule[:,nTeacher,:,nDay,nClass] > 0)
        for i in range(idx[0].size):
            self.costTable[idx[0][i],nTeacher,idx[1][i],nDay,nClass] += cost

    def combinationCheck(self, schedule):
        array = np.einsum('ijkml->jkml', schedule)
        for i in range(self.database.teacher_count):
            for j in range(self.database.day_count):
                for k in range(self.database.class_count):
                    ret = self.subjectEval.getViolationCost(array[i,:,j,k])
                    self.cost += ret
                    if self.tableEn: self.combinationTable(i, j, k, ret, schedule)

    # 授業間隔評価
    def classIntervalTable(self, nStudent, nSubject, nDay1, nDay2, nClass, cost, schedule):
        if nDay1 >= 0:
            idx = np.where(schedule[nStudent,:,nSubject,nDay1,nClass] > 0)
            for i in range(idx[0].size):
                self.costTable[nStudent,idx[0][i],nSubject,nDay1,nClass] += cost
        idx = np.where(schedule[nStudent,:,nSubject,nDay2,nClass] > 0)
        for i in range(idx[0].size):
            self.costTable[nStudent,idx[0][i],nSubject,nDay2,nClass] += cost

    def classIntervalCheck(self, schedule):
        array = np.einsum('ijkml->ikml', schedule)
        for i in range(self.database.student_count):
            for j in range(self.database.personal_subject_count):
                before = -3
                for k in range(self.database.day_count):
                    for l in range(self.database.class_count):
                        if array[i,j,k,l] != 0:
                            if self.database.students[i]['grade'] == '中3' and ((k-before) <= self.database.student3g_interval_cost_count):
                                ret = self.database.student3g_interval_cost[k-before]
                            elif self.database.students[i]['grade'] != '中3' and ((k-before) <= self.database.student_interval_cost_count):
                                ret = self.database.student_interval_cost[k-before]
                            else:
                                ret = 0
                            self.cost += ret
                            if self.tableEn: self.classIntervalTable(i, j, before, k, l, ret, schedule)
                            before = k

    # 座席数チェック
    def occupationTable(self, occupation, seatnumber, schedule):
        idx1 = np.where(occupation > seatnumber)
        for i in range(idx1[0].size):
            idx2 = np.where(schedule[:,:,:,idx1[0][i],idx1[1][i]] > 0)
            for j in range(idx2[0].size):
                self.violationTable[idx2[0][j],idx2[1][j],idx2[2][j],idx1[0][i],idx1[1][i]] += occupation[idx1[0][i],idx1[1][i]] - seatnumber

    def occupationCheck(self, schedule):
        occupationPerTeacher = np.einsum('ijkml->jml', schedule)
        occupation = np.sum( np.apply_along_axis(math.Theta, 1, occupationPerTeacher), axis=0)
        for i in range(self.database.day_count):
            for j in range(self.database.class_count):
                if occupation[i,j] > self.database.seatnumber:
                    self.violation += occupation[i,j] - self.database.seatnumber
                    if self.messageEn: logger.info(VIOLATION_OCCUPATION_CHECK.format(self.database.days[i], j+1))
                    if self.messageEn: logger.debug(f"Day:{i} Class:{j}")
                    if self.tableEn: self.occupationTable(occupation, self.database.seatnumber, schedule)

    # Validation
    def timetableCheck(self, schedule):
        result = True
        classExistance = np.einsum('ijkml->ml', schedule)
        for i in range(self.database.day_count):
            for j in range(self.database.class_count):
                if self.database.timetable[i,j] == -1 and classExistance[i,j] != 0:
                    logger.error(VALIDATION_TIMETABLE_CHECK.format(self.database.days[i], j+1))
                    result = False
        return result

    def classnumberCheck(self, schedule):
        result = True
        expectedClassNumber = self.database.classnumber
        currentClassNumber = np.einsum('ijkml->ijk', schedule)
        overClassNumber = currentClassNumber - expectedClassNumber
        for i in range(self.database.student_count):
            for j in range(self.database.teacher_count):
                for k in range(self.database.personal_subject_count):
                    if overClassNumber[i,j,k] != 0:
                        logger.error(VALIDATION_CLASSNUMBER_CHECK.format(
                            self.database.students[i]['lastname'],
                            self.database.students[i]['firstname'],
                            self.database.personal_subjects[k]['name']
                            ))
                        result = False
        return result
