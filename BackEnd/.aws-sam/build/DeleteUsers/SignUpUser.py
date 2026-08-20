import json
import logging
import os
from datetime import datetime,timezone
from uuid import uuid4
import psycopg2
def response(code,body):
    return {
        "statusCode" : code,
        "headers" : {
            "Content-Type" : "application/json",
            "Access-Control-Allow-Origin" : "*"
        },
        "body" : json.dumps(body)
    }
def lambda_handler(event,context):
    try:
        body = json.loads(event.get("body","{}"))
        username = body.get("username")
        email = body.get("email")
        password = body.get("password")
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
                created_at TIMESTAMPTZ NOT NULL
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
            "SET UP AUTH FOR PASSWORD THINGS",
            "default_key",
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