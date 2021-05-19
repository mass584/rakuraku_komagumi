import logging
import os

from array_builder.array_builder import ArrayBuilder
from cost_evaluator.cost_evaluator import CostEvaluator
from database.database import Database
from installer.installer import Installer
from model.term_object import TermObject
from tutorial_piece_evaluator.tutorial_piece_evaluator import TutorialPieceEvaluator
from swapper.swapper import Swapper
from deletion.deletion import Deletion


def main():
    host = os.environ['DATABASE_HOST']
    dbname = os.environ['DATABASE_NAME']
    username = os.environ['DATABASE_USERNAME']
    password = os.environ['DATABASE_PASSWORD']
    term_id = os.environ['OPTIMIZATION_TERM_ID']
    optimization_env = os.environ['OPTIMIZATION_ENV']
    process_count = os.environ['OPTIMIZATION_PROCESS_COUNT']

    format = "%(asctime)s %(levelname)s %(name)s :%(message)s"
    level = 'DEBUG' if optimization_env == 'development' else 'INFO'
    filename = f"log/{optimization_env}.log"
    logging.basicConfig(level=level, filename=filename, format=format)

    database = Database(
        host=host,
        port=5432,
        dbname=dbname,
        username=username,
        password=password)
    term_object = TermObject(database=database, term_id=term_id).fetch()
    array_builder = ArrayBuilder(term_object=term_object)
    cost_evaluator = CostEvaluator(
        array_size=array_builder.array_size(),
        student_optimization_rules=term_object['student_optimization_rules'],
        teacher_optimization_rule=term_object['teacher_optimization_rule'],
        student_group_occupation=array_builder.student_group_occupation_array(),
        teacher_group_occupation=array_builder.teacher_group_occupation_array(),
        student_vacancy=array_builder.student_vacancy_array(),
        teacher_vacancy=array_builder.teacher_vacancy_array(),
        school_grades=array_builder.school_grade_array())
    tutorial_piece_evaluator = TutorialPieceEvaluator(
        array_size=array_builder.array_size(),
        student_optimization_rules=term_object['student_optimization_rules'],
        teacher_optimization_rule=term_object['teacher_optimization_rule'],
        student_group_occupation=array_builder.student_group_occupation_array(),
        teacher_group_occupation=array_builder.teacher_group_occupation_array(),
        student_vacancy=array_builder.student_vacancy_array(),
        teacher_vacancy=array_builder.teacher_vacancy_array(),
        school_grades=array_builder.school_grade_array())
    installer = Installer(
        process_count=process_count,
        term_object=term_object,
        array_size=array_builder.array_size(),
        tutorial_piece_count_array=array_builder.tutorial_piece_count_array(),
        timetable_array=array_builder.timetable_array(),
        tutorial_occupation_array=array_builder.tutorial_occupation_array(),
        cost_evaluator=cost_evaluator)
    installer.execute()
    swapper = Swapper(
        process_count=process_count,
        term_object=term_object,
        array_size=array_builder.array_size(),
        timetable_array=array_builder.timetable_array(),
        tutorial_occupation_array=array_builder.tutorial_occupation_array(),
        fixed_tutorial_occupation_array=array_builder.fixed_tutorial_occupation_array(),
        tutorial_piece_count_array=array_builder.tutorial_piece_count_array(),
        cost_evaluator=cost_evaluator,
        tutorial_piece_evaluator=tutorial_piece_evaluator)
    swapper.execute()
    deletion = Deletion(
        term_object=term_object,
        tutorial_occupation_array=array_builder.tutorial_occupation_array(),
        fixed_tutorial_occupation_array=array_builder.fixed_tutorial_occupation_array(),
        tutorial_piece_count_array=array_builder.tutorial_piece_count_array(),
        cost_evaluator=cost_evaluator,
        tutorial_piece_evaluator=tutorial_piece_evaluator)
    deletion.execute()


if __name__ == '__main__':
    main()
