import json
import boto3
from os import getenv
from decimal import Decimal
import logging
import os

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

        # Extract user ID from the event body
        body = json.loads(event.get("body", "{}"))
        user_id = body.get("user_id")

        if not user_id:
            return response(400, {"error": "Missing required field: user_id"})

        # Prepare the SQL statement to delete the user
        sql = f"DELETE FROM users WHERE user_id = '{user_id}'"

        # Execute the SQL statement
        client.execute_statement(
            secretArn=secret_arn,
            database='AuroraDB',
            resourceArn=db_cluster_arn,
            sql=sql
        )

        return response(200, {"message": "User deleted successfully"})

    except Exception as e:
        logging.error(f"Error deleting user: {str(e)}")
        return response(500, {"error": str(e)})