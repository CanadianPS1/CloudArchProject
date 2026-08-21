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
        dynamodb = boto3.resource("dynamodb")
        table = dynamodb.Table("Channels")
        dbresponse = table.scan(ProjectionExpression = "Id")
        ids = [item["Id"] for item in dbresponse.get("Items",[])]
        return response(200,{"ids" : ids})
    except Exception as e:
        logging.error(f"Error Getting Channels : {str(e)}")
        return response(500,{"error" : str(e)})

