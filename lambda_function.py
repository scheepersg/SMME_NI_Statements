import json
import boto3
import os

sns_client = boto3.client('sns')

def lambda_handler(event, context):
    sns_topic_arn = os.environ['SNS_TOPIC_ARN']
    
    message = {
        'event': event
    }
    
    sns_client.publish(
        TopicArn=sns_topic_arn,
        Message=json.dumps({'default': json.dumps(message)}),
        MessageStructure='json'
    )
    
    return {
        'statusCode': 200,
        'body': json.dumps('SNS notification sent successfully!')
    }
