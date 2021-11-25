import boto3


client = boto3.client('iam')


def list_users_and_check_permissions(event, context):
    counter = 0
    users = client.list_users()['Users']
    
    if users is None:
        return "No users found"
    else:
        for user in users:
            print(f"User name: {user['UserName']} \n Policy: ")
            policies = client.list_attached_user_policies(UserName=user['UserName'])
            for policy in policies['AttachedPolicies']:
                print(f"- {policy['PolicyName']:>5}")
                if policy['PolicyName'] == 'AdministratorAccess':
                    client.detach_user_policy(
                        UserName=user['UserName'],
                        PolicyArn='arn:aws:iam::aws:policy/AdministratorAccess'
                        )
                    counter +=1
        return f"Detached {counter} policies"
