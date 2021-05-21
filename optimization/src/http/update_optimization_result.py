import json
import urllib.request


class UpdateOptimizationResult():
    def __init__(self, token, domain, term_id, optimization_result):
        self.__token = token
        self.__domain = domain
        self.__path = '/optimization/result'
        self.__query = f"?term_id={term_id}"
        self.__optimization_result = optimization_result

    def __request_header(self):
        return {
            'Authorization': f"Basic {self.__token}",
            'Content-Type': 'application/json',
        }

    def __request_body(self):
        return json.dumps(self.__optimization_result).encode()

    def execute(self):
        url = self.__domain + self.__path + self.__query
        request = urllib.request.Request(url, self.__request_body(), self.__request_header())
        response = urllib.request.urlopen(request)
        return response
