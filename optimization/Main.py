# -*- coding: utf-8 -*-
import os
import sys
import logging
import Database as db
import Progress as pg
import InitialState as init
import Improve as impr
import Modification as modf
import CostAndViolation as cv
logger = logging.getLogger('Main')

ERROR_IMPROVE = "異常終了しました。管理者に問い合わせてください。(ERROR_IMPROVE)"
ERROR_LOOP_COUNT_OVER = "異常終了しました。管理者に問い合わせてください。(ERROR_LOOP_COUNT_OVER)"
LOOP_COUNT_MAX = 3

def main(schedulemaster_id):
    host = os.environ['RAILS_DATABASE_HOST']
    dbname = os.environ['RAILS_DATABASE_NAME']
    user = os.environ['RAILS_DATABASE_USERNAME']
    password = os.environ['RAILS_DATABASE_PASSWORD']
    database = db.Database(host, 5432, dbname, user, password, schedulemaster_id)
    progress = pg.Progress(database)
    initial = init.InitialState(database, progress)
    schedule = initial.getNewSchedule()
    improve = impr.Improve(database, progress)
    modification = modf.Modification(database)
    for n in range(LOOP_COUNT_MAX):
        logger.info('改善を開始します')
        if not improve.runImprove(schedule):
            logger.error(ERROR_IMPROVE)
            database.write_result(ERROR_IMPROVE)
            sys.exit(-1)
        logger.info('修繕を開始します')
        if modification.runModification(schedule):
            database.write_schedules(schedule)
            modification.writeDeleteMessage()
            sys.exit(0)
    logger.error(ERROR_LOOP_COUNT_OVER)
    database.write_result(ERROR_LOOP_COUNT_OVER)
    sys.exit(-1)

if not len(sys.argv) == 3:
    sys.exit(-1)
logpath = sys.argv[1]
fmt = "%(asctime)s %(levelname)s %(name)s :%(message)s"
logging.basicConfig(level='DEBUG', filename=logpath, format=fmt)

schedulemaster_id = sys.argv[2]
main(schedulemaster_id)
