import json
import urllib.request


class UpdateOptimizationLog():
    def __init__(self, token, domain, term_id, optimization_log):
        self.__token = token
        self.__domain = domain
        self.__path = '/optimization/log'
        self.__query = f"?term_id={term_id}"
        self.__optimization_log = optimization_log

    def __request_header(self):
        return {
            'Authorization': f"Basic {self.__token}",
            'Content-Type': 'application/json',
        }

    def __request_body(self):
        return json.dumps(self.__optimization_log).encode()

    def execute(self):
        url = self.__domain + self.__path + self.__query
        request = urllib.request.Request(url, self.__request_body(), self.__request_header())
        response = urllib.request.urlopen(request)
        return response
