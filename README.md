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

## Repository Structure

```mermaid
flowchart TB
    subgraph repo["📁 cloudformation_templates/"]
        README["📄 README.md"]
        subgraph idc["📁 idc-cf/"]
            GUIDE["📄 DEPLOYMENT_GUIDE.md<br/><i>Detailed deployment instructions</i>"]
            PS["📄 AddIDCPermissionSets.yml<br/><i>Permission Sets template</i>"]
            UG["📄 AddUserGroups.yml<br/><i>Groups template</i>"]
            UA["📄 AddingUsersAssignments.yml<br/><i>Users template</i>"]
        end
    end
    
    style repo fill:#1a1a2e,color:#fff
    style idc fill:#16213e,color:#fff
    style README fill:#0f3460,color:#fff
    style GUIDE fill:#e94560,color:#fff
    style PS fill:#533483,color:#fff
    style UG fill:#533483,color:#fff
    style UA fill:#533483,color:#fff
```
