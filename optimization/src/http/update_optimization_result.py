import json
import urllib.request


class UpdateOptimizationResult():
    def __init__(self, token, domain, term_id):
        self.__token = token
        self.__domain = domain
        self.__path = '/optimization/result'
        self.__query = f"?term_id={term_id}"

    def __request_header(self):
        return {
            'Authorization': f"Basic {self.__token}",
            'Content-Type': 'application/json',
        }

    def __request_body(self, optimization_result):
        return json.dumps(optimization_result).encode()

    def execute(self, optimization_result):
        url = self.__domain + self.__path + self.__query
        request = urllib.request.Request(
            url, self.__request_body(optimization_result), self.__request_header())
        response = urllib.request.urlopen(request)
        return response
