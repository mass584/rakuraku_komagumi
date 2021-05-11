import psycopg2
import psycopg2.extras


class TutorialPiece():
    def __init__(self, database, tutorial_piece_id):
        self.database = database
        self.tutorial_piece_id = tutorial_piece_id

    def update_seat_id(self, seat_id):
        self.database.connect()
        cur = self.database.cursor()
        sql_update = f"tutorial_pieces set seat_id = {seat_id}"
        sql_where = f"id = {self.tutorial_piece_id}"
        cur.execute(' '.join(['update', sql_update, 'where', sql_where]))
        cur.close()
        self.database.commit()
        self.database.close()
