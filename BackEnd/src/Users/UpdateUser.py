import json
import logging
import os
import psycopg2
import boto3
import base64
import AuthTool

from datetime import datetime,timezone
from uuid import uuid4
sqs = boto3.client("sqs")
def response(code,body):
    return {
        "statusCode":code,
        "headers":{
            "Content-Type":"application/json",
            "Access-Control-Allow-Origin":"*"
        },
        "body":json.dumps(body)
    }

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

def lambda_handler(event,context):
    try:
        path_parameters = event.get("pathParameters",{})
        user_id = path_parameters.get("user_id")
        body = json.loads(event.get("body","{}"))
        username = body.get("username")
        email = body.get("email")
        password = body.get("password")

        encryption_key = AuthTool.KeyGenerator(32)  # Generate a random encryption key
        encrypted_password = password_encryption(str(password), encryption_key)
        
        sql = """
            UPDATE users
            SET
        """
        if username:
            sql += f" username  =  '{username}'"
        elif email:
            sql += f" email  =  '{email}'"
        elif password:
            sql += f" encryptedPass  =  '{encrypted_password}'"
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
        sqs.send_message(
            QueueUrl=os.environ["NOTIFICATION_QUEUE_URL"],
            MessageBody=json.dumps({
                "message":"User Updated",
                "user_id":user_id
            })
        )
        return response(200,{"message":"User updated successfully"})
    except Exception as e:
        logging.error(f"Error updating user: {str(e)}")
        return response(500,{"error":str(e)})