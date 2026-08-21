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
        user_id = event.get("pathParameters",{}).get("user_id")
        body = json.loads(event.get("body","{}"))
        channel_id = body.get("channel_id")
        dynamodb = boto3.resource("dynamodb")
        table = dynamodb.Table("Channels")
        table.update_item(
            Key = {"Id" : channel_id},
            UpdateExpression = "SET people=list_append(if_not_exists(people,:empty),:user)",
            ExpressionAttributeValues = {
                ":empty" : [],
                ":user" : [user_id]
            }
        )
        return response(200,{"Message":"User Added to channel"})
    except Exception as e:
        logging.error(f"Error Updating Name : {str(e)}")
        return response(500,{"error" : str(e)})

