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
        table.delete_item(Key={"Id" : channel_id})
        return response(200,{"Message" : "Channel deleted"})
    except Exception as e:
        logging.error(f"Error Updating Name : {str(e)}")
        return response(500,{"error" : str(e)})