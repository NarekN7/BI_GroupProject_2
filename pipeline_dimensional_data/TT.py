import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from pipeline_dimensional_data.flow import DimensionalDataFlow
from utils import *


if __name__ == "__main__":
    START_DATE = "2024-01-01"
    END_DATE = "2024-12-31"

    # Instantiate the DimensionalDataFlow class
    pipeline = DimensionalDataFlow()

    # Execute the pipeline
    result = pipeline.exec(START_DATE, END_DATE)
    print(result)
    # Print the result
    # if result["success"]:
    #     print(f"Pipeline executed successfully with Execution ID: {result['execution_id']}")
    # else:
    #     print(f"Pipeline failed with Execution ID: {result['execution_id']}. Error: {result['error']}")




