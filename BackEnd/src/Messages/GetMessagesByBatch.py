# GETS only the last 100 messages from the database, ordered by timestamp in descending order.
import json
import boto3
from os import getenv

from boto3.dynamodb.conditions import Key

import logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

channelTable = boto3.resource('dynamodb').Table(getenv('CHANNEL_TABLE_NAME', 'Channels'))
messageTable = boto3.resource('dynamodb').Table(getenv('MESSAGE_TABLE_NAME', 'Messages'))
def response(code,body):
    return {
        "statusCode" : code,
        "headers": {
            "Content-Type" : "application/json",
            "Access-Control-Allow-Origin" : "*"
        },
        "body" : json.dumps(body)
    }

def stringIsInt(value):
    try:
        int(value)
        return True
    except (ValueError, TypeError):
        return False

def lambda_handler(event, context):
    try: 
        logger.info("Starting Message Retrieval Request")
        #get data from path params (channel and message IDs)
        path_params = event.get("pathParameters") or {}
        channel_id  = path_params.get("channel_id", "")
        message_batch_id  = path_params.get("message_batch_number", "")

        #both required fields
        if channel_id == "" or message_batch_id == "":
            return response(400, {"message" : "channelId and messageBatchID are both required items"})

        if not stringIsInt(message_batch_id):
            return response(400, {"message" : "Message_batch_Id should be an integer"})

        # Check channel exists
        existing = channelTable.get_item(Key={"Id": channel_id})
        if "Item" not in existing:
            return response(404, {"message": f"Channel '{channel_id}' not found"})

        logger.info("Request data validated, starting data read")
        messageData = ""

        for index in range(int(message_batch_id)):
            if index > 0:
                if messageData.get("LastEvaluatedKey", None) is None:
                    break
            params = {
                "KeyConditionExpression": Key("ChannelID").eq(channel_id),#"ChannelId = :channel_id",
                # "ExpressionAttributeValues": {
                #     ":channel_id": channel_id,
                # },
                "ScanIndexForward": False,  # newest first
                "Limit": 50,
            }
            if index > 0:
                params["ExclusiveStartKey"] = messageData.get("LastEvaluatedKey")

            messageData = messageTable.query(**params)

        logger.info("Message read completed")
        return response(200, {"messages" : messageData, "isLast" : True if messageData.get("LastEvaluatedKey") is None else False})

    except Exception as e:
            logging.error(f"Error reading messages: {str(e)}")
            return response(500, {"error": str(e)})