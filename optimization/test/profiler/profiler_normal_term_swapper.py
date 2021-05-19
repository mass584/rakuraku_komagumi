import line_profiler
from test.swapper import test_swapper
from src.swapper import swapper
from src.tutorial_piece_evaluator import tutorial_piece_evaluator


test_runner = test_swapper.TestSwapper()
profiler = line_profiler.LineProfiler()
profiler.add_module(swapper)
profiler.add_module(tutorial_piece_evaluator)
profiler.runcall(test_runner.test_normal_term_swapper)
with open('log/profiler_normal_term_swapper.log', 'w') as file:
    profiler.print_stats(stream=file)
