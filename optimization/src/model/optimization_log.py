import numpy as np


class OptimizationLog():
    def __init__(self, database, optimization_log_id):
        self.database = database
        self.optimization_log_id = 0
        self.installation_progress = 0
        self.swapping_progress = 0
        self.deletion_progress = 0

    def add_installation_progress(self):
        self.installation_progress += 1
        self.database.connect()
        cursor = self.database.cursor()
        sql_update = (
            f"terms set installation_progress = {self.installation_progress}")
        sql_where = f"id = {self.optimization_log_id}"
        cursor.execute(' '.join(['update', sql_update, 'where', sql_where]))
        cursor.close()
        self.database.commit()
        self.database.close()

    def add_swapping_progress(self):
        self.swapping_progress += 1
        self.database.connect()
        cursor = self.database.cursor()
        sql_update = (
            f"update terms set swapping_progress = {self.swapping_progress}")
        sql_where = f"where id = {self.optimization_log_id}"
        cursor.execute(' '.join([sql_update, sql_where]))
        cursor.close()
        self.database.commit()
        self.database.close()

    def add_deletion_progress(self):
        self.deletion_progress += 1
        self.database.connect()
        cursor = self.database.cursor()
        sql_update = (
            f"update terms set deletion_progress = {self.deletion_progress}")
        sql_where = f"where id = {self.optimization_log_id}"
        cursor.execute(' '.join([sql_update, sql_where]))
        cursor.close()
        self.database.commit()
        self.database.close()
