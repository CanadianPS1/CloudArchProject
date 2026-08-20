import json


def handler(event, context):
    body = {
        "message": "Hello from AWS SAM",
        "path": event.get("path", "/hello"),
        "requestId": context.aws_request_id if context else None,
    }

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
        },
        "body": json.dumps(body),
    }
