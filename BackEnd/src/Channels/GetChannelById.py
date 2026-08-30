import json
import boto3
import logging
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
        channel_id = event.get("pathParameters",{}).get("channel_id")
        dynamodb = boto3.resource("dynamodb")
        table = dynamodb.Table("Channels")
        dbresponse = table.get_item(Key = {"Id" : channel_id})
        item = dbresponse.get("Item")
        if not item:
            return response(404,{"error" : "Channel not found"})
        return response(200,item)
    except Exception as e:
        logging.error(f"Error creating user : {str(e)}")
        return response(500,{"error" : str(e)})