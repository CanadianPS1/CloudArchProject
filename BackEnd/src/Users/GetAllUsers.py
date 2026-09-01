import json
import os
import psycopg2
from os import getenv

def response(status_code,body):
    return {
        "statusCode":status_code,
        "headers":{
            "Content-Type":"application/json",
            "Access-Control-Allow-Origin":"*",
        },
        "body":json.dumps(body,default=str),
    }
def lambda_handler(event,context):
    try:
        connection = psycopg2.connect(
                    host = os.environ["DB_HOST"],
                    port = int(os.environ.get("DB_PORT","5432")),
                    database = os.environ.get("DB_NAME","my_database"),
                    user = getenv("DB_USER"), #secret_dict["username"],         # From Secrets Manager
                    password = getenv("DB_PASSWORD"),#secret_dict["password"], 
                    sslmode = "require"
                )
        
        cursor = connection.cursor()
        cursor.execute("SELECT * FROM users")
        records = cursor.fetchall()
        columns = [description[0] for description in cursor.description]
        users = []
        for record in records:
            user = {columns[i]:record[i] for i in range(len(columns))}
            users.append(user)
        cursor.close()
        connection.close()
        return response(200,{"users":users})
    except Exception as e:
        return response(500,{"error":str(e)})