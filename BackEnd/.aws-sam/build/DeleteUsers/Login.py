import json
import logging
import os
import psycopg2
from datetime import datetime,timezone
from uuid import uuid4
import boto3
import base64
import cryptography
from decimal import Decimal
from os import getenv
import AuthTool
def response(code, body):
    return {
        "statusCode":code,
        "headers":{
            "Content-Type":"application/json",
            "Access-Control-Allow-Origin":"*"
        },
        "body":json.dumps(body)
    }
def _decimal_to_float(obj):
    """JSON serializer helper — DynamoDB returns Decimal for numbers."""
    if isinstance(obj, Decimal):
        return float(obj)
    raise TypeError(f"Object of type {type(obj)} is not JSON serializable")
def decrypt_password(encrypted_password, encryption_key):
    try:
        encrypted_bytes = encrypted_password.decode('utf-8')
        key_bytes = encryption_key.decode('utf-8')
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
        # path_parameters = event.get("pathParameters",{})
        # user_id = path_parameters.get("user_id")
        body=json.loads(event.get("body","{}"))
        username=body.get("username")
        password=body.get("password")
        connection = psycopg2.connect(
                            host = os.environ["DB_HOST"],
                            port = int(os.environ.get("DB_PORT","5432")),
                            database = os.environ.get("DB_NAME","my_database"),
                            user = getenv("DB_USER"), #secret_dict["username"],         # From Secrets Manager
                            password = getenv("DB_PASSWORD"),#secret_dict["password"], 
                            sslmode = "require"
                        )
        cursor = connection.cursor()
        cursor.execute(
            "SELECT * FROM users WHERE username  =  %s",
            (username,)
        )
        search_results = cursor.fetchall()
        if not search_results:
            return response(404, {"error": "User not found"})

        encyptionKey = search_results[0][4]
        ecryptedPass = search_results[0][3]
        decrypted_password = decrypt_password(ecryptedPass, encyptionKey)

        if decrypted_password != password:
            return response(404, {"error": "Incorrect password"})
        # Here you would implement your password verification logic
        cursor.close()
        connection.close()
        return response(200,{"message":"Login successful","user_id":search_results[0][0]})
    except Exception as e:
        logging.error(f"Error updating user: {str(e)}")
        return response(500,{"error":str(e)})