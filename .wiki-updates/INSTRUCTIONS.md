# Instructions to Complete Wiki Update

## Overview

The IAM-Engineering-Project wiki page has been successfully updated with all requested content and is ready to be pushed to GitHub. The changes are committed locally in the wiki repository and just need to be pushed.

## What Was Updated

The wiki page at `https://github.com/damatechguy27/cloudformation_templates/wiki/IAM-Engineering-Project` has been updated with:

### 1. Purpose Section
Added explanation that this wiki covers projects related to:
- Deploying AWS Organizations
- Configuring Landing Zone
- Setting up AWS IAM Identity Center
- Creating a test Sandbox AWS account using AWS Organizations
- Integrating AWS Identity Center with Entra ID (Azure AD)

### 2. Related Wiki Pages
Added hyperlinks to:
- [AWS Control Tower Setup Guide](https://github.com/damatechguy27/cloudformation_templates/wiki/Aws-control-tower-setup-guide)
- [AWS IAM Identity Center - CloudFormation Deployment Guide](https://github.com/damatechguy27/cloudformation_templates/wiki/AWS-IAM-Identity-Center-%E2%80%90-CloudFormation-Deployment-Guide)
- [Integrating Entra ID with AWS Identity Center](https://github.com/damatechguy27/cloudformation_templates/wiki/Integrating-Entra-ID-with-AWS-Identity-Center)

## Files in This Directory

- `IAM-Engineering-Project.md` - The updated wiki page content
- `README.md` - Detailed information about the changes
- `SUMMARY.md` - Before/after comparison and change summary
- `push-wiki-changes.sh` - Script to push the changes to GitHub
- `INSTRUCTIONS.md` - This file

## How to Push the Changes

### Option 1: Using the Provided Script

```bash
cd /home/runner/work/cloudformation_templates/cloudformation_templates/.wiki-updates
./push-wiki-changes.sh
```

### Option 2: Manual Push

```bash
cd /home/runner/work/cloudformation_templates/cloudformation_templates.wiki
git push origin master
```

### Option 3: Using GitHub CLI

```bash
cd /home/runner/work/cloudformation_templates/cloudformation_templates.wiki
gh auth login
git push origin master
```

## Verification

After pushing, you can verify the changes at:
https://github.com/damatechguy27/cloudformation_templates/wiki/IAM-Engineering-Project

The page should now display:
- A proper title: "IAM Engineering Project"
- A Purpose section with the five project areas listed
- A Related Wiki Pages section with three hyperlinks

## Git Commit Information

- **Repository**: cloudformation_templates.wiki
- **Branch**: master
- **Commit SHA**: 3e11d208c0681dbb34057f38a1d00347a2531ad3
- **Commit Message**: "Update IAM Engineering Project wiki with purpose and related page links"
- **Files Changed**: IAM-Engineering-Project.md (20 additions, 2 deletions)

## Troubleshooting

If you encounter authentication issues:

1. Ensure you have write access to the wiki repository
2. Configure GitHub credentials:
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```
3. Use a personal access token or GitHub CLI for authentication
4. Alternatively, edit the wiki page directly through the GitHub web interface

## Alternative: Manual Web Update

If pushing is not possible, you can also update the wiki page directly via the GitHub web interface:

1. Navigate to: https://github.com/damatechguy27/cloudformation_templates/wiki/IAM-Engineering-Project/_edit
2. Replace the content with the content from `IAM-Engineering-Project.md` in this directory
3. Save the page

## Summary

✓ All content requirements have been met
✓ All hyperlinks have been added correctly
✓ Changes are committed and ready to push
✓ Markdown formatting is correct
□ Final step: Push to GitHub (authentication required)
