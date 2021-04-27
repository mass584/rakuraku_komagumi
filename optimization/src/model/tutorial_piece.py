import psycopg2
import psycopg2.extras
import logging

logger = logging.getLogger('Term')

class TutorialPiece():
    def __init__(self, database, tutorial_piece_id):
        self.database = database
        self.tutorial_piece_id = tutorial_piece_id

    def update_seat_id(self, seat_id):
        self.database.connect()
        cur = self.database.cursor()
        cur.execute(f"update tutorial_pieces set seat_id = {seat_id} where id = {self.tutorial_piece_id}")
        cur.close()
        self.database.commit()
        self.database.close()
