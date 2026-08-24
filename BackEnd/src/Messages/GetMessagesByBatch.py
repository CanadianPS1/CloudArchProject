# GETS only the last 100 messages from the database, ordered by timestamp in descending order.
import json
import boto3
from os import getenv

table = boto3.resource('dynamodb').Table(getenv('TABLE_NAME', 'Channels'))
def response(code,body):
    return {
        "statusCode" : code,
        "headers": {
            "Content-Type" : "application/json",
            "Access-Control-Allow-Origin" : "*"
        },
        "body" : json.dumps(body)
    }

def lambda_handler(event, context):
    #get data from path params (channel and message IDs)
    path_params = event.get("pathParameters") or {}
    channel_id  = path_params.get("channelID", "")
    message_batch_id  = path_params.get("messageID", "")

    #both required fields
    if channel_id == "" or message_batch_id == "":
        return response(400, {"message" : "channelId and messageID are both required items"})

    # Check channel exists
    existing = table.get_item(Key={"Id": channel_id})
    if "Item" not in existing:
        return response(404, {"message": f"Channel '{channel_id}' not found"})