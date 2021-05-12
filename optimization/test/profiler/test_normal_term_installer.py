import line_profiler
from test.installer import test_installer
from src.installer import installer


test_runner = test_installer.TestInstaller()
profiler = line_profiler.LineProfiler()
profiler.add_module(installer)
profiler.runcall(test_runner.test_normal_term_installer)
with open('test/profiler/test_normal_term_installer.log', 'w') as file:
    profiler.print_stats(stream=file)
