import json
import logging
import os
import psycopg2
from datetime import datetime,timezone
from uuid import uuid4
def response(code,body):
    return {
        "statusCode":code,
        "headers":{
            "Content-Type":"application/json",
            "Access-Control-Allow-Origin":"*"
        },
        "body":json.dumps(body)
    }
def lambda_handler(event,context):
    try:
        "/api/users/username/{username}/password/{password}"
        path_parameters = event.get("pathParameters",{})
        user_id = path_parameters.get("user_id")
        body=json.loads(event.get("body","{}"))
        username=body.get("username")
        password=body.get("password")
        connection = psycopg2.connect(
            host = os.environ["DB_HOST"],
            port = os.environ.get("DB_PORT","5432"),
            database = os.environ["DB_NAME"],
            user = os.environ["DB_USER"],
            password = os.environ["DB_PASSWORD"]
        )
        cursor = connection.cursor()
        cursor.execute(
            "SELECT * FROM users WHERE username  =  %s",
            (username,)
        )
        search_results = cursor.fetchall()
        if not search_results:
            cursor.close()
            connection.close()
            return response(404,{"error":"User not found"})
        encryptionKey = search_results[0][4]
        encryptedPass = search_results[0][3]
        # Here you would implement your password verification logic
        cursor.close()
        connection.close()
        return response(200,{"message":"Login successful","user_id":search_results[0][0]})
    except Exception as e:
        logging.error(f"Error updating user: {str(e)}")
        return response(500,{"error":str(e)})