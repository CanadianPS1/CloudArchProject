#DATA STRUCTURE FOR MESSAGES
#{
#“ChanelId” : string,
#“ChanelName” : string,
#“MessageId” : string,
#“UserId” : string, 
#“UserName” : “TestUser1”,
#“Timestamp” : string (“07/24/26, 23:54”), 
#“Message” : string (“I just sent a message!!!),
#}

import json
import logging
import os
import boto3
from datetime import datetime, timezone
from decimal import Decimal
from os import getenv
from uuid import uuid4
from botocore.awsrequest import AWSRequest

import logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)
#from gremlin_python.driver.driver_remote_connection import DriverRemoteConnection
#from gremlin_python.process.anonymous_traversal import traversal

channelTable = boto3.resource('dynamodb').Table(getenv('CHANNEL_TABLE_NAME', 'Channels'))
messageTable = boto3.resource('dynamodb').Table(getenv('MESSAGE_TABLE_NAME', 'Messages'))


def response(code, body):
    return {
        "statusCode": code,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps(body, default=_decimal_to_float)
    }

def _decimal_to_float(obj):
    """JSON serializer helper — DynamoDB returns Decimal for numbers."""
    if isinstance(obj, Decimal):
        return float(obj)
    raise TypeError(f"Object of type {type(obj)} is not JSON serializable")

def lambda_handler(event, context):
    try:

        logger.info("Starting Create Message Request")
        #get data from body
        body = json.loads(event.get("body", "{}"))
        channel_id = body.get("channel_id")
        user_id = body.get("user_id")
        message_content = body.get("message")

        #required fields
        if not channel_id or not user_id or not message_content:
            return response(400, {"error": "Missing required fields"})

        #make sure the channel exists
        existing = channelTable.get_item(Key={"Id": channel_id})
        if "Item" not in existing:
            return response(404, {"message": f"Channel '{channel_id}' not found"})

        logger.info("Input Validated, starting data creation")
        
        # Generate a unique message ID
        message_id = str(uuid4())

        # Get the current timestamp in UTC
        timestamp = datetime.now(timezone.utc).isoformat()

        #create message for insertion
        newMessage = {
            "ChannelID" : channel_id,
            "SortKey" : f"{timestamp}{message_id}",
            "messageID" : message_id,
            "userID" : user_id,
            "message" : message_content,
            "timestamp" : timestamp
        }

        logger.info("data creation complete, inserting into table")
        messageTable.put_item(Item = newMessage)
        #update the channel, appending the message
        # response = table.add_item(
        #     Key={
        #         'ID': channel_id  # Your table's primary key
        #     },
        #     UpdateExpression="SET messages = list_append(messages, :new_vals)",
        #     ExpressionAttributeValues={
        #         ":new_vals": newMessageList  # The list of values to append
        #     },
        #     ReturnValues="UPDATED_NEW"
        # )

        logger.info("Message Create Complete")
        return response(200, {"message": "Message created successfully", "message_id": message_id})

    except Exception as e:
        logging.error(f"Error creating message: {str(e)}")
        return response(500, {"error": str(e)})