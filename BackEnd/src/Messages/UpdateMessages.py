import json
import boto3
from botocore.exceptions import ClientError
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

def get_body(event):
    body = event.get("body")
    return {} if body is None else json.loads(body)

def lambda_handler(event, context):
    try:
        logger.info("Starting Update Message Request")
        #ok, get message info
        body = get_body(event)
        newMessage  = body.get("message", "")
        channel_id  = body.get("channel_id", "")
        sort_key = body.get("sort_key","")

        #required fields
        if newMessage == "" or channel_id == "" or sort_key == "":
            return response(400, {"message" : "messageID, channelID, sortKey and NewMessage are required items"})
        logger.info("Input Validated, starting update protocol")

        try:
        #update message
            updateResponse = messageTable.update_item(
                        Key={
                            'ChannelID': channel_id,  # Your table's primary key
                            'SortKey' : sort_key
                        },
                        UpdateExpression=f"SET message = :new_vals",
                        ExpressionAttributeValues={
                            ":new_vals": newMessage
                        },
                        ReturnValues="UPDATED_NEW"
                    )

            logger.info("Update Complete")
            return response(200, {"message": "Message updated", "response Attributes":updateResponse['Attributes']})
        
        except ClientError as e:
            # Extract the error code from the response metadata
            error_code = e.response['Error']['Code']
            
            if error_code == 'ConditionalCheckFailedException':
                return response(404, {"message": f"Message '{message_id}' not found"})
            else:
                # Handle other potential DynamoDB errors (e.g., ProvisionedThroughputExceededException)
                logger.error(e.response)
                return response(404, {"message": "An unexpected error has occured"})

    except Exception as e:
            logging.error(f"Error updating message: {str(e)}")
            return response(500, {"error": str(e)})