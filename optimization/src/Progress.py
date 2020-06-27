import numpy as np

class Progress():

    def __init__(self, database):
        self.database = database
        self.strideInitialize = 0
        self.strideImprove = 0
        self.progress = float(0)

    def startInitialize(self, countMax):
        if countMax > 0:
            self.strideInitialize = float(45) / float(countMax)
        else:
            self.strideInitialize = float(0)
        self.progress = float(0)
        self.database.write_progress(int(self.progress))

    def advanceInitialize(self):
        self.progress += self.strideInitialize
        self.database.write_progress(int(self.progress))

    def endInitialize(self):
        self.progress = float(45)
        self.database.write_progress(int(self.progress))

    def startImprove(self, countMax):
        if countMax > 0:
            self.strideImprove = float(50) / float(countMax)
        else:
            self.strideImprove = float(0)
        self.progress = float(45)
        self.database.write_progress(int(self.progress))

    def advanceImprove(self):
        self.progress += self.strideImprove
        self.database.write_progress(int(self.progress))

    def endImprove(self):
        self.progress = float(95)
        self.database.write_progress(int(self.progress))
