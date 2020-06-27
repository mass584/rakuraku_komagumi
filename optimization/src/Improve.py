import os
import time
import numpy as np
import CostAndViolation as cv
import logging
logger = logging.getLogger('Improve')

class Improve():

    def __init__(self, database, progress):
        self.database = database
        self.progress = progress
        self.cv1 = cv.CostAndViolation(database)
        self.cv2 = cv.CostAndViolation(database)
        self.timetable = database.timetable
        self.classnumber = database.classnumber
        self.fixedSchedule = database.schedule_fixonly
        self.nBefore = 0

    # コスト・違反評価値が最も小さくなる移動先(第一近傍)を探します
    # schedule : 編集対象となるスケジュール
    # candidateIndex : 移動候補となるスケジュール
    def getBestFirstNeighborhood(self, schedule, candidateIndex):
        bestValue = np.inf
        for i in range(self.database.day_count):
            for j in range(self.database.class_count):
                if self.timetable[i, j] != 0: continue
                if schedule[candidateIndex[0],candidateIndex[1],candidateIndex[2],i,j] != 0: continue
                # 一時的にスケジュール変更
                schedule[candidateIndex[0],candidateIndex[1],candidateIndex[2],candidateIndex[3],candidateIndex[4]] = 0
                schedule[candidateIndex[0],candidateIndex[1],candidateIndex[2],i,j] = 1
                candidateValue = self.cv2.getCostAndViolation(schedule)
                if candidateValue < bestValue:
                    bestValue = candidateValue; bestDay = i; bestClass = j
                # 一時的にスケジュール変更したものを戻す
                schedule[candidateIndex[0],candidateIndex[1],candidateIndex[2],i,j] = 0
                schedule[candidateIndex[0],candidateIndex[1],candidateIndex[2],candidateIndex[3],candidateIndex[4]] = 1
        return [bestValue, bestDay, bestClass]

    # コスト・違反評価値が最も小さくなる移動先(第二近傍)を探します
    # schedule : 編集対象となるスケジュール
    # candidateIndex : 移動候補となるスケジュール
    def getBestSecondNeighborhood(self, schedule, candidateIndex):
        bestValue = np.inf; bestStudent = 0; bestSubject = 0;  bestDay = 0; bestClass = 0
        for i in range(self.database.student_count):
            for j in range(self.database.personal_subject_count):
                if i == candidateIndex[0] and j == candidateIndex[2]: continue
                if schedule[i,candidateIndex[1],j,candidateIndex[3],candidateIndex[4]] == 0: continue
                if self.fixedSchedule[i,candidateIndex[1],j,candidateIndex[3],candidateIndex[4]]: continue
                for k in range(self.database.day_count):
                    for l in range(self.database.class_count):
                        if k == candidateIndex[3] and l == candidateIndex[4]: continue
                        if self.timetable[k, l] != 0: continue
                        if schedule[candidateIndex[0],candidateIndex[1],candidateIndex[2],k,l] == 1: continue
                        if schedule[i,candidateIndex[1],j,k,l] == 1: continue
                        # 一時的にスケジュール変更
                        schedule[candidateIndex[0],candidateIndex[1],candidateIndex[2],candidateIndex[3],candidateIndex[4]] = 0
                        schedule[i,candidateIndex[1],j,candidateIndex[3],candidateIndex[4]] = 0
                        schedule[candidateIndex[0],candidateIndex[1],candidateIndex[2],k,l] = 1
                        schedule[i,candidateIndex[1],j,k,l] = 1
                        candidateValue = self.cv2.getCostAndViolation(schedule)
                        if candidateValue < bestValue:
                            bestValue = candidateValue; bestStudent = i; bestSubject = j;  bestDay = k; bestClass = l
                        # 一時的にスケジュール変更したものを戻す
                        schedule[candidateIndex[0],candidateIndex[1],candidateIndex[2],k,l] = 0
                        schedule[i,candidateIndex[1],j,k,l] = 0
                        schedule[candidateIndex[0],candidateIndex[1],candidateIndex[2],candidateIndex[3],candidateIndex[4]] = 1
                        schedule[i,candidateIndex[1],j,candidateIndex[3],candidateIndex[4]] = 1
        return [bestValue, bestStudent, bestSubject, bestDay, bestClass]

    # コスト・違反評価値が最も小さくなる移動先(第三近傍)を探します
    # schedule : 編集対象となるスケジュール
    # candidateIndex : 移動候補となるスケジュール
    def getBestThirdNeighborhood(self, schedule, candidateIndex):
        bestValue = np.inf; bestStudent = 0; bestSubject = 0;  bestDay = 0; bestClass = 0
        for i in range(self.database.student_count):
            for j in range(self.database.personal_subject_count):
                if i == candidateIndex[0] and j == candidateIndex[2]: continue
                for k in range(self.database.day_count):
                    for l in range(self.database.class_count):
                        if k == candidateIndex[3] and l == candidateIndex[4]: continue
                        if self.timetable[k, l] != 0: continue
                        if schedule[i,candidateIndex[1],j,k,l] == 0: continue
                        if self.fixedSchedule[i,candidateIndex[1],j,k,l]: continue
                        if schedule[i,candidateIndex[1],j,candidateIndex[3],candidateIndex[4]] == 1: continue
                        if schedule[candidateIndex[0],candidateIndex[1],candidateIndex[2],k,l] == 1: continue
                        # 一時的にスケジュール変更
                        schedule[candidateIndex[0],candidateIndex[1],candidateIndex[2],candidateIndex[3],candidateIndex[4]] = 0
                        schedule[i,candidateIndex[1],j,k,l] = 0
                        schedule[candidateIndex[0],candidateIndex[1],candidateIndex[2],k,l] = 1
                        schedule[i,candidateIndex[1],j,candidateIndex[3],candidateIndex[4]] = 1
                        candidateValue = self.cv2.getCostAndViolation(schedule)
                        if candidateValue < bestValue:
                            bestValue = candidateValue; bestStudent = i; bestSubject = j; bestDay = k; bestClass = l
                        # 一時的にスケジュール変更したものを戻す
                        schedule[candidateIndex[0],candidateIndex[1],candidateIndex[2],k,l] = 0
                        schedule[i,candidateIndex[1],j,candidateIndex[3],candidateIndex[4]] = 0
                        schedule[candidateIndex[0],candidateIndex[1],candidateIndex[2],candidateIndex[3],candidateIndex[4]] = 1
                        schedule[i,candidateIndex[1],j,k,l] = 1
        return [bestValue, bestStudent, bestSubject, bestDay, bestClass]

    def execImproveFirstNeighborhood(self, schedule, candidateIndex, candidateDay, candidateClass):
        schedule[candidateIndex[0],candidateIndex[1],candidateIndex[2],candidateIndex[3],candidateIndex[4]] = 0
        schedule[candidateIndex[0],candidateIndex[1],candidateIndex[2],candidateDay,candidateClass] = 1
        logger.debug(f"Improved by 1st neighborhood replacement.")
        logger.debug(f"Target Schedule : student:{candidateIndex[0]} teacher:{candidateIndex[1]} subject:{candidateIndex[2]}")
        logger.debug(f"From            : day:{candidateIndex[3]} class:{candidateIndex[4]}")
        logger.debug(f"To              : day:{candidateDay} class:{candidateClass}")
        return

    def execImproveSecondNeighborhood(self, schedule, candidateIndex, candidateStudent, candidateSubject, candidateDay, candidateClass):
        schedule[candidateIndex[0],candidateIndex[1],candidateIndex[2],candidateIndex[3],candidateIndex[4]] = 0
        schedule[candidateStudent,candidateIndex[1],candidateSubject,candidateIndex[3],candidateIndex[4]] = 0
        schedule[candidateIndex[0],candidateIndex[1],candidateIndex[2],candidateDay,candidateClass] = 1
        schedule[candidateStudent,candidateIndex[1],candidateSubject,candidateDay,candidateClass] = 1
        logger.debug(f"Improved by 2nd neighborhood replacement.")
        logger.debug(f"Target Schedule A : student:{candidateIndex[0]} teacher:{candidateIndex[1]} subject:{candidateIndex[2]}")
        logger.debug(f"Target Schedule B : student:{candidateStudent} teacher:{candidateIndex[1]} subject:{candidateSubject}")
        logger.debug(f"From              : day:{candidateIndex[3]} class:{candidateIndex[4]}")
        logger.debug(f"To                : day:{candidateDay} class:{candidateClass}")
        return

    def execImproveThirdNeighborhood(self, schedule, candidateIndex, candidateStudent, candidateSubject, candidateDay, candidateClass):
        schedule[candidateIndex[0],candidateIndex[1],candidateIndex[2],candidateIndex[3],candidateIndex[4]] = 0
        schedule[candidateStudent,candidateIndex[1],candidateSubject,candidateDay,candidateClass] = 0
        schedule[candidateIndex[0],candidateIndex[1],candidateIndex[2],candidateDay,candidateClass] = 1
        schedule[candidateStudent,candidateIndex[1],candidateSubject,candidateIndex[3],candidateIndex[4]] = 1
        logger.debug(f"Improved by 3rd neighborhood replacement.")
        logger.debug(f"Swap Schedule A : student:{candidateIndex[0]} teacher:{candidateIndex[1]} subject:{candidateIndex[2]}")
        logger.debug(f"                  day:{candidateIndex[3]} class:{candidateIndex[4]}")
        logger.debug(f"Swap Schedule B : student:{candidateStudent} teacher:{candidateIndex[1]} subject:{candidateSubject}")
        logger.debug(f"                  day:{candidateDay} class:{candidateClass}")
        return

    def improveOneTime(self, schedule):
        improved = False
        self.cv1.tableEn = True
        originalValue = self.cv1.getCostAndViolation(schedule)
        violationExist = (self.cv1.violation > 0)
        totalScheduleNumber = int(np.sum(self.classnumber))
        tryOrder = list(range(self.nBefore, totalScheduleNumber)) + list(range(0, self.nBefore))
        for n in tryOrder:
            candidateIndex = self.cv1.getNthElementFromWorst(n)
            if violationExist and self.cv1.violationTable[candidateIndex[0],candidateIndex[1],candidateIndex[2],candidateIndex[3],candidateIndex[4]] == 0: continue
            if self.fixedSchedule[candidateIndex[0],candidateIndex[1],candidateIndex[2],candidateIndex[3],candidateIndex[4]]: continue
            if not schedule[candidateIndex[0],candidateIndex[1],candidateIndex[2],candidateIndex[3],candidateIndex[4]]: continue
            # 第1〜第3近傍置換を行った時の最善解
            candidateValue = [np.inf, np.inf, np.inf]
            [candidateValue[0], candidateDay1, candidateClass1] \
              = self.getBestFirstNeighborhood(schedule, candidateIndex)
            [candidateValue[1], candidateStudent2, candidateSubject2, candidateDay2, candidateClass2] \
              = self.getBestSecondNeighborhood(schedule, candidateIndex)
            [candidateValue[2], candidateStudent3, candidateSubject3, candidateDay3, candidateClass3] \
              = self.getBestThirdNeighborhood(schedule, candidateIndex)
            bestCandidateIndex = candidateValue.index(min(candidateValue))
            if candidateValue[bestCandidateIndex] >= originalValue: continue
            # 改善方法が見つかった場合の処理
            logger.debug(f"===============================================================")
            if bestCandidateIndex == 0:
                self.execImproveFirstNeighborhood(schedule, candidateIndex, candidateDay1, candidateClass1)
            elif bestCandidateIndex == 1:
                self.execImproveSecondNeighborhood(schedule, candidateIndex, candidateStudent2, candidateSubject2, candidateDay2, candidateClass2)
            elif bestCandidateIndex == 2:
                self.execImproveThirdNeighborhood(schedule, candidateIndex, candidateStudent3, candidateSubject3, candidateDay3, candidateClass3)
            logger.debug(f"{n+1}th schedule from worst")
            logger.debug(f"Original cost-violation : {originalValue}")
            logger.debug(f"Changed  cost-violation : {candidateValue[bestCandidateIndex]}")
            self.nBefore = n
            improved = True
            break
        return improved

    def runImprove(self, schedule):
        count = 0
        startUnixTimeSec = int(time.time())
        self.progress.startImprove(self.database.max_count)
        while True:
            if not self.improveOneTime(schedule):
                logger.info("Finished the improvement because better solutions cannot find.")
                break
            count += 1
            self.progress.advanceImprove()
            logger.debug(f"Improved {count} times")
            if self.database.max_count > 0 and count == self.database.max_count:
                logger.info("Finished the improvement because the improvement loop number reached maximum number.")
                break
            nowUnixTimeSec = int(time.time())
            elapsedTimeSec = nowUnixTimeSec - startUnixTimeSec
            if self.database.max_time_sec > 0 and elapsedTimeSec > self.database.max_time_sec:
                logger.info("Finished the improvement by timeout.")
                break
        self.progress.endImprove()
        final = self.cv2.getCostAndViolation(schedule)
        logger.info(f"Evaluation value:{final}")
        return self.cv2.validation(schedule)

