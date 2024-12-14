from pipeline_dimensional_data.flow import DimensionalDataFlow

if __name__ == "__main__":
    START_DATE = "2024-01-01"
    END_DATE = "2024-12-31"


    flow = DimensionalDataFlow()

    result = flow.exec(START_DATE, END_DATE)

    if result["success"]:
        print(f"Pipeline executed successfully with Execution ID: {result['execution_id']}")
    else:
        print(f"Pipeline failed with Execution ID: {result['execution_id']}. Error: {result['error']}")
