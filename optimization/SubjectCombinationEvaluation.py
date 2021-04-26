import numpy as np

class SubjectCombinationEvaluation():

    # tutorial_indexject <integer> : 科目数
    def __init__(self, tutorial_indexject, singleCost, differentPairCost):
        self.tutorial_indexject = tutorial_indexject
        self.singleCost = singleCost
        self.differentPairCost = differentPairCost

    # occupation <list of integer> : 科目ごとの指導数
    def getViolationCost(self, occupation):
        s = sum(occupation)
        if s == 0:
            return 0
        elif s == 1:
            return self.singleCost
        elif s == 2:
            if 1 in occupation:
                return self.differentPairCost
            else:
                return 0
        else:
            return 0

