import json
import logging
import os
import psycopg2
from os import getenv
from datetime import datetime,timezone
from uuid import uuid4

logger = logging.getLogger()
logger.setLevel(logging.INFO)
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
        logger.info("Begin User Update")
        path_parameters = event.get("pathParameters",{})
        user_id = path_parameters.get("user_id")
        body = json.loads(event.get("body","{}"))
        username = body.get("username")
        email = body.get("email")
        password = body.get("password")
        logger.info("get data")
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
        logger.info("SQL created")
        connection = psycopg2.connect(
                            host = os.environ["DB_HOST"],
                            port = int(os.environ.get("DB_PORT","5432")),
                            database = os.environ.get("DB_NAME","my_database"),
                            user = getenv("DB_USER"), #secret_dict["username"],         # From Secrets Manager
                            password = getenv("DB_PASSWORD"),#secret_dict["password"], 
                            sslmode = "require"
                        )
        logger.info("data connected")
        cursor = connection.cursor()
        cursor.execute(sql)
        connection.commit()
        cursor.close()
        connection.close()
        logger.info("user updated")
        return response(200,{"message":"User updated successfully"})
    except Exception as e:
        logging.error(f"Error updating user: {str(e)}")
        return response(500,{"error":str(e)})