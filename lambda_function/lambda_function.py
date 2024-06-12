import json
import boto3

def lambda_handler(event, context):
    # Initialize the SNS client
    sns_client = boto3.client('sns')
    
    # Extract the bucket name and object key from the event
    bucket_name = event['Records'][0]['s3']['bucket']['name']
    object_key = event['Records'][0]['s3']['object']['key']
    
    # Create the SNS message
    message = f"File {object_key} has been uploaded to {bucket_name}."
    
    # Send the SNS notification
    response = sns_client.publish(
        TopicArn='arn:aws:sns:REGION:ACCOUNT_ID:TOPIC_NAME',
        Message=message,
        Subject='S3 Upload Notification'
    )
    
    # Log the response
    print(response)
    
    return {
        'statusCode': 200,
        'body': json.dumps('SNS notification sent successfully!')
    }

