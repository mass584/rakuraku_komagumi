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

logger = logging.getLogger()
log_filename = "log_filename"
log_format = "%(asctime)s %(levelname)s %(name)s :%(message)s"
logging.basicConfig(level='INFO', filename=log_filename, format=log_format)

ERROR_IMPROVE = "異常終了しました。管理者に問い合わせてください。(ERROR_IMPROVE)"
ERROR_LOOP_COUNT_OVER = "異常終了しました。管理者に問い合わせてください。(ERROR_LOOP_COUNT_OVER)"
LOOP_COUNT_MAX = 3

def main():
    host = os.environ['DATABASE_HOST']
    dbname = os.environ['DATABASE_NAME']
    username = os.environ['DATABASE_USERNAME']
    password = os.environ['DATABASE_PASSWORD']
    database = db.Database(host, 5432, dbname, username, password)
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

main()
