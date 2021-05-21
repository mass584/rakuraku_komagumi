class OptimizationLog():
    def __init__(self, update_optimization_log):
        self.__update_optimization_log = update_optimization_log
        self.__sequence_number = 0
        self.__installation_progress = 0
        self.__swapping_progress = 0
        self.__deletion_progress = 0
        self.__exit_message = None
        self.__exit_status = 0

    def __write(self):
        request_body = {
            'sequence_number': self.__sequence_number,
            'installation_progress': self.__installation_progress,
            'swapping_progress': self.__swapping_progress,
            'deletion_progress': self.__deletion_progress,
            'exit_message': self.__exit_message,
            'exit_status': self.__exit_status,
        }
        self.__update_optimization_log.execute(request_body)

    def start_installation(self):
        self.__sequence_number = 1
        self.__write()

    def start_swapping(self):
        self.__sequence_number = 2
        self.__write()

    def start_deletion(self):
        self.__sequence_number = 3
        self.__write()

    def start_finalize(self):
        self.__sequence_number = 4
        self.__write()

    def increment_installation_progress(self):
        self.__installation_progress += 1
        self.__write()

    def increment_swapping_progress(self):
        self.__swapping_progress += 1
        self.__write()

    def increment_deletion_progress(self):
        self.__deletion_progress += 1
        self.__write()

    def write_success_status(self, exit_message):
        self.__exit_message = exit_message
        self.__exit_status = 1
        self.__write()

    def write_fail_status(self, exit_message):
        self.__exit_message = exit_message
        self.__exit_status = 2
        self.__write()
