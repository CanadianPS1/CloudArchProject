import json
import boto3
from os import getenv

import logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

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

def lambda_handler(event, context):
    try:
        logger.info("Starting Delete Message Request")
        #get data from path params (channel and message IDs)
        path_params = event.get("pathParameters") or {}
        channel_id  = path_params.get("channel_id", "")
        sort_key = path_params.get("sort_key", "")

        #both required fields
        if channel_id == "" or sort_key == "":
            return response(400, {"message" : "channel_id and sort_key are required items"})

        # Check message exists
        existing = messageTable.get_item(Key={"ChannelID": channel_id, "SortKey" : sort_key})
        if "Item" not in existing:
            return response(404, {"message": "Message not found"})

        logger.info("Request data validated, removing message")
        #update channel, removing the message from the channel
        deleteDetails = messageTable.delete_item(Key={"ChannelID": channel_id, "SortKey" : sort_key})

        logger.info("Message delete completed")
        return response(200, {"message": "Message deleted"}) #, "response Attributes":deleteDetails['Attributes']

    except Exception as e:
            logging.error(f"Error deleting message: {str(e)}")
            return response(500, {"error": str(e)})