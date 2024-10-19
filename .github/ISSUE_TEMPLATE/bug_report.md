---
name: Bug report
about: Create a report to help us improve
title: '[BUG] '
labels: bug
assignees: ''

---

**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Environment (please complete the following information):**
 - OS: [e.g. Ubuntu 20.04]
 - GitHub Actions Runner version [e.g. 2.283.3]
 - Auto PR Action version [e.g. v1.0.0]

**Workflow file**
Please provide the relevant part of your workflow file:

```yaml
- name: Auto PR from Dev to Default
  uses: yuri-val/auto-pr-action@v1
  with:
    openai_api_key: ${{ secrets.OPENAI_API_KEY }}
    github_token: ${{ secrets.GITHUB_TOKEN }}
    dev_branch: dev
```

**Additional context**
Add any other context about the problem here. For example:
- Are you using self-hosted runners?
- Are there any specific configurations in your repository that might be relevant?
- Have you made any recent changes to your workflow or repository settings?

**Logs**
If possible, please provide relevant log outputs. Make sure to remove any sensitive information.

```
[Log output here]
```

This template will guide users to provide comprehensive information when reporting bugs, including:

1. A description of the bug
2. Steps to reproduce
3. Expected behavior
4. Screenshots (if applicable)
5. Environment details
6. The relevant part of their workflow file
7. Additional context
8. Relevant logs

