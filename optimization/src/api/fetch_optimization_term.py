import json
import urllib.request


class FetchOptimizationTerm():
    def __init__(self, token, domain, term_id):
        self.__token = token
        self.__domain = domain
        self.__path = f"/optimization/terms/{term_id}"

    def __request_header(self):
        return {
            'Authorization': f"Basic {self.__token}",
        }

    def fetch(self):
        url = self.__domain + self.__path
        request = urllib.request.Request(url, headers=self.__request_header())
        with urllib.request.urlopen(request) as response:
            response_body = json.loads(response.read())
        return response_body
