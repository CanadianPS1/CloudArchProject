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
        statusOptions = {
            "active": "active",
            "inactive": "inactive",
            "pending": "pending"
        }
        # Extract user data from the event body
        body = json.loads(event.get("body", "{}"))
        username = body.get("username")
        email = body.get("email")
        password = body.get("password")


        if not username or not email or not password:
            return response(400, {"error": "Missing required fields"})

        # Generate a unique user ID
        user_id = str(uuid4())

        # Get the current timestamp in UTC
        created_at = datetime.now(timezone.utc).isoformat()

        # Prepare the SQL statement to insert a new user
        sql = f"""
            IF EXISTS (
                SELECT 1
                FROM INFORMATION_SCHEMA.TABLES
                WHERE TABLE_SCHEMA = 'dbo'
                AND TABLE_NAME = 'users'
            )
            BEGIN
                INSERT INTO users (user_id, username, email, encryptedPass, encryptionKey, created_at, status)
                VALUES ('{user_id}', '{username}', '{email}', 'SET UP AUTH FOR PASSWORD THINGS', 'default_key', '{created_at}', '{statusOptions["active"]}');
            END 
            ELSE
            BEGIN
                CREATE TABLE users (
                    user_id VARCHAR(36) PRIMARY KEY,
                    username VARCHAR(255) NOT NULL,
                    email VARCHAR(255) NOT NULL,
                    encryptedPass VARCHAR(255) NOT NULL,
                    encryptionKey VARCHAR(255) NOT NULL,
                    bio VARCHAR(500),
                    status VARCHAR(50) NOT NULL,
                    created_at DATETIME NOT NULL
                );

                INSERT INTO users (user_id, username, email, encryptedPass, encryptionKey, created_at, status)
                VALUES ('{user_id}', '{username}', '{email}', 'SET UP AUTH FOR PASSWORD THINGS', 'default_key', '{created_at}', '{statusOptions["active"]}');
            END
        """

        # Execute the SQL statement using RDS Data Service
        client = boto3.client('rds-data')
        secret_arn = os.environ['SECRET_ARN']
        db_cluster_arn = os.environ['DB_CLUSTER_ARN']

        client.execute_statement(
            secretArn=secret_arn,
            database='AuroraDB',
            resourceArn=db_cluster_arn,
            sql=sql
        )

        return response(201, {"message": "User created successfully", "user_id": user_id})

    except Exception as e:
        logging.error(f"Error creating user: {str(e)}")
        return response(500, {"error": str(e)})