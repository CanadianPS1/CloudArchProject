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
    message_id  = path_params.get("messageID", "")

    #both required fields
    if channel_id == "" or message_id == "":
        return response(400, {"message" : "channelId and messageID are both required items"})

    # Check channel exists
    existing = table.get_item(Key={"Id": channel_id})
    if "Item" not in existing:
        return response(404, {"message": f"Channel '{channel_id}' not found"})

    #make sure message exists and find its Index in the channel messages list
    messageIndex = -1
    #in case we go through the whole things and dont find it
    findValue = False

    holdChannel = existing.get["Item"]
    for message in holdChannel.messages:
        messageIndex += 1
        if message.ID == message_id:
            findValue = True
            break

    if not findValue:
        return response(404, {"message": f"Message '{message_id}' not found"})

    #update channel, removing the message from the channel
    response = table.update_item(
    Key={
        'ID': channel_id
    },
    UpdateExpression=f"REMOVE messages[{messageIndex}]",
    ReturnValues="UPDATED_NEW"
    )
    return response(200, {"message": "Message deleted", "Id": message_id, "response Attributes":response['Attributes']})