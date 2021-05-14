import logging
import sys

format = "%(asctime)s %(levelname)s %(name)s :%(message)s"
logging.basicConfig(level='INFO', filename='log/test.log', format=format)
sys.path.append('./src')
