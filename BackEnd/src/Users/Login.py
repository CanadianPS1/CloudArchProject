import json
import logging
import os
import boto3
import base64
import cryptography
from datetime import datetime, timezone
from decimal import Decimal
from os import getenv
from uuid import uuid4
from BackEnd.src import AuthTool


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

def decrypt_password(encrypted_password, encryption_key):
    try:
        encrypted_bytes = encrypted_password.encode('utf-8') if isinstance(encrypted_password, str) else encrypted_password
        key_bytes = encryption_key.encode('utf-8') if isinstance(encryption_key, str) else encryption_key
        if not key_bytes:
            raise ValueError("Encryption key cannot be empty")

        decrypted = AuthTool.XorCipher(encrypted_bytes, key_bytes)
        return decrypted.decode('utf-8')
    except Exception as e:
        logging.error(f"Error decrypting password: {str(e)}")
        return encrypted_password

def lambda_handler(event, context):
    try:
        "/api/users/username/{username}/password/{password}"

        client = boto3.client('rds-data')
        secret_arn = os.environ['SECRET_ARN']
        db_cluster_arn = os.environ['DB_CLUSTER_ARN']
        
        path_parameters = event.get("pathParameters", {})
        user_id = path_parameters.get("user_id")
        # Extract user data from the event body
        username = path_parameters.get("username")
        password = path_parameters.get("password")

        response = client.execute_statement(
            secretArn=secret_arn,
            database='AuroraDB',
            resourceArn=db_cluster_arn,
            sql=f"SELECT * FROM users WHERE username = '{username}'"
        )
        search_results = response.get("records", [])
        if not search_results:
            return response(404, {"error": "User not found"})

        encyptionKey = search_results[0][4]['stringValue']
        ecryptedPass = search_results[0][3]['stringValue']
        decrypted_password = decrypt_password(ecryptedPass, encyptionKey)

        if decrypted_password != password:
            return response(404, {"error": "Incorrect password"})
        # Here you would implement your password verification logic
        # Execute the SQL statement
        client = boto3.client('rds-data')
    except Exception as e:
        logging.error(f"Error updating user: {str(e)}")
        return response(500, {"error": str(e)})