# Wiki Content

This directory contains wiki content that should be manually pushed to the GitHub Wiki repository.

## Updating the Wiki

The GitHub Wiki is a separate git repository. To push changes:

1. Clone the wiki repository:
   ```bash
   git clone https://github.com/damatechguy27/cloudformation_templates.wiki.git
   ```

2. Copy the updated files from this directory to the wiki repository

3. Commit and push the changes:
   ```bash
   cd cloudformation_templates.wiki
   git add .
   git commit -m "Update wiki content"
   git push origin master
   ```

## Files

- **IAM-Engineering-Project.md** - Main wiki page for IAM Engineering projects with overview and related guide links
