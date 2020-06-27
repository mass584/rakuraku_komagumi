import os
import unittest
import subprocess

class TestTashizan(unittest.TestCase):

    # =====================================
    # Finished Condition   : Complete
    # Fixed Schedule       : Not Available
    # Conclusive Violation : Not Available
    # Group Class          : Not Available
    # =====================================
    def test000(self):
        testDir = './TestData000'
        maxCount = 20
        maxTimeSec = 0
        ret = self.execMain(testDir, maxCount, maxTimeSec)
        self.assertEqual(ret, 0)

    # =====================================
    # Finished Condition   : Complete
    # Fixed Schedule       : Available
    # Conclusive Violation : Not Available
    # Group Class          : Not Available
    # =====================================
    def test001(self):
        testDir = './TestData001'
        maxCount = 20
        maxTimeSec = 0
        ret = self.execMain(testDir, maxCount, maxTimeSec)
        self.assertEqual(ret, 0)

    # =====================================
    # Finished Condition   : Complete
    # Fixed Schedule       : Not Available
    # Conclusive Violation : Available
    # Group Class          : Not Available
    # =====================================
    def test002(self):
        testDir = './TestData002'
        maxCount = 20
        maxTimeSec = 0
        ret = self.execMain(testDir, maxCount, maxTimeSec)
        self.assertEqual(ret, 0)

    # =====================================
    # Finished Condition   : Complete
    # Fixed Schedule       : Not Available
    # Conclusive Violation : Not Available
    # Group Class          : Available
    # =====================================
    def test003(self):
        testDir = './TestData003'
        maxCount = 20
        maxTimeSec = 0
        ret = self.execMain(testDir, maxCount, maxTimeSec)
        self.assertEqual(ret, 0)

    def execMain(self, testDir, maxCount, maxTimeSec):
        generatedScheduleFile = testDir + '/GeneratedSchedule.dat'
        logFile = testDir + '/focusopt.log'
        if os.path.exists(generatedScheduleFile): os.remove(generatedScheduleFile)
        if os.path.exists(logFile): os.remove(logFile)
        args = ['python', '../Main.py', testDir, str(maxCount), str(maxTimeSec)]
        return subprocess.call(args)

if __name__ == "__main__":
    unittest.main()

