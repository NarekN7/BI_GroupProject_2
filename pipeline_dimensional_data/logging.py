import logging
import os


def setup_logger(execution_id, log_file="logs/logs_dimensional_data_pipeline.txt"):
    """
    Sets up a logger for dimensional data flow with execution_id included in every log entry.
    :param execution_id: Unique ID for tracking the execution instance.
    :param log_file: Path to the log file.
    :return: Configured logger.
    """
  
    log_dir = os.path.dirname(log_file)
    if not os.path.exists(log_dir):
        os.makedirs(log_dir)

    logger = logging.getLogger(f"DimensionalDataFlow_{execution_id}")
    logger.setLevel(logging.DEBUG)

    formatter = logging.Formatter(
        fmt="%(asctime)s - %(levelname)s - Execution ID: %(execution_id)s - %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S"
    )



    file_handler = logging.FileHandler(log_file)
    file_handler.setLevel(logging.DEBUG)
    file_handler.setFormatter(formatter)

    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.INFO)
    console_handler.setFormatter(formatter)

    class ExecutionIDFilter(logging.Filter):
        def __init__(self, execution_id):
            super().__init__()
            self.execution_id = execution_id

        def filter(self, record):
            record.execution_id = self.execution_id
            return True

    logger.addFilter(ExecutionIDFilter(execution_id))
    logger.addHandler(file_handler)
    logger.addHandler(console_handler)

    return logger


setup_logger(execution_id, log_file="logs/logs_dimensional_data_pipeline.txt")