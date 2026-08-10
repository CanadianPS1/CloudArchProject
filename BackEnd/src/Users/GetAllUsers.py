import json
import os 
import boto3
from decimal import Decimal
from os import getenv


def response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
        },
        "body": json.dumps(body, default=decimalToFloat),
    }

def decimalToFloat(obj):
    if isinstance(obj, Decimal):
        return float(obj)
    raise TypeError(f"Object of type {type(obj)} is not JSON serializable")

def lambdaHandler(event, context):
    try:
        client = boto3.client('rds-data')
        secret_arn = os.environ['SECRET_ARN']
        db_cluster_arn = os.environ['DB_CLUSTER_ARN']

        # Example: Execute a SQL query
        response = client.execute_statement(
            secretArn=secret_arn,
            database='AuroraDB',
            resourceArn=db_cluster_arn,
            sql='SELECT * FROM users'
        )

        # Extract the records from the response
        records = response.get("records", [])

        # Convert the records to a list of dictionaries
        users = []
        for record in records:
            user = {column['name']: column['value'] for column in record}
            users.append(user)

        return response(200, {"users": users})

    except Exception as e:
        return response(500, {"error": str(e)})