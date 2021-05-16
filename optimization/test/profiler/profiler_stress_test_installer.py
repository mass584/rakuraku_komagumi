import copy
import line_profiler
import logging
import sys
from src.array_builder.array_builder import ArrayBuilder
from src.installer.installer import Installer
from test.test_data.generate_stress_test_data import generate_stress_test_data


def stress_test_installer():
    stress_test_term_data = generate_stress_test_data()
    term_object = copy.deepcopy(stress_test_term_data)
    array_builder = ArrayBuilder(term_object=term_object)
    installer = Installer(
        term_object=term_object,
        array_builder=array_builder,
        student_optimization_rules=term_object['student_optimization_rules'],
        teacher_optimization_rule=term_object['teacher_optimization_rule'])
    installer.execute()


format = "%(asctime)s %(levelname)s %(name)s :%(message)s"
logging.basicConfig(level='INFO', filename='log/test.log', format=format)
sys.path.append('./src')

profiler = line_profiler.LineProfiler()
profiler.add_module(stress_test_installer)
profiler.runcall(stress_test_installer)
with open('log/profiler_stress_test_installer.log', 'w') as file:
    profiler.print_stats(stream=file)
