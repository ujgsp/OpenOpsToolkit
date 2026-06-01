# Contributing to OpenOps Toolkit

Terima kasih atas minat Anda untuk berkontribusi! 🎉

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Branch Naming Convention](#branch-naming-convention)
- [Pull Request Process](#pull-request-process)
- [Issue Templates](#issue-templates)
- [Coding Standards](#coding-standards)
- [Documentation](#documentation)
- [Community](#community)

---

## Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

---

## Getting Started

### Prerequisites

1. **Fork** the repository
2. **Clone** your fork locally
3. **Create** a new branch for your changes
4. **Make** your changes
5. **Test** your changes
6. **Submit** a pull request

### Development Setup

```bash
# Fork and clone
git clone https://github.com/YOUR_USERNAME/openops-toolkit.git
cd openops-toolkit

# Add upstream remote
git remote add upstream https://github.com/openops-toolkit/openops-toolkit.git

# Create a branch
git checkout -b feature/your-feature-name
```

---

## How to Contribute

### 🐛 Reporting Bugs

1. Check existing [issues](https://github.com/openops-toolkit/openops-toolkit/issues) first
2. Use the **bug report** template
3. Include:
   - Clear description
   - Steps to reproduce
   - Expected vs actual behavior
   - Environment details
   - Screenshots (if applicable)

### 💡 Suggesting Features

1. Check existing [discussions](https://github.com/openops-toolkit/openops-toolkit/discussions)
2. Use the **feature request** template
3. Explain:
   - Problem you're trying to solve
   - Proposed solution
   - Alternatives considered
   - Additional context

### 📝 Improving Documentation

1. Find documentation issues in [docs](docs/)
2. Use the **documentation** template
3. Submit improvements via pull request

### 🔧 Contributing Code

1. Check [issues](https://github.com/openops-toolkit/openops-toolkit/issues) for available tasks
2. Look for `good first issue` or `help wanted` labels
3. Comment on the issue to claim it
4. Submit your changes

---

## Branch Naming Convention

Use descriptive branch names:

```
feature/short-description
bugfix/issue-number-description
docs/what-you-are-documenting
refactor/what-you-are-refactoring
```

### Examples

```
feature/laravel-nginx-config
bugfix/123-ssl-certificate-error
docs/ansible-role-guide
refactor/monitoring-scripts
```

---

## Pull Request Process

### Before Submitting

1. **Update** your branch with latest upstream changes
2. **Test** your changes thoroughly
3. **Update** documentation if needed
4. **Follow** coding standards
5. **Write** clear commit messages

### PR Template

```markdown
## Description

Brief description of the changes.

## Type of Change

- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Checklist

- [ ] My code follows the style guidelines of this project
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes

## Related Issues

Closes #123
```

### Review Process

1. **Automated checks** will run
2. **Maintainers** will review your code
3. **Address** any requested changes
4. **Approval** and merge

---

## Issue Templates

We use issue templates to ensure consistency:

### Bug Report

```markdown
## Description

[Clear description of the bug]

## Steps to Reproduce

1. Go to '...'
2. Click on '...'
3. Scroll down to '...'
4. See error

## Expected Behavior

[What you expected to happen]

## Actual Behavior

[What actually happened]

## Environment

- OS: [e.g., Ubuntu 22.04]
- Ansible Version: [e.g., 2.9.27]
- Python Version: [e.g., 3.10]

## Additional Context

[Any other context about the problem]
```

### Feature Request

```markdown
## Problem Statement

[Clear description of the problem]

## Proposed Solution

[Your proposed solution]

## Alternatives Considered

[Other solutions you've considered]

## Additional Context

[Any other context or screenshots]
```

---

## Coding Standards

### Ansible

- Use YAML syntax
- Follow [Ansible Best Practices](https://docs.ansible.com/ansible/latest/tips_tricks/ansible_tips_tricks.html)
- Use meaningful variable names
- Add comments for complex tasks
- Include `README.md` for each role

### YAML

- Use 2 spaces for indentation
- Use lowercase for keys
- Use descriptive names
- Add comments for clarity

### Shell Scripts

- Use `#!/bin/bash` shebang
- Add error handling (`set -e`)
- Include usage instructions
- Add comments for complex logic

### Documentation

- Use Markdown format
- Follow the [Documentation Style Guide](docs/style-guide.md)
- Include examples
- Keep it concise and clear

---

## Documentation

### Writing Guidelines

1. **Be Clear**: Use simple language
2. **Be Concise**: Avoid unnecessary words
3. **Be Complete**: Include all necessary information
4. **Be Accurate**: Verify information before publishing

### Documentation Structure

```
docs/
├── deployment/      # How to deploy
├── automation/      # How to automate
├── monitoring/      # How to monitor
├── aiops/          # AI operations
└── roadmap/        # Project roadmap
```

---

## Community

### Getting Help

- **Issues**: For bugs and feature requests
- **Discussions**: For questions and ideas
- **Pull Requests**: For code contributions

### Communication

- Be respectful and inclusive
- Use clear and concise language
- Provide context when asking questions
- Help others when you can

### Recognition

Contributors will be:
- Listed in [CONTRIBUTORS.md](CONTRIBUTORS.md)
- Mentioned in release notes
- Given credit in documentation

---

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

## Questions?

If you have questions about contributing, please:
1. Check existing [documentation](docs/)
2. Search [issues](https://github.com/openops-toolkit/openops-toolkit/issues)
3. Start a [discussion](https://github.com/openops-toolkit/openops-toolkit/discussions)

---

**Thank you for contributing to OpenOps Toolkit!** 🚀