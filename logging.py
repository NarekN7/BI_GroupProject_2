import logging
import uuid
from datetime import datetime

def setup_logger():
    """
    Sets up a logger for the dimensional data flow.
    Returns:
        logger (logging.Logger): Configured logger instance.
    """
    execution_id = str(uuid.uuid4())

    logger = logging.getLogger("DimensionalDataFlowLogger")
    logger.setLevel(logging.DEBUG)


    log_formatter = logging.Formatter(
        fmt="%(asctime)s | ExecutionID: %(execution_id)s | %(levelname)s | %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S"
    )

    log_formatter._fmt = log_formatter._fmt.replace("%(execution_id)s", execution_id)

    file_handler = logging.FileHandler("logs/logs_dimensional_data_pipeline.txt")
    file_handler.setLevel(logging.DEBUG)
    file_handler.setFormatter(log_formatter)

    logger.addHandler(file_handler)

    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.INFO)
    console_handler.setFormatter(log_formatter)
    logger.addHandler(console_handler)

    logger.info(f"Logger setup complete. Execution ID: {execution_id}")

    return logger, execution_id
