# AWS IAM Identity Center CloudFormation Templates

This folder contains CloudFormation templates for managing AWS IAM Identity Center (formerly AWS SSO) resources including Permission Sets, Groups, and Users.

---

## Prerequisites

Before deploying these templates, ensure you have:

1. **AWS IAM Identity Center enabled** in your AWS Organization
2. **AWS CLI configured** with appropriate credentials
3. **Required information:**
   - **Instance ARN**: Found in IAM Identity Center → Settings → Identity source (format: `arn:aws:sso:::instance/ssoins-xxxxxxxxxxxxxxxx`)
   - **Identity Store ID**: Found in IAM Identity Center → Settings (format: `d-xxxxxxxxxx`)

---

## Templates Overview

| Template | Purpose | Dependencies |
|----------|---------|--------------|
| `AddIDCPermissionSets.yml` | Creates Permission Sets | None |
| `AddUserGroups.yml` | Creates Identity Center Groups | None |
| `AddingUsersAssignments.yml` | Creates Users and assigns to Groups | Groups must exist |

---

## 1. AddIDCPermissionSets.yml

### Description

This template creates **six standard Permission Sets** in IAM Identity Center. Permission Sets define the level of access users and groups have when they access AWS accounts.

### Permission Sets Created

| Permission Set | AWS Managed Policy | Description |
|----------------|-------------------|-------------|
| **AdministratorAccess** | `AdministratorAccess` | Full access to all AWS services and resources |
| **PowerUserAccess** | `PowerUserAccess` | Full access except IAM and Organizations management |
| **SystemAdministrator** | `job-function/SystemAdministrator` | Systems management and administration tasks |
| **SecurityAudit** | `SecurityAudit` | Security auditing and compliance review access |
| **ReadOnlyAccess** | `ReadOnlyAccess` | Read-only access to all AWS services |
| **ViewOnlyAccess** | `job-function/ViewOnlyAccess` | More restricted view-only access |

### Parameters

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `InstanceArn` | String | ARN of the IAM Identity Center instance | Required |
| `SessionDurationHours` | Number | Session duration (1-12 hours) | 8 |

### Deployment Command

```bash
aws cloudformation create-stack \
  --stack-name idc-permission-sets \
  --template-body file://AddIDCPermissionSets.yml \
  --parameters \
    ParameterKey=InstanceArn,ParameterValue=arn:aws:sso:::instance/ssoins-xxxxxxxxxxxxxxxx \
    ParameterKey=SessionDurationHours,ParameterValue=8
```

### Outputs

The template exports ARNs for all Permission Sets, which can be used in other stacks for account assignments:
- `{StackName}-AdministratorAccessPermissionSetArn`
- `{StackName}-PowerUserAccessPermissionSetArn`
- `{StackName}-SystemAdministratorPermissionSetArn`
- `{StackName}-SecurityAuditPermissionSetArn`
- `{StackName}-ReadOnlyAccessPermissionSetArn`
- `{StackName}-ViewOnlyAccessPermissionSetArn`

---

## 2. AddUserGroups.yml

### Description

This template creates **Identity Center Groups** that can be used to organize users and assign permissions collectively.

### Groups Created

| Group Name | Description |
|------------|-------------|
| **InfraAdmin** | Infrastructure administrators with full AWS access |
| **InfraReadOnly** | Infrastructure read-only access |

### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `IdentityStoreId` | String | The ID of the Identity Store (format: `d-xxxxxxxxxx`) |

### Deployment Command

```bash
aws cloudformation create-stack \
  --stack-name idc-user-groups \
  --template-body file://AddUserGroups.yml \
  --parameters \
    ParameterKey=IdentityStoreId,ParameterValue=d-xxxxxxxxxx
```

### Outputs

The template exports Group IDs for use in user assignments:
- `{StackName}-InfraAdminGroupId`
- `{StackName}-InfraReadOnlyGroupId`

---

## 3. AddingUsersAssignments.yml

### Description

This template creates **IAM Identity Center Users** and assigns them to groups using a **Lambda-backed Custom Resource**. This approach is necessary because CloudFormation doesn't natively support `AWS::IdentityStore::User` resources.

### How It Works

1. **Lambda Function**: Creates a Python Lambda function that interacts with the Identity Store API
2. **IAM Role**: Grants the Lambda function permissions to manage users and group memberships
3. **Custom Resources**: Uses CloudFormation Custom Resources to trigger the Lambda for user creation

### Resources Created

- **IAM Role** (`IdentityStoreLambdaRole`): Permissions for Lambda to manage Identity Store
- **Lambda Function** (`IdentityStoreUserFunction`): Handles Create, Update, and Delete operations
- **User 1** (`User1`): First user with group assignment
- **User 2** (`User2`): Second user with group assignment

### Lambda Function Capabilities

| Operation | Actions Performed |
|-----------|-------------------|
| **Create** | Creates user in Identity Store, adds to specified group |
| **Update** | Returns success (no modifications) |
| **Delete** | Removes group membership, deletes user |

### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `IdentityStoreId` | String | Identity Store ID (format: `d-xxxxxxxxxx`) |
| `User1UserName` | String | Username for User 1 |
| `User1FirstName` | String | First name for User 1 |
| `User1LastName` | String | Last name for User 1 |
| `User1Email` | String | Email for User 1 |
| `User1GroupId` | String | Group ID to assign User 1 |
| `User2UserName` | String | Username for User 2 |
| `User2FirstName` | String | First name for User 2 |
| `User2LastName` | String | Last name for User 2 |
| `User2Email` | String | Email for User 2 |
| `User2GroupId` | String | Group ID to assign User 2 |

### Deployment Command

```bash
aws cloudformation create-stack \
  --stack-name idc-users \
  --template-body file://AddingUsersAssignments.yml \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameters \
    ParameterKey=IdentityStoreId,ParameterValue=d-xxxxxxxxxx \
    ParameterKey=User1UserName,ParameterValue=jdoe \
    ParameterKey=User1FirstName,ParameterValue=John \
    ParameterKey=User1LastName,ParameterValue=Doe \
    ParameterKey=User1Email,ParameterValue=jdoe@example.com \
    ParameterKey=User1GroupId,ParameterValue=<InfraAdminGroupId> \
    ParameterKey=User2UserName,ParameterValue=jsmith \
    ParameterKey=User2FirstName,ParameterValue=Jane \
    ParameterKey=User2LastName,ParameterValue=Smith \
    ParameterKey=User2Email,ParameterValue=jsmith@example.com \
    ParameterKey=User2GroupId,ParameterValue=<InfraReadOnlyGroupId>
```

> **Note**: `--capabilities CAPABILITY_NAMED_IAM` is required because this template creates an IAM role.

### Outputs

- `User1Id`: The Identity Store User ID for User 1
- `User2Id`: The Identity Store User ID for User 2

---

## Deployment Architecture & Flow

This section provides a comprehensive view of the deployment process, showing how CloudFormation templates create AWS resources and their relationships.

### Complete Deployment Architecture

```mermaid
graph TB
    Start([Start Deployment]) --> PreReq{Prerequisites Met?}
    PreReq -->|No| PreReqCheck[Check Prerequisites:<br/>- IAM Identity Center enabled<br/>- Instance ARN obtained<br/>- Identity Store ID obtained<br/>- AWS CLI configured]
    PreReqCheck --> PreReq
    PreReq -->|Yes| Template1[Template 1: AddIDCPermissionSets.yml]

    Template1 --> PS[CloudFormation Stack:<br/>idc-permission-sets]
    PS --> PSResources[Creates 6 Permission Sets]

    PSResources --> PS1[AdministratorAccess<br/>AWS Managed Policy]
    PSResources --> PS2[PowerUserAccess<br/>AWS Managed Policy]
    PSResources --> PS3[SystemAdministrator<br/>Job Function Policy]
    PSResources --> PS4[SecurityAudit<br/>AWS Managed Policy]
    PSResources --> PS5[ReadOnlyAccess<br/>AWS Managed Policy]
    PSResources --> PS6[ViewOnlyAccess<br/>Job Function Policy]

    PS1 --> PSExport[Stack Outputs:<br/>Permission Set ARNs<br/>exported for cross-stack reference]
    PS2 --> PSExport
    PS3 --> PSExport
    PS4 --> PSExport
    PS5 --> PSExport
    PS6 --> PSExport

    PSExport --> Wait1[Wait for Stack Complete]

    Wait1 --> Template2[Template 2: AddUserGroups.yml]

    Template2 --> Groups[CloudFormation Stack:<br/>idc-user-groups]
    Groups --> GroupResources[Creates Identity Store Groups]

    GroupResources --> G1[InfraAdmin Group<br/>For full admin access]
    GroupResources --> G2[InfraReadOnly Group<br/>For read-only access]

    G1 --> GExport[Stack Outputs:<br/>Group IDs exported]
    G2 --> GExport

    GExport --> Wait2[Wait for Stack Complete]

    Wait2 --> Template3[Template 3: AddingUsersAssignments.yml]

    Template3 --> UserStack[CloudFormation Stack:<br/>idc-users]

    UserStack --> IAMRole[IAM Role:<br/>IdentityStoreLambdaRole]
    IAMRole --> IAMPolicies[Permissions:<br/>- identitystore:CreateUser<br/>- identitystore:DeleteUser<br/>- identitystore:CreateGroupMembership<br/>- identitystore:DeleteGroupMembership<br/>- logs:CreateLogGroup/Stream/Events]

    UserStack --> Lambda[Lambda Function:<br/>IdentityStoreUserFunction]
    Lambda --> LambdaDetails[Python 3.11 Runtime<br/>120s timeout<br/>Handles Create/Update/Delete]

    UserStack --> CustomResource1[Custom Resource:<br/>User1]
    UserStack --> CustomResource2[Custom Resource:<br/>User2]

    CustomResource1 --> LambdaTrigger1[Triggers Lambda<br/>CREATE event]
    CustomResource2 --> LambdaTrigger2[Triggers Lambda<br/>CREATE event]

    LambdaTrigger1 --> LambdaAction1[Lambda Actions:<br/>1. Create user in Identity Store<br/>2. Add user to specified group]
    LambdaTrigger2 --> LambdaAction2[Lambda Actions:<br/>1. Create user in Identity Store<br/>2. Add user to specified group]

    LambdaAction1 --> IDCUser1[Identity Center User 1<br/>Assigned to Group]
    LambdaAction2 --> IDCUser2[Identity Center User 2<br/>Assigned to Group]

    IDCUser1 --> UserOutputs[Stack Outputs:<br/>User IDs]
    IDCUser2 --> UserOutputs

    UserOutputs --> Complete[Deployment Complete]

    Complete --> NextSteps{Next Steps}
    NextSteps --> Manual1[Manual: Create Account Assignments<br/>Link Groups to AWS Accounts + Permission Sets]
    NextSteps --> Manual2[Manual: Users set passwords<br/>via Identity Center portal]
    NextSteps --> Optional[Optional: Configure Entra ID<br/>for SSO & Auto-Provisioning]

    style Start fill:#90EE90
    style Complete fill:#90EE90
    style Template1 fill:#2E86AB,color:#fff
    style Template2 fill:#A23B72,color:#fff
    style Template3 fill:#F18F01,color:#fff
    style PS fill:#87CEEB
    style Groups fill:#DDA0DD
    style UserStack fill:#FFB347
    style Lambda fill:#FF6B6B
    style IAMRole fill:#4ECDC4
    style IDCUser1 fill:#95E1D3
    style IDCUser2 fill:#95E1D3
    style Optional fill:#FFD700
```

### Quick Deployment Order (Simple View)

```mermaid
flowchart LR
    A["1️⃣ AddIDCPermissionSets.yml"] --> B["2️⃣ AddUserGroups.yml"]
    B --> C["3️⃣ AddingUsersAssignments.yml"]

    A -.- A1["Creates Permission Sets"]
    B -.- B1["Creates Groups"]
    C -.- C1["Creates Users<br/>(requires Group IDs)"]

    style A fill:#2E86AB,color:#fff
    style B fill:#A23B72,color:#fff
    style C fill:#F18F01,color:#fff
    style A1 fill:#E8E8E8,color:#333
    style B1 fill:#E8E8E8,color:#333
    style C1 fill:#E8E8E8,color:#333
```

### Resource Relationship Diagram

This diagram shows how AWS resources created by the templates relate to each other:

```mermaid
graph LR
    subgraph AWS_Organization[AWS Organization]
        subgraph IDC[IAM Identity Center Instance]
            subgraph PS_Layer[Permission Sets Layer]
                PS_Admin[AdministratorAccess]
                PS_Power[PowerUserAccess]
                PS_Sys[SystemAdministrator]
                PS_Sec[SecurityAudit]
                PS_RO[ReadOnlyAccess]
                PS_VO[ViewOnlyAccess]
            end

            subgraph Group_Layer[Groups Layer]
                G_Admin[InfraAdmin Group]
                G_RO[InfraReadOnly Group]
            end

            subgraph User_Layer[Users Layer]
                U1[User 1]
                U2[User 2]
            end
        end

        subgraph Accounts[AWS Accounts]
            Acct1[Production Account]
            Acct2[Development Account]
            Acct3[Sandbox Account]
        end
    end

    subgraph CloudFormation[CloudFormation Resources]
        Lambda[Lambda Function]
        IAM[IAM Role]
        CR1[Custom Resource User1]
        CR2[Custom Resource User2]
    end

    U1 -.->|Member of| G_Admin
    U2 -.->|Member of| G_RO

    G_Admin -.->|Can be assigned| PS_Admin
    G_Admin -.->|Can be assigned| PS_Power
    G_RO -.->|Can be assigned| PS_RO
    G_RO -.->|Can be assigned| PS_VO

    PS_Admin -.->|Access to| Acct1
    PS_Admin -.->|Access to| Acct2
    PS_RO -.->|Access to| Acct3

    CR1 -->|Triggers| Lambda
    CR2 -->|Triggers| Lambda
    Lambda -->|Uses| IAM
    Lambda -->|Creates| U1
    Lambda -->|Creates| U2
    Lambda -->|Adds to group| G_Admin
    Lambda -->|Adds to group| G_RO

    style PS_Layer fill:#E3F2FD
    style Group_Layer fill:#F3E5F5
    style User_Layer fill:#FFF3E0
    style CloudFormation fill:#FFEBEE
    style Lambda fill:#FF6B6B
    style IAM fill:#4ECDC4
```

### Understanding the Lambda Custom Resource Flow

Since CloudFormation doesn't natively support `AWS::IdentityStore::User`, we use a Lambda-backed Custom Resource pattern:

```mermaid
sequenceDiagram
    participant CFN as CloudFormation
    participant CR as Custom Resource
    participant Lambda as Lambda Function
    participant IAM as IAM Role
    participant IDStore as Identity Store API

    Note over CFN,IDStore: Stack Creation Process

    CFN->>CR: Create User1 Resource
    CR->>Lambda: Invoke with CREATE event
    Lambda->>IAM: Assume role for permissions
    IAM-->>Lambda: Temporary credentials
    Lambda->>IDStore: CreateUser(username, email, name)
    IDStore-->>Lambda: User ID returned
    Lambda->>IDStore: CreateGroupMembership(userId, groupId)
    IDStore-->>Lambda: Membership ID returned
    Lambda-->>CR: SUCCESS with User ID
    CR-->>CFN: Resource created successfully

    Note over CFN,IDStore: Stack Deletion Process

    CFN->>CR: Delete User1 Resource
    CR->>Lambda: Invoke with DELETE event
    Lambda->>IAM: Assume role for permissions
    IAM-->>Lambda: Temporary credentials
    Lambda->>IDStore: DeleteGroupMembership(membershipId)
    IDStore-->>Lambda: Membership deleted
    Lambda->>IDStore: DeleteUser(userId)
    IDStore-->>Lambda: User deleted
    Lambda-->>CR: SUCCESS
    CR-->>CFN: Resource deleted successfully
```

### Integration with Broader AWS Environment

This diagram shows how the CloudFormation-deployed resources fit into a complete AWS identity management architecture:

```mermaid
graph TB
    subgraph External[External Identity Provider - Optional]
        EntraID[Microsoft Entra ID<br/>Azure Active Directory]
        SAML[SAML 2.0 Integration]
        SCIM[SCIM Auto-Provisioning]
    end

    subgraph AWS_Org[AWS Organization]
        subgraph Management[Management Account]
            Org[AWS Organizations]
            CT[AWS Control Tower<br/>Landing Zone]
        end

        subgraph IDC_Setup[IAM Identity Center]
            direction TB
            IDC_Instance[Identity Center Instance]

            subgraph CF_Templates[CloudFormation Templates<br/>This Guide]
                T1[Permission Sets Template<br/>6 AWS Managed Policies]
                T2[Groups Template<br/>InfraAdmin, InfraReadOnly]
                T3[Users Template<br/>Lambda Custom Resources]
            end

            T1 --> PS_List[Permission Sets:<br/>Admin, Power, System, Security, RO, VO]
            T2 --> Group_List[Groups:<br/>InfraAdmin, InfraReadOnly]
            T3 --> User_List[Users:<br/>Locally managed or synced]
        end

        subgraph Accounts[AWS Accounts in Organization]
            Prod[Production Account]
            Dev[Development Account]
            Sandbox[Sandbox Account]
            Security[Security/Audit Account]
            LogArchive[Log Archive Account]
        end
    end

    subgraph Access[User Access Flow]
        UserLogin[User Login]
        Portal[AWS Access Portal]
        Assume[Assume Role with Permission Set]
        WorkInAccount[Work in AWS Account]
    end

    EntraID -.->|SAML SSO| IDC_Instance
    EntraID -.->|SCIM Sync| User_List
    SAML -.->|Metadata Exchange| IDC_Instance

    Org --> IDC_Instance
    CT --> IDC_Instance

    PS_List --> Assignments[Account Assignments]
    Group_List --> Assignments
    User_List --> Group_List

    Assignments --> Prod
    Assignments --> Dev
    Assignments --> Sandbox
    Assignments --> Security
    Assignments --> LogArchive

    User_List --> UserLogin
    UserLogin --> Portal
    Portal --> Assume
    Assume --> WorkInAccount

    style External fill:#FFE5E5
    style EntraID fill:#0078D4,color:#fff
    style CF_Templates fill:#FFD700
    style T1 fill:#2E86AB,color:#fff
    style T2 fill:#A23B72,color:#fff
    style T3 fill:#F18F01,color:#fff
    style IDC_Instance fill:#FF9900,color:#fff
    style Access fill:#E8F5E9
```

### Deployment Decision Tree

Use this flowchart to determine your deployment approach:

```mermaid
graph TD
    Start{Do you have<br/>Entra ID/Azure AD?}
    Start -->|Yes| EntraQ{Want to use<br/>SSO & Auto-Provisioning?}
    Start -->|No| LocalIDC[Use AWS Identity Center<br/>as Identity Source]

    EntraQ -->|Yes| EntraPath[Deploy Entra ID Integration]
    EntraQ -->|No| LocalIDC

    EntraPath --> EntraSteps[1. Setup SAML between Entra ID & AWS<br/>2. Configure SCIM provisioning<br/>3. Skip CloudFormation User Template<br/>4. Deploy Permission Sets & Groups<br/>5. Users auto-sync from Entra ID]

    LocalIDC --> LocalSteps[1. Deploy Permission Sets Template<br/>2. Deploy Groups Template<br/>3. Deploy Users Template<br/>4. Users managed in AWS Identity Center]

    LocalSteps --> AccountAssign[Manually Create Account Assignments<br/>Link Groups to Accounts + Permission Sets]
    EntraSteps --> AccountAssign

    AccountAssign --> Complete[Users can access AWS accounts]

    style Start fill:#FFD700
    style EntraPath fill:#0078D4,color:#fff
    style LocalIDC fill:#FF9900,color:#fff
    style Complete fill:#90EE90
```

---

## Deployment Order Summary

| Step | Template | Creates | Depends On | Export/Output |
|------|----------|---------|------------|---------------|
| 1️⃣ | `AddIDCPermissionSets.yml` | 6 Permission Sets | IAM Identity Center enabled | Permission Set ARNs |
| 2️⃣ | `AddUserGroups.yml` | 2 Groups (InfraAdmin, InfraReadOnly) | Step 1 complete | Group IDs |
| 3️⃣ | `AddingUsersAssignments.yml` | Lambda function, IAM role, 2 Users | Step 2 complete (needs Group IDs) | User IDs |
| 4️⃣ | Manual | Account Assignments | Steps 1-3 complete | Users can access accounts |

### Complete Deployment Script

```bash
# Set your variables
INSTANCE_ARN="arn:aws:sso:::instance/ssoins-xxxxxxxxxxxxxxxx"
IDENTITY_STORE_ID="d-xxxxxxxxxx"

# Step 1: Deploy Permission Sets
aws cloudformation create-stack \
  --stack-name idc-permission-sets \
  --template-body file://AddIDCPermissionSets.yml \
  --parameters ParameterKey=InstanceArn,ParameterValue=$INSTANCE_ARN

aws cloudformation wait stack-create-complete --stack-name idc-permission-sets

# Step 2: Deploy Groups
aws cloudformation create-stack \
  --stack-name idc-user-groups \
  --template-body file://AddUserGroups.yml \
  --parameters ParameterKey=IdentityStoreId,ParameterValue=$IDENTITY_STORE_ID

aws cloudformation wait stack-create-complete --stack-name idc-user-groups

# Get Group IDs from outputs
INFRA_ADMIN_GROUP_ID=$(aws cloudformation describe-stacks \
  --stack-name idc-user-groups \
  --query "Stacks[0].Outputs[?OutputKey=='InfraAdminGroupId'].OutputValue" \
  --output text)

INFRA_READONLY_GROUP_ID=$(aws cloudformation describe-stacks \
  --stack-name idc-user-groups \
  --query "Stacks[0].Outputs[?OutputKey=='InfraReadOnlyGroupId'].OutputValue" \
  --output text)

# Step 3: Deploy Users
aws cloudformation create-stack \
  --stack-name idc-users \
  --template-body file://AddingUsersAssignments.yml \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameters \
    ParameterKey=IdentityStoreId,ParameterValue=$IDENTITY_STORE_ID \
    ParameterKey=User1UserName,ParameterValue=admin1 \
    ParameterKey=User1FirstName,ParameterValue=Admin \
    ParameterKey=User1LastName,ParameterValue=User \
    ParameterKey=User1Email,ParameterValue=admin1@example.com \
    ParameterKey=User1GroupId,ParameterValue=$INFRA_ADMIN_GROUP_ID \
    ParameterKey=User2UserName,ParameterValue=readonly1 \
    ParameterKey=User2FirstName,ParameterValue=ReadOnly \
    ParameterKey=User2LastName,ParameterValue=User \
    ParameterKey=User2Email,ParameterValue=readonly1@example.com \
    ParameterKey=User2GroupId,ParameterValue=$INFRA_READONLY_GROUP_ID

aws cloudformation wait stack-create-complete --stack-name idc-users
```

---

## Cleanup

To delete all resources, remove stacks in reverse order:

```bash
aws cloudformation delete-stack --stack-name idc-users
aws cloudformation wait stack-delete-complete --stack-name idc-users

aws cloudformation delete-stack --stack-name idc-user-groups
aws cloudformation wait stack-delete-complete --stack-name idc-user-groups

aws cloudformation delete-stack --stack-name idc-permission-sets
aws cloudformation wait stack-delete-complete --stack-name idc-permission-sets
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `Invalid InstanceArn` | Verify format: `arn:aws:sso:::instance/ssoins-xxxxxxxxxxxxxxxx` |
| `Invalid IdentityStoreId` | Verify format: `d-xxxxxxxxxx` |
| User creation fails | Check Lambda logs in CloudWatch for detailed errors |
| Permission denied | Ensure your AWS credentials have IAM Identity Center admin access |
| Stack stuck in `CREATE_IN_PROGRESS` | Check Lambda function logs for Custom Resource timeout |

---

## Additional Notes

- Users created via CloudFormation will need to set up their passwords through the IAM Identity Center portal
- To assign groups to AWS accounts with permission sets, you'll need to create additional `AWS::SSO::Assignment` resources
- The Lambda function runtime is Python 3.11 with a 120-second timeout
