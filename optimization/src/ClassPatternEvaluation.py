import numpy as np

class ClassPatternEvaluation():

    def __init__(self, nClass, totalClassMax, totalClassCost, blankClassMax, blankClassCost):
        self.nClass = nClass
        self.totalClassMax = totalClassMax
        self.totalClassCost = totalClassCost
        self.blankClassMax = blankClassMax
        self.blankClassCost = blankClassCost
        self.cost = np.zeros(2**self.nClass, dtype='int32')
        self.violation = np.zeros(2**self.nClass, dtype='int32')
        self.transform_array = np.logspace(0, self.nClass, num=self.nClass, endpoint=False, base=2, dtype='int32')

    def setViolationCost(self):
        for i in range(2**self.nClass):
            totalClass = 0
            blankClass = 0
            blankClassTmp = 0
            classBegin = False
            for j in range(self.nClass):
                if (i>>j & 1):
                    totalClass += 1
                    if (blankClassTmp >= 1 and classBegin):
                        blankClass += blankClassTmp
                    classBegin = True
                    blankClassTmp = 0
                else:
                    blankClassTmp += 1
            # Factor 1 : cost for total class
            if totalClass > self.totalClassMax:
                self.violation[i] = totalClass - self.totalClassMax
            else:
                self.cost[i] = self.totalClassCost[totalClass]
            # Factor 2 : cost for blank class
            if blankClass > self.blankClassMax:
                self.violation[i] += blankClass - self.blankClassMax
            else:
                self.cost[i] += self.blankClassCost[blankClass]
        return

    # oneDay <list of integer> : 一日の授業の有無, 0 or 1
    def getViolationCost(self, oneDay):
        arg = np.dot(self.transform_array, oneDay)
        return [self.violation[arg], self.cost[arg]]

