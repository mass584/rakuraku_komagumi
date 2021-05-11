import psycopg2
import psycopg2.extras


class Database():
    def __init__(self, host, port, dbname, username, password):
        self.host = host
        self.port = port
        self.dbname = dbname
        self.username = username
        self.password = password
        self.connection = None

    def connect(self):
        self.connection = psycopg2.connect(
            host=self.host,
            port=self.port,
            dbname=self.dbname,
            user=self.username,
            password=self.password)

    def cursor(self):
        if self.connection:
            return self.connection.cursor(
                cursor_factory=psycopg2.extras.DictCursor)

    def commit(self):
        if self.connection:
            self.connection.commit()

    def close(self):
        if self.connection:
            self.connection.close()
