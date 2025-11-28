import json
import boto3
from aws_xray_sdk.core import xray_recorder
from aws_xray_sdk.core import patch_all

# Patch Boto3 to instrument AWS SDK for X-Ray
patch_all(['boto3'])

# Create a DynamoDB client and instrument it with X-Ray
dynamodb = boto3.client('dynamodb')
dynamodb = xray_recorder.capture_aws(dynamodb)

def lambda_handler(event, context):
    try:
        response = dynamodb.get_item(
            TableName='DynamoLists-meh2szflhvearkr3spbtrkmjim-listdev',
            Key={
                'KeyAttribute': {'S': 'id'}
            }
        )
        item = response.get('Item')
        if item:
           
            return {
                'statusCode': 200,
                'body': json.dumps(item)
            }
        else:
            return {
                'statusCode': 404,
                'body': "Item not found"
            }
    except Exception as e:
        
        return {
            'statusCode': 500,
            'body': str(e)
        }

   
