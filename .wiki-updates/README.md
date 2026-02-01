# Wiki Update Instructions

This directory contains the updated wiki page that needs to be pushed to the GitHub wiki repository.

## Updated File

- `IAM-Engineering-Project.md` - Updated with purpose explanation and hyperlinks to related wiki pages

## Changes Made

The IAM-Engineering-Project wiki page has been updated with:

1. **Purpose Section**: Added explanation that this wiki covers projects related to:
   - Deploying AWS Organizations
   - Configuring Landing Zone
   - Setting up AWS IAM Identity Center
   - Creating a test Sandbox AWS account using AWS Organizations
   - Integrating AWS Identity Center with Entra ID (Azure AD)

2. **Related Wiki Pages Section**: Added hyperlinks to:
   - AWS Control Tower Setup Guide
   - AWS IAM Identity Center - CloudFormation Deployment Guide
   - Integrating Entra ID with AWS Identity Center

## How to Apply These Changes

The wiki changes have been committed to the wiki repository locally at:
`/home/runner/work/cloudformation_templates/cloudformation_templates.wiki`

To push the changes to GitHub, run:

```bash
cd /home/runner/work/cloudformation_templates/cloudformation_templates.wiki
git push origin master
```

Note: This requires GitHub credentials with write access to the wiki repository.

## Git Commit Details

- Commit SHA: 3e11d208c0681dbb34057f38a1d00347a2531ad3
- Commit Message: "Update IAM Engineering Project wiki with purpose and related page links"
- Files Changed: IAM-Engineering-Project.md (20 insertions, 2 deletions)
