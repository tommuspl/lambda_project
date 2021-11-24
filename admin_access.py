import boto3


client = boto3.client('iam')


def list_users_and_check_permissions(event, context):
    
    users = client.list_users()['Users']
    
    for user in users:
        policies = client.list_attached_user_policies(UserName=user['UserName'])
        for policy in policies['AttachedPolicies']:
            if 'PolicyName' in policy and policy['PolicyName'] == 'AdministratorAccess':
                client.detach_user_policy(UserName=user['UserName'],
                                          PolicyArn='arn:aws:iam::aws:policy/AdministratorAccess')
