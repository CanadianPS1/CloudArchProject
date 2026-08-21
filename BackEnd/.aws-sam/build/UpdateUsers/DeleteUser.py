import json
import logging
import os
import psycopg2
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
        if not user_id:
            return response(400,{"error":"Missing required field: user_id"})
        connection = psycopg2.connect(
            host = os.environ["DB_HOST"],
            port = os.environ.get("DB_PORT","5432"),
            database = os.environ["DB_NAME"],
            user = os.environ["DB_USER"],
            password = os.environ["DB_PASSWORD"]
        )
        cursor = connection.cursor()
        cursor.execute("DELETE FROM users WHERE user_id = %s",(user_id,))
        connection.commit()
        cursor.close()
        connection.close()
        return response(200,{"message":"User deleted successfully"})
    except Exception as e:
        logging.error(f"Error deleting user: {str(e)}")
        return response(500,{"error":str(e)})