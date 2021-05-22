import json
import urllib.request


class UpdateOptimizationResult():
    def __init__(self, token, domain, term_id):
        self.__token = token
        self.__domain = domain
        self.__path = f"/optimization/terms/{term_id}"

    def __request_header(self):
        return {
            'Authorization': f"Basic {self.__token}",
            'Content-Type': 'application/json',
        }

    def __request_body(self, optimization_result):
        return json.dumps({'term': optimization_result}).encode()

    def execute(self, optimization_result):
        url = self.__domain + self.__path
        request = urllib.request.Request(
            url,
            self.__request_body(optimization_result),
            self.__request_header(),
            method='PUT')
        response = urllib.request.urlopen(request)
        return response
