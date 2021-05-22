import json
import urllib.request


class UpdateOptimizationLog():
    def __init__(self, token, domain, log_id):
        self.__token = token
        self.__domain = domain
        self.__path = f"/optimization/logs/{log_id}"

    def __request_header(self):
        return {
            'Authorization': f"Basic {self.__token}",
            'Content-Type': 'application/json',
        }

    def __request_body(self, optimization_log):
        return json.dumps({'optimization_log': optimization_log}).encode()

    def execute(self, optimization_log):
        url = self.__domain + self.__path
        request = urllib.request.Request(
            url,
            self.__request_body(optimization_log),
            self.__request_header(),
            method='PUT')
        response = urllib.request.urlopen(request)
        return response
