# Auto PR from Dev to Default Branch

## Description

This GitHub Action automatically creates or updates a Pull Request from a development branch to the default branch, generates descriptive PR content using OpenAI's API, and adds relevant reviewers.

## Features

- 🔄 Automatically creates or updates a PR from dev to the default branch
- 🤖 Generates PR descriptions using OpenAI API
- 👥 Automatically adds relevant reviewers
- 📅 Sets PR title with current date (e.g., "Release v2023.05.25")

## Inputs

| Name | Description | Required | Default |
|------|-------------|----------|---------|
| `openai_api_key` | OpenAI API Key | Yes | N/A |
| `github_token` | GitHub Personal Access Token with repo permissions | Yes | N/A |
| `dev_branch` | Name of the development branch | No | 'dev' |

## Outputs

| Name | Description |
|------|-------------|
| `pr_number` | The number of the pull request created or updated |

## Usage

To use this action in your workflow, add the following step:

```yaml
- name: Auto PR from Dev to Default
  uses: yuri-val/auto-pr-action@v1
  with:
    openai_api_key: ${{ secrets.OPENAI_API_KEY }}
    github_token: ${{ secrets.GITHUB_TOKEN }}
    dev_branch: dev  # Optional, defaults to 'dev'
```

Make sure to set up the `OPENAI_API_KEY` secret in your repository settings.

### Example Workflow Using Your Custom Action

Create a workflow file in your repository (e.g., `.github/workflows/auto-pr.yml`):

```yml
name: Auto PR from dev to default

on:
  push:
    branches:
      - dev

jobs:
  auto-pr:
    runs-on: ubuntu-latest
    steps:
      - name: Run Auto PR Action
        uses: yuri-val/auto-pr-action@v1.0.0
        with:
          openai_api_key: ${{ secrets.OPENAI_API_KEY }}
          github_token: ${{ secrets.PAT_TOKEN }}
          dev_branch: 'dev'  # Optional, defaults to 'dev'

```

## How it works

1. Checks out the repository
2. Sets up Git configuration
3. Determines the default branch
4. Generates a diff between the dev and default branches
5. Uses OpenAI API to generate a descriptive PR content
6. Creates a new PR or updates an existing one
7. Adds relevant reviewers to the PR

## License

[MIT License](LICENSE)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

This README.md provides an overview of your GitHub Action, including its features, inputs, outputs, and usage instructions. It also briefly explains how the action works and includes sections for licensing and contributions.

You may want to adjust the "Usage" section to reflect the correct GitHub username or organization where this action will be published. Also, if you haven't already, you might want to add a LICENSE file to your repository.

Feel free to modify this README to better fit your project's specific needs or to add any additional information you think would be helpful for users of your GitHub Action.
