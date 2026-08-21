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
        channel = table.get_item(
            Key = {"Id":channel_id},
            ProjectionExpression = "people"
        ).get("Item")
        if not channel:
            return response(404,{"error" : "Channel not found"})
        people = channel.get("people",[])
        if user_id not in people:
            return response(404,{"error" : "User is not in channel"})
        index = people.index(user_id)
        table.update_item(
            Key = {"Id":channel_id},
            UpdateExpression = f"REMOVE people[{index}]"
        )
        return response(200,{"Message":"User removed from channel"})
    except Exception as e:
        logging.error(f"Error Updating Name : {str(e)}")
        return response(500,{"error" : str(e)})

