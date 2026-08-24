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

def get_body(event):
    body = event.get("body")
    return {} if body is None else json.loads(body)

def lambda_handler(event, context):
    #get path params
    path_params = event.get("pathParameters") or {}
    channel_id  = path_params.get("channelID", "")
    message_id  = path_params.get("messageID", "")

    #required fields
    if channel_id == "" or message_id == "":
        return response(400, {"message" : "channelId and messageID are both required items"})

    # make sure channel exists
    existing = table.get_item(Key={"Id": channel_id})
    if "Item" not in existing:
        return response(404, {"message": f"Channel '{channel_id}' not found"})

    #ok, get message info
    body = get_body(event)
    newMessage  = body.get("message", "")

    #make sure message exists, and where index is
    messageIndex = -1
    findValue = False
    
    holdChannel = existing.get["Item"]
    for message in holdChannel.messages:
        messageIndex += 1
        if message.ID == message_id:
            findValue = True
            break

    if not findValue:
        return response(404, {"message": f"Message '{message_id}' not found"})

    #update channel, going into the list index and modifying its message
    response = table.update_item(
                Key={
                    'ID': channel_id  # Your table's primary key
                },
                UpdateExpression=f"SET messages[{messageIndex}].message = :new_vals)",
                ExpressionAttributeValues={
                    ":new_vals": newMessage  # The list of values to append
                },
                ReturnValues="UPDATED_NEW"
            )
    return response(200, {"message": "Message deleted", "Id": message_id, "response Attributes":response['Attributes']})