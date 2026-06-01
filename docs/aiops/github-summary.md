# AI GitHub Issue Summary

AI-powered GitHub issue summarization and prioritization.

## Overview

This tool uses AI to:
- Summarize long GitHub issues
- Extract action items
- Classify priority
- Detect duplicates

## Features

### Issue Summarization

- Extract key points from issue description
- Summarize long comment threads
- Identify main problem and proposed solutions

### Action Item Extraction

- Extract tasks from issue description
- Identify TODO items in comments
- Track action item completion

### Priority Classification

- Analyze issue content for severity
- Consider impact and urgency
- Suggest priority labels

### Duplicate Detection

- Compare with existing issues
- Identify similar issues
- Suggest merging or linking

## Usage

### Manual Analysis

```bash
# Summarize a single issue
python scripts/ai_github.py --repo owner/repo --issue 123

# Summarize all open issues
python scripts/ai_github.py --repo owner/repo --open

# Analyze issue priority
python scripts/ai_github.py --repo owner/repo --issue 123 --priority
```

### Automated Analysis

```yaml
# GitHub Actions workflow
name: AI Issue Summary

on:
  issues:
    types: [opened, edited]

jobs:
  summarize:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Generate Summary
        uses: ./.github/actions/ai-summary
        with:
          issue-number: ${{ github.event.issue.number }}
          github-token: ${{ secrets.GITHUB_TOKEN }}
```

## Prompts

### Issue Summarization

```
Summarize the following GitHub issue in 2-3 sentences. Include:
1. The main problem or feature request
2. Any proposed solutions
3. Current status or blockers

Issue Title: {title}
Issue Body: {body}
Comments: {comments}
```

### Action Item Extraction

```
Extract action items from the following GitHub issue. List each item as:
- [ ] Action item description

Include items from:
1. Issue description
2. Comments
3. TODO items mentioned

Issue Title: {title}
Issue Body: {body}
Comments: {comments}
```

### Priority Classification

```
Classify the priority of this GitHub issue as: Critical, High, Medium, or Low.

Consider:
1. Impact on users
2. Urgency of fix
3. Complexity of solution
4. Number of affected users

Issue Title: {title}
Issue Body: {body}
Labels: {labels}
```

### Duplicate Detection

```
Check if this GitHub issue is a duplicate of any existing issues.

Compare with:
1. Issue titles
2. Issue descriptions
3. Labels and components

New Issue:
Title: {title}
Body: {body}

Existing Issues:
{existing_issues}
```

## Examples

### Example 1: Long Issue Summary

**Input:**
```
Title: Application crashes when uploading large files

Body:
I've been experiencing crashes when trying to upload files larger than 10MB. 
The application freezes and then shows a 500 error. This happens on both 
Chrome and Firefox. I've tried:
- Clearing browser cache
- Using incognito mode
- Different file types (PDF, images, videos)

The error log shows:
[2024-01-15 10:23:45] production.ERROR: Allowed memory size of 134217728 bytes exhausted

This is a critical issue for our users who need to upload large documents.
```

**AI Output:**
```
## Summary

The application crashes when users attempt to upload files larger than 10MB, 
resulting in a 500 error. The issue occurs across multiple browsers and file 
types, indicating a server-side problem rather than client-specific.

## Root Cause

The error log indicates PHP memory limit exhaustion (128MB limit reached). 
Large file uploads are consuming more memory than allocated.

## Action Items

- [ ] Increase PHP memory_limit in php.ini
- [ ] Implement chunked file upload
- [ ] Add file size validation before upload
- [ ] Improve error handling for large files

## Priority: High

This affects a core functionality (file uploads) and impacts multiple users.
```

### Example 2: Action Item Extraction

**Input:**
```
Title: Implement user authentication

Body:
We need to implement user authentication with the following features:
- Login with email/password
- Password reset functionality
- Remember me option
- Two-factor authentication (optional)

TODO:
- Design database schema
- Create API endpoints
- Build frontend components
- Write tests
```

**AI Output:**
```
## Action Items

### Database
- [ ] Design user table schema
- [ ] Create sessions table
- [ ] Create password_resets table

### Backend
- [ ] Create authentication API endpoints
- [ ] Implement password hashing
- [ ] Add session management
- [ ] Create password reset flow
- [ ] Implement 2FA (optional)

### Frontend
- [ ] Build login form
- [ ] Build registration form
- [ ] Build password reset form
- [ ] Add remember me functionality

### Testing
- [ ] Write unit tests for auth logic
- [ ] Write integration tests for API
- [ ] Write E2E tests for login flow
```

## Configuration

### Environment Variables

```bash
# GitHub Token
GITHUB_TOKEN=your-github-token

# OpenAI API Key
OPENAI_API_KEY=your-api-key

# Model to use
AI_MODEL=gpt-3.5-turbo

# Max tokens for response
AI_MAX_TOKENS=500
```

### Configuration File

```yaml
# config/ai_github.yml
github_summary:
  enabled: true
  model: gpt-3.5-turbo
  max_tokens: 500
  temperature: 0.3
  
  features:
    summarization: true
    action_items: true
    priority: true
    duplicates: true
  
  triggers:
    on_open: true
    on_edit: true
    on_comment: false
```

## Integration

### With GitHub Actions

```yaml
# .github/workflows/ai-summary.yml
name: AI Issue Summary

on:
  issues:
    types: [opened]

jobs:
  summarize:
    runs-on: ubuntu-latest
    permissions:
      issues: write
    
    steps:
      - uses: actions/checkout@v2
      
      - name: Generate Summary
        uses: openai/gpt-3.5-turbo@v1
        with:
          prompt: |
            Summarize this GitHub issue:
            Title: ${{ github.event.issue.title }}
            Body: ${{ github.event.issue.body }}
          
      - name: Add Comment
        uses: actions/github-script@v6
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: '## AI Summary\n\n' + summary
            })
```

### With GitHub Bot

```python
import github
import openai

def summarize_issue(repo_name, issue_number):
    """Summarize a GitHub issue using AI."""
    # Get issue
    g = github.Github(os.getenv('GITHUB_TOKEN'))
    repo = g.get_repo(repo_name)
    issue = repo.get_issue(issue_number)
    
    # Generate summary
    prompt = f"""
    Summarize this GitHub issue:
    Title: {issue.title}
    Body: {issue.body}
    """
    
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "system", "content": "You are a helpful assistant."},
            {"role": "user", "content": prompt}
        ]
    )
    
    summary = response.choices[0].message.content
    
    # Add comment
    issue.create_comment(f"## AI Summary\n\n{summary}")
    
    return summary
```

## Best Practices

### 1. Prompt Design

- Be specific about output format
- Include relevant context
- Ask for structured output
- Iterate on prompts

### 2. Token Management

- Summarize long issues before analysis
- Use appropriate model for task
- Cache responses when possible
- Monitor API usage

### 3. Quality Control

- Validate AI output
- Allow manual corrections
- Track accuracy over time
- Improve prompts based on feedback

## Troubleshooting

### Common Issues

1. **API Rate Limiting**
   - Implement exponential backoff
   - Cache responses
   - Use batch processing

2. **Poor Summary Quality**
   - Improve prompt specificity
   - Provide more context
   - Use more capable model

3. **Incorrect Priority**
   - Add more training examples
   - Use rule-based pre-filtering
   - Allow manual override

## Resources

- [GitHub API Documentation](https://docs.github.com/en/rest)
- [OpenAI API Documentation](https://platform.openai.com/docs/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## License

MIT

## Author

OpenOps Toolkit Contributors