from pipeline_dimensional_data.flow import DimensionalDataFlow

if __name__ == "__main__":
    # Define start and end dates for execution
    START_DATE = "2024-01-01"
    END_DATE = "2024-12-31"

    # Create an instance of the DimensionalDataFlow class
    flow = DimensionalDataFlow()

    # Execute the data pipeline
    result = flow.exec(START_DATE, END_DATE)

    # Print the execution result
    if result["success"]:
        print(f"Pipeline executed successfully with Execution ID: {result['execution_id']}")
    else:
        print(f"Pipeline failed with Execution ID: {result['execution_id']}. Error: {result['error']}")
