import base64
import os
from xxlimited import new
import cryptography
import json

#from numpy import var

def lamda_handler(event, context):
    try:
        # Extract the Authorization header from the event
        auth_header = event.get("headers", {}).get("Authorization")
        if not auth_header:
            return {
                "statusCode": 401,
                "body": json.dumps({"error": "Missing Authorization header"})
            }

        user_body = json.loads(event.get("body", "{}"))
        username = user_body.get("username")

        return {
            "statusCode": 200,
            "body": json.dumps({"message": f"Authenticated user: {username}"})
        }
    except Exception as e:
        return {}

def XorCipher(data, key):
    result = bytearray(len(data))
    for i in range(len(data)):
        result[i] = data[i] ^ key[i % len(key)]
    return result

def KeyGenerator(key_length):
    return base64.urlsafe_b64encode(os.urandom(key_length)).decode('utf-8')