import logging
import os
from array_builder.array_builder import ArrayBuilder
from database.database import Database
from installer.installer import Installer
from model.term_object import TermObject


def main():
    host = os.environ['DATABASE_HOST']
    dbname = os.environ['DATABASE_NAME']
    username = os.environ['DATABASE_USERNAME']
    password = os.environ['DATABASE_PASSWORD']
    term_id = os.environ['OPTIMIZATION_TERM_ID']
    format = "%(asctime)s %(levelname)s %(name)s :%(message)s"
    filename = f"optimization_{term_id}.log"
    logging.basicConfig(level='DEBUG', filename=filename, format=format)
    database = Database(
        host=host,
        port=5432,
        dbname=dbname,
        username=username,
        password=password)
    term_object = TermObject(database=database, term_id=term_id).fetch()
    array_builder = ArrayBuilder(term_object=term_object)
    installer = Installer(
        array_builder=array_builder,
        student_optimization_rules=term_object['student_optimization_rules'],
        teacher_optimization_rule=term_object['teacher_optimization_rule'])
    installer.execute()

main()
