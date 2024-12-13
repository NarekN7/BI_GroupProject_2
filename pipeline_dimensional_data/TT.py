from pipeline_dimensional_data.flow import DimensionalDataFlow

if name == "__main__":
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


