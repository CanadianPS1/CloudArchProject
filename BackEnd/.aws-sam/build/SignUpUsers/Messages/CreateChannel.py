import json
import boto3
import logging
from datetime import datetime,timezone
from uuid import uuid4
def response(code, body):
    return {
        "statusCode" : code,
        "headers" : {
            "Content-Type" : "application/json",
            "Access-Control-Allow-Origin" : "*"
        },
        "body" : json.dumps(body)
    }
def lambda_handler(event, context):
    try:
        body = json.loads(event.get("body","{}"))
        name = body.get("name")
        people = body.get("people")
        admin = body.get("admin")
        dynamodb = boto3.resource("dynamodb")
        table = dynamodb.Table("Channels")
        item = {
            "Id" : str(uuid4()),
            "name" : name,
            "people" : people,
            "admin" : admin,
            "messages":[
                {
                    "createDate":datetime.now(timezone.utc).isoformat(),
                    "id":str(uuid4()),
                    "message":"Welcome to the chat!!!",
                    "posterId": "0001",
                    "posterName":"System"
                }
            ]
        }
        table.put_item(Item = item)
        return response(200,{"Message":"Success, Channel Created"})
    except Exception as e:
        logging.error(f"Error creating user : {str(e)}")
        return response(500,{"error" : str(e)})

