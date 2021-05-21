import urllib.request


class FetchOptimizationTerm():
    def __init__(self, token, domain, term_id):
        self.__token = token
        self.__domain = domain
        self.__path = '/optimization/term'
        self.__query = f"?term_id={term_id}"

    def __request_header(self):
        return {
            'Authorization': f"Basic {self.__token}",
        }

    def fetch(self):
        url = self.__domain + self.__path + self.__query
        request = urllib.request.Request(url=url, header=self.__request_header())
        response = urllib.request.urlopen(request)
        response_body = response.read()
        return response_body
