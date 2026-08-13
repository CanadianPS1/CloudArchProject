import json
import logging
import os
import boto3
from datetime import datetime, timezone
from decimal import Decimal
from os import getenv
from uuid import uuid4

def response(code, body):
    return {
        "statusCode": code,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps(body, default=_decimal_to_float)
    }


def _decimal_to_float(obj):
    """JSON serializer helper — DynamoDB returns Decimal for numbers."""
    if isinstance(obj, Decimal):
        return float(obj)
    raise TypeError(f"Object of type {type(obj)} is not JSON serializable")


def lambda_handler(event, context):
    try:

        path_parameters = event.get("pathParameters", {})
        user_id = path_parameters.get("user_id")
        # Extract user data from the event body
        body = json.loads(event.get("body", "{}"))
        username = body.get("username")
        email = body.get("email")
        password = body.get("password")
        sql = f"""
            PATCH users
            SET
        """
        if user_id:
            sql += f" username = '{username}'"
        elif email:
            sql += f" email = '{email}'"
        elif password:
            sql += f" password = '{password}'"
        else:
            return response(400, {"error": "Missing required fields"})
        # Get the current timestamp in UTC
        updated_at = datetime.now(timezone.utc).isoformat()

        # Prepare the SQL statement to update the user
        sql = f"""
            {sql},
            WHERE user_id = '{user_id}'
        """

        # Execute the SQL statement
        client = boto3.client('rds-data')
        secret_arn = os.environ['SECRET_ARN']
        db_cluster_arn = os.environ['DB_CLUSTER_ARN']

        client.execute_statement(
            secretArn=secret_arn,
            database='AuroraDB',
            resourceArn=db_cluster_arn,
            sql=sql
        )

        return response(200, {"message": "User updated successfully"})

    except Exception as e:
        logging.error(f"Error updating user: {str(e)}")
        return response(500, {"error": str(e)})