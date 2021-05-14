import line_profiler
from test.installer import test_installer
from src.installer import installer
from src.cost_evaluator import cost_evaluator


test_runner = test_installer.TestInstaller()
profiler = line_profiler.LineProfiler()
profiler.add_module(installer)
profiler.add_module(cost_evaluator)
profiler.runcall(test_runner.test_exam_planning_term_installer)
with open('log/profiler/exam_planning_term_installer.log', 'w') as file:
    profiler.print_stats(stream=file)
