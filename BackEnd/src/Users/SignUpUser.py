import json
import logging
import os
from datetime import datetime,timezone
from uuid import uuid4
import psycopg2
import boto3
import base64
import cryptography
from decimal import Decimal
from os import getenv
import AuthTool

def response(code, body):
    return {
        "statusCode" : code,
        "headers" : {
            "Content-Type" : "application/json",
            "Access-Control-Allow-Origin" : "*"
        },
        "body" : json.dumps(body)
    }

def _decimal_to_float(obj):
    """JSON serializer helper — DynamoDB returns Decimal for numbers."""
    if isinstance(obj, Decimal):
        return float(obj)
    raise TypeError(f"Object of type {type(obj)} is not JSON serializable")

def password_encryption(password, encryption_key):
    # Placeholder for password encryption logic
    # You can implement your own encryption method here
    try:
        password_bytes = password.encode('utf-8')
        password_base64 = base64.b64encode(password_bytes)
        print(f"test print: {password_base64}")
        print("Password test" + password)

        key_bytes = encryption_key.encode('utf-8')
        key_base64 = base64.b64encode(key_bytes)
        encrypted_password = AuthTool.XorCipher(password_base64, key_base64)
        pass
    except Exception as e:
        logging.error(f"Error encrypting password: {str(e)}")
    return encrypted_password

def lambda_handler(event, context):
    try:
        body = json.loads(event.get("body","{}"))
        print("test print")
        
        # String to encode
        my_string = "Hello from PythonGuides!"

        # Convert string to bytes
        string_bytes = my_string.encode('utf-8')

        # Encode bytes to base64
        base64_bytes = base64.b64encode(string_bytes)

        # Convert base64 bytes to string for display
        base64_string = base64_bytes.decode('utf-8')

        #print(f"Original string: {my_string}")
        #print(f"Base64 encoded: {base64_string}")
        username = body.get("username")
        email = body.get("email")
        password = body.get("password")
        encryption_key = AuthTool.KeyGenerator(32)  # Generate a random encryption key
        encrypted_password = password_encryption(str(password), encryption_key)  # Encrypt the password using the generated key
        if not username or not email or not password:
            return response(400,{"error":"Missing required fields"})
        
        user_id = str(uuid4())
        
        created_at = datetime.now(timezone.utc)
        connection = psycopg2.connect(
            host = os.environ["DB_HOST"],
            port = int(os.environ.get("DB_PORT","5432")),
            database = os.environ.get("DB_NAME","my_database"),
            user = os.environ["DB_USER"],
            password = os.environ["DB_PASSWORD"]
        )

        print("Encryption Key: " + encryption_key)

        cursor = connection.cursor()
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS users(
                user_id VARCHAR(36) PRIMARY KEY,
                username VARCHAR(255) NOT NULL,
                email VARCHAR(255) NOT NULL,
                encryptedPass VARCHAR(255) NOT NULL,
                encryptionKey VARCHAR(255) NOT NULL,
                bio VARCHAR(500),
                status VARCHAR(50) NOT NULL,
                created_at TIMESTAMP NOT NULL
            )
        """)
        cursor.execute("""
            INSERT INTO users(
                user_id,
                username,
                email,
                encryptedPass,
                encryptionKey,
                created_at,
                status
            )
            VALUES(%s,%s,%s,%s,%s,%s,%s)
        """,(
            user_id,
            username,
            email,
            encrypted_password,
            encryption_key,
            created_at,
            "active"
        ))
        connection.commit()
        cursor.close()
        connection.close()
        
        return response(201,{
            "message" : "User created successfully",
            "user_id" : user_id
        })
    except Exception as e:
        logging.error(f"Error creating user : {str(e)}")
        return response(500,{"error" : str(e)})