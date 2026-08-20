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
        path_parameters = event.get("pathParameters",{})
        user_id = path_parameters.get("user_id")
        body = json.loads(event.get("body","{}"))
        username = body.get("username")
        email = body.get("email")
        password = body.get("password")
        sql = """
            UPDATE users
            SET
        """
        if username:
            sql += f" username  =  '{username}'"
        elif email:
            sql += f" email  =  '{email}'"
        elif password:
            sql += f" encryptedPass  =  '{password}'"
        else:
            return response(400,{"error":"Missing required fields"})
        sql += f"""
            WHERE user_id  =  '{user_id}'
        """
        connection = psycopg2.connect(
            host = os.environ["DB_HOST"],
            port = os.environ.get("DB_PORT","5432"),
            database = os.environ["DB_NAME"],
            user = os.environ["DB_USER"],
            password = os.environ["DB_PASSWORD"]
        )
        cursor = connection.cursor()
        cursor.execute(sql)
        connection.commit()
        cursor.close()
        connection.close()
        return response(200,{"message":"User updated successfully"})
    except Exception as e:
        logging.error(f"Error updating user: {str(e)}")
        return response(500,{"error":str(e)})