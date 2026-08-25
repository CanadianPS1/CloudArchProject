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
from gremlin_python.driver.driver_remote_connection import DriverRemoteConnection
from gremlin_python.process.anonymous_traversal import traversal

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
        # Extract message data from the event body
        body = json.loads(event.get("body", "{}"))
        channel_id = body.get("channel_id")
        channel_name = body.get("channel_name")
        user_id = body.get("user_id")
        user_name = body.get("user_name")
        message_content = body.get("message")

        if not channel_id or not channel_name or not user_id or not user_name or not message_content:
            return response(400, {"error": "Missing required fields"})

        # Generate a unique message ID
        message_id = str(uuid4())

        # Get the current timestamp in UTC
        timestamp = datetime.now(timezone.utc).isoformat()

        return response(200, {"message": "Message created successfully", "message_id": message_id})

    except Exception as e:
        logging.error(f"Error creating message: {str(e)}")
        return response(500, {"error": str(e)})