# AWS CloudFormation Templates

This repository contains AWS CloudFormation templates for managing AWS infrastructure and identity services.

---

## IAM Identity Center (IDC) Templates

The `idc-cf/` folder contains templates for deploying and managing **AWS IAM Identity Center** (formerly AWS SSO) resources:

| Template | Description |
|----------|-------------|
| `AddIDCPermissionSets.yml` | Creates Permission Sets with AWS managed policies (AdministratorAccess, PowerUserAccess, ReadOnlyAccess, etc.) |
| `AddUserGroups.yml` | Creates Identity Center Groups for organizing users |
| `AddingUsersAssignments.yml` | Creates Users and assigns them to Groups using Lambda-backed Custom Resources |

### Quick Start

1. Navigate to the `idc-cf/` folder
2. Follow the [DEPLOYMENT_GUIDE.md](idc-cf/DEPLOYMENT_GUIDE.md) for detailed instructions

### Prerequisites

- AWS IAM Identity Center enabled in your AWS Organization
- AWS CLI configured with appropriate credentials
- Identity Center Instance ARN and Identity Store ID

---

## What These Templates Do

These CloudFormation templates automate the setup of AWS IAM Identity Center, enabling centralized identity and access management across your AWS Organization.

### High-Level Architecture

```mermaid
graph TB
    subgraph Templates[CloudFormation Templates in This Repo]
        T1[1. Permission Sets Template<br/>AddIDCPermissionSets.yml]
        T2[2. Groups Template<br/>AddUserGroups.yml]
        T3[3. Users Template<br/>AddingUsersAssignments.yml]
    end

    subgraph AWS_Resources[AWS Resources Created]
        subgraph IDC[IAM Identity Center]
            PS[6 Permission Sets<br/>Admin, Power, System, Security, RO, VO]
            Groups[2 Groups<br/>InfraAdmin, InfraReadOnly]
            Users[Users<br/>Created via Lambda]
        end
    end

    subgraph Result[End Result]
        Access[Users can access AWS accounts<br/>with appropriate permissions<br/>via SSO portal]
    end

    T1 --> PS
    T2 --> Groups
    T3 --> Users

    PS --> Access
    Groups --> Access
    Users --> Access

    style Templates fill:#E3F2FD
    style AWS_Resources fill:#FFF3E0
    style Result fill:#E8F5E9
    style T1 fill:#2E86AB,color:#fff
    style T2 fill:#A23B72,color:#fff
    style T3 fill:#F18F01,color:#fff
    style IDC fill:#FF9900,color:#fff
    style Access fill:#4CAF50,color:#fff
```

---

## Deployment Flow Visualization

```mermaid
graph LR
    Start([Deploy Templates]) --> Step1[Step 1: Permission Sets]
    Step1 --> Output1[Outputs: 6 Permission Set ARNs]
    Output1 --> Step2[Step 2: Groups]
    Step2 --> Output2[Outputs: 2 Group IDs]
    Output2 --> Step3[Step 3: Users]
    Step3 --> Output3[Outputs: User IDs]
    Output3 --> Manual[Manual Step:<br/>Create Account Assignments]
    Manual --> Complete([Users Access AWS Accounts])

    style Start fill:#90EE90
    style Complete fill:#90EE90
    style Step1 fill:#2E86AB,color:#fff
    style Step2 fill:#A23B72,color:#fff
    style Step3 fill:#F18F01,color:#fff
    style Output1 fill:#E8E8E8
    style Output2 fill:#E8E8E8
    style Output3 fill:#E8E8E8
    style Manual fill:#FFD700
```

---

## Complete AWS Identity Management Architecture

This diagram shows how the templates fit into a complete AWS identity and access management setup:

```mermaid
graph TB
    subgraph External[Optional: External Identity Provider]
        Entra[Microsoft Entra ID<br/>Azure Active Directory]
        SAML[SAML SSO]
        SCIM[SCIM Provisioning]
    end

    subgraph AWS_Org[AWS Organization]
        subgraph Management[Management Account]
            Org[AWS Organizations]
            CT[AWS Control Tower]
        end

        subgraph IDC_Layer[IAM Identity Center]
            IDC_Instance[Identity Center Instance]

            subgraph Templates_This_Repo[Templates in This Repository]
                T1[Permission Sets Template]
                T2[Groups Template]
                T3[Users Template]
            end

            PS_Set[Permission Sets<br/>Define access levels]
            Groups_Set[Groups<br/>Organize users]
            Users_Set[Users<br/>Individual identities]
        end

        subgraph Accounts[AWS Accounts]
            Prod[Production]
            Dev[Development]
            Sandbox[Sandbox]
            Security[Security/Audit]
        end
    end

    subgraph User_Access[User Experience]
        Login[User Login]
        Portal[AWS Access Portal]
        SelectRole[Select Account + Permission Set]
        Work[Work in AWS Account]
    end

    Entra -.->|Optional| SAML
    SAML -.->|SSO Integration| IDC_Instance
    SCIM -.->|Auto-Provision Users| Users_Set

    Org --> IDC_Instance
    CT --> IDC_Instance

    T1 --> PS_Set
    T2 --> Groups_Set
    T3 --> Users_Set

    Users_Set --> Groups_Set
    Groups_Set --> Assignment[Account Assignments]
    PS_Set --> Assignment

    Assignment --> Prod
    Assignment --> Dev
    Assignment --> Sandbox
    Assignment --> Security

    Users_Set --> Login
    Login --> Portal
    Portal --> SelectRole
    SelectRole --> Work

    style External fill:#FFE5E5
    style Entra fill:#0078D4,color:#fff
    style Templates_This_Repo fill:#FFD700
    style T1 fill:#2E86AB,color:#fff
    style T2 fill:#A23B72,color:#fff
    style T3 fill:#F18F01,color:#fff
    style IDC_Instance fill:#FF9900,color:#fff
    style User_Access fill:#E8F5E9
    style Assignment fill:#FF6B6B,color:#fff
```

---

## Repository Structure

```mermaid
flowchart TB
    subgraph repo["📁 cloudformation_templates/"]
        README["📄 README.md<br/><i>You are here</i>"]
        subgraph idc["📁 idc-cf/"]
            GUIDE["📄 DEPLOYMENT_GUIDE.md<br/><i>Detailed deployment instructions</i>"]
            PS["📄 AddIDCPermissionSets.yml<br/><i>Creates 6 Permission Sets</i>"]
            UG["📄 AddUserGroups.yml<br/><i>Creates InfraAdmin & InfraReadOnly groups</i>"]
            UA["📄 AddingUsersAssignments.yml<br/><i>Lambda-backed user creation</i>"]
        end
    end

    README --> GUIDE
    GUIDE --> PS
    GUIDE --> UG
    GUIDE --> UA

    style repo fill:#1a1a2e,color:#fff
    style idc fill:#16213e,color:#fff
    style README fill:#0f3460,color:#fff
    style GUIDE fill:#e94560,color:#fff
    style PS fill:#2E86AB,color:#fff
    style UG fill:#A23B72,color:#fff
    style UA fill:#F18F01,color:#fff
```

---

## Template Details at a Glance

### 1. AddIDCPermissionSets.yml
Creates six AWS managed permission sets that define what users can do in AWS accounts:

| Permission Set | AWS Managed Policy | Use Case |
|----------------|-------------------|----------|
| AdministratorAccess | `AdministratorAccess` | Full admin rights |
| PowerUserAccess | `PowerUserAccess` | Developer access without IAM management |
| SystemAdministrator | `job-function/SystemAdministrator` | Systems/infrastructure management |
| SecurityAudit | `SecurityAudit` | Security compliance and auditing |
| ReadOnlyAccess | `ReadOnlyAccess` | View-only access to all services |
| ViewOnlyAccess | `job-function/ViewOnlyAccess` | Restricted view-only access |

### 2. AddUserGroups.yml
Creates Identity Center groups for organizing users:

| Group | Purpose |
|-------|---------|
| InfraAdmin | Infrastructure administrators with elevated privileges |
| InfraReadOnly | Read-only access for monitoring and auditing |

### 3. AddingUsersAssignments.yml
Uses Lambda-backed Custom Resources to create users and assign them to groups:

- **Why Lambda?** CloudFormation doesn't natively support creating Identity Center users
- **What it does:** Creates users, assigns to groups, handles cleanup on deletion
- **Runtime:** Python 3.11 Lambda with 120s timeout

---

## Quick Comparison: Local vs. Entra ID Integration

```mermaid
graph TD
    Decision{Using Entra ID<br/>for SSO?}

    Decision -->|Yes| EntraPath[Deploy Entra ID Integration]
    Decision -->|No| LocalPath[Use These Templates]

    EntraPath --> EntraSteps["✓ Deploy Permission Sets template<br/>✓ Deploy Groups template<br/>✗ Skip Users template<br/>→ Users sync from Entra ID via SCIM"]

    LocalPath --> LocalSteps["✓ Deploy Permission Sets template<br/>✓ Deploy Groups template<br/>✓ Deploy Users template<br/>→ Users managed in AWS Identity Center"]

    EntraSteps --> Result[Users access AWS via SSO]
    LocalSteps --> Result

    style Decision fill:#FFD700
    style EntraPath fill:#0078D4,color:#fff
    style LocalPath fill:#FF9900,color:#fff
    style Result fill:#90EE90
```

---

## Template Dependencies & Deployment Order

This diagram shows the dependencies between templates and the required deployment sequence:

```mermaid
graph TB
    subgraph Prerequisites[Prerequisites - Before Deploying]
        PreReq1[AWS IAM Identity Center<br/>enabled in Organization]
        PreReq2[Instance ARN obtained<br/>from Identity Center settings]
        PreReq3[Identity Store ID obtained<br/>from Identity Center settings]
        PreReq4[AWS CLI configured<br/>with admin credentials]
    end

    subgraph Deploy1[Deployment Step 1]
        T1[AddIDCPermissionSets.yml]
        T1Input[Input: Instance ARN]
        T1Output[Output: Permission Set ARNs]
    end

    subgraph Deploy2[Deployment Step 2]
        T2[AddUserGroups.yml]
        T2Input[Input: Identity Store ID]
        T2Output[Output: Group IDs]
    end

    subgraph Deploy3[Deployment Step 3]
        T3[AddingUsersAssignments.yml]
        T3Input[Input: Identity Store ID<br/>+ Group IDs from Step 2]
        T3Output[Output: User IDs]
    end

    subgraph Post[Post-Deployment - Manual]
        Manual1[Create Account Assignments]
        Manual2[Link Groups → Accounts → Permission Sets]
        Manual3[Users can now access AWS accounts]
    end

    Prerequisites --> Deploy1
    PreReq2 --> T1Input
    T1Input --> T1
    T1 --> T1Output

    Deploy1 --> Deploy2
    PreReq3 --> T2Input
    T2Input --> T2
    T2 --> T2Output

    Deploy2 --> Deploy3
    T2Output --> T3Input
    T3Input --> T3
    T3 --> T3Output

    Deploy3 --> Post
    T3Output --> Manual1
    Manual1 --> Manual2
    Manual2 --> Manual3

    style Prerequisites fill:#E8E8E8
    style Deploy1 fill:#E3F2FD
    style Deploy2 fill:#F3E5F5
    style Deploy3 fill:#FFF3E0
    style Post fill:#E8F5E9
    style T1 fill:#2E86AB,color:#fff
    style T2 fill:#A23B72,color:#fff
    style T3 fill:#F18F01,color:#fff
    style Manual3 fill:#4CAF50,color:#fff
```

---

## Key Features & Benefits

### Infrastructure as Code
- **Version Control**: Track all changes to your identity infrastructure
- **Reproducible**: Deploy identical setups across multiple environments
- **Automated**: No manual clicking through AWS console
- **Documented**: Templates serve as living documentation

### Lambda-Backed Custom Resources
- **Native CloudFormation**: Manage users like any other CloudFormation resource
- **Automated Cleanup**: Users are deleted when stack is deleted
- **Error Handling**: Built-in retry logic and error reporting
- **Extensible**: Easy to modify for additional user attributes

### Best Practices Built-In
- **Least Privilege**: Permission sets use AWS managed policies
- **Organized Access**: Group-based permission assignments
- **Session Duration**: Configurable session timeouts
- **Cross-Stack References**: Outputs enable modular deployments

---

## Common Use Cases

### 1. New AWS Organization Setup
```
Deploy all three templates → Create account assignments → Onboard team
```

### 2. Adding New Permission Levels
```
Edit AddIDCPermissionSets.yml → Add new permission set → Redeploy stack
```

### 3. Onboarding New Team Members
```
Edit AddingUsersAssignments.yml → Add user parameters → Update stack
```

### 4. Migrating to Entra ID
```
Setup SAML/SCIM → Deploy Permission Sets & Groups → Skip Users template
```

---

## Related Resources

- **[Detailed Deployment Guide](idc-cf/DEPLOYMENT_GUIDE.md)** - Step-by-step instructions with examples
- **[AWS IAM Identity Center Documentation](https://docs.aws.amazon.com/singlesignon/)** - Official AWS documentation
- **[AWS Control Tower Setup](https://github.com/damatechguy27/cloudformation_templates/wiki/Aws-control-tower-setup-guide)** - Landing Zone setup guide
- **[Entra ID Integration Guide](https://github.com/damatechguy27/cloudformation_templates/wiki/Integrating-Entra-ID-with-AWS-Identity-Center)** - SSO configuration

---

## Getting Help

If you encounter issues:

1. Check the [DEPLOYMENT_GUIDE.md](idc-cf/DEPLOYMENT_GUIDE.md) troubleshooting section
2. Review CloudWatch Logs for Lambda function errors (Users template)
3. Verify Instance ARN and Identity Store ID formats
4. Ensure IAM Identity Center is enabled in your Organization
