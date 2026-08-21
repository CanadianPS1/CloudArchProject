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
        return response(200,{"Message" : "name updated"})
    except Exception as e:
        logging.error(f"Error Updating Name : {str(e)}")
        return response(500,{"error" : str(e)})

