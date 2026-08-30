import json
import boto3
import logging
import os
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
        dynamodb = boto3.resource("dynamodb")
        table = dynamodb.Table("Channels")
        dbresponse = table.scan(
            FilterExpression = "contains(people,:user_id)",
            ExpressionAttributeValues = {":user_id" : user_id},
            ProjectionExpression = "Id,#n,people",
            ExpressionAttributeNames = {"#n" : "name"}
        )
        channels = [
            {
                "id" : channel["Id"],
                "name" : channel["name"],
                "people" : len(channel.get("people",[]))
            }
            for channel in dbresponse.get("Items",[])
        ]
        return response(200,{"channels" : channels})
    except Exception as e:
        logging.error(f"Error Getting Channels : {str(e)}")
        return response(500,{"error" : str(e)})

