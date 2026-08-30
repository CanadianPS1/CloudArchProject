import json
import boto3
import os
import logging
sqs = boto3.client("sqs")
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
        body = json.loads(event.get("body","{}"))
        name = body.get("name")
        dynamodb = boto3.resource("dynamodb")
        table = dynamodb.Table("Channels")
        table.update_item(
            Key = {"Id" : channel_id},
            UpdateExpression = "SET #n=:name",
            ExpressionAttributeNames = {"#n" : "name"},
            ExpressionAttributeValues = {":name" : name}
        )
        sqs.send_message(
            QueueUrl=os.environ["NOTIFICATION_QUEUE_URL"],
            MessageBody=json.dumps({
                "message":"Channel Name Updated",
                "channel_id":channel_id
            })
        )
        return response(200,{"Message" : "name updated"})
    except Exception as e:
        logging.error(f"Error Updating Name : {str(e)}")
        return response(500,{"error" : str(e)})

