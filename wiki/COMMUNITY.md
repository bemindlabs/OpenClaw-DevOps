---
title: Community Guidelines
tags: [community, guidelines, participation]
created: 2026-02-07
updated: 2026-02-07
---

# OpenClaw Community Guidelines

Welcome to the OpenClaw DevOps community! We're excited to have you here. This guide will help you get involved and make the most of your participation.

## 🌟 Getting Involved

### Ways to Contribute

There are many ways to contribute to OpenClaw beyond writing code:

1. **Documentation**
   - Improve existing documentation
   - Write tutorials and guides
   - Translate documentation
   - Create video tutorials

2. **Code Contributions**
   - Fix bugs
   - Implement new features
   - Improve performance
   - Write tests

3. **Community Support**
   - Answer questions in discussions
   - Help troubleshoot issues
   - Share your use cases
   - Mentor new contributors

4. **Design & UX**
   - Improve UI/UX
   - Create graphics and diagrams
   - Design dashboards
   - Suggest UX improvements

5. **Testing & QA**
   - Test new features
   - Report bugs
   - Validate fixes
   - Write automated tests

6. **Infrastructure**
   - Improve CI/CD pipelines
   - Optimize Docker configurations
   - Enhance deployment scripts
   - Monitor performance

## 💬 Communication Channels

### GitHub Discussions
Primary place for:
- Feature requests
- General questions
- Show and tell
- Community announcements

👉 [GitHub Discussions](https://github.com/openclaw/devops/discussions)

### Issues
For:
- Bug reports
- Specific feature requests
- Technical problems

👉 [GitHub Issues](https://github.com/openclaw/devops/issues)

### Discord/Slack (Coming Soon)
Real-time chat for:
- Quick questions
- Community discussions
- Collaboration

### Social Media
- Twitter: [@OpenClawDev](https://twitter.com/OpenClawDev)
- LinkedIn: [OpenClaw](https://linkedin.com/company/openclaw)

## 🎯 Contribution Process

### 1. Find Something to Work On

**For Beginners:**
- Look for issues labeled `good-first-issue`
- Check issues labeled `help-wanted`
- Browse the documentation for gaps

**For Experienced Contributors:**
- Review the [Roadmap](ROADMAP.md)
- Check issues labeled `enhancement`
- Propose new features in Discussions

### 2. Before You Start

1. **Check if it's already being worked on**
   - Look at open PRs
   - Check issue comments
   - Ask in the issue thread

2. **Discuss major changes first**
   - Open a Discussion or Issue
   - Get feedback from maintainers
   - Align on the approach

3. **Read the contributing guide**
   - See [CONTRIBUTING.md](../CONTRIBUTING.md)
   - Follow coding standards
   - Review git hook requirements

### 3. Making Your Contribution

1. **Fork and clone** the repository
2. **Create a branch** (`git checkout -b feature/your-feature`)
3. **Make your changes** following our guidelines
4. **Write tests** if applicable
5. **Update documentation** as needed
6. **Run linters and tests** (pre-commit hooks will help)
7. **Submit a Pull Request**

### 4. Pull Request Review

- Be patient - reviews may take time
- Respond to feedback constructively
- Make requested changes
- Keep the conversation focused and professional

## 📋 Best Practices

### Issue Reporting

**Good Bug Report:**
```markdown
### Description
Clear description of the issue

### Steps to Reproduce
1. Start service with `docker-compose up`
2. Access http://localhost:3000
3. Click on login button
4. See error

### Expected Behavior
Should show login form

### Actual Behavior
Shows 500 error

### Environment
- OS: macOS 14.0
- Docker: 24.0.6
- Node: 20.10.0
- Browser: Chrome 120

### Logs
```
[error] Connection refused...
```
```

### Pull Requests

**Good PR Description:**
```markdown
## What does this PR do?
Adds health check endpoint to gateway service

## Why is this needed?
Enables load balancer health monitoring

## How to test?
1. Start gateway: `pnpm dev:gateway`
2. Access: `curl http://localhost:18789/health`
3. Should return: `{"status": "ok"}`

## Checklist
- [x] Tests added/updated
- [x] Documentation updated
- [x] Linting passes
- [x] Follows coding standards
```

## 🏆 Recognition

We value all contributions! Contributors are recognized through:

- **Contributors List** - All contributors listed in README
- **Release Notes** - Contributors credited in each release
- **Community Highlights** - Monthly spotlight on contributors
- **Badges** - GitHub badges for different contribution types

## 🎓 Learning Resources

### For New Contributors

- [First Contributions Guide](https://github.com/firstcontributions/first-contributions)
- [How to Contribute to Open Source](https://opensource.guide/how-to-contribute/)
- [Understanding the GitHub Flow](https://guides.github.com/introduction/flow/)

### Technical Resources

- [Docker Documentation](https://docs.docker.com/)
- [pnpm Workspaces](https://pnpm.io/workspaces)
- [Next.js Documentation](https://nextjs.org/docs)
- [Express.js Guide](https://expressjs.com/en/guide/routing.html)

## 🤝 Community Values

### Collaboration Over Competition
We work together to build something great. Share knowledge freely and help each other succeed.

### Quality Over Quantity
We value well-thought-out contributions over rushing to add features. Take time to do things right.

### Respect and Kindness
Treat everyone with respect. We're all learning and growing together.

### Transparency
Communicate openly about decisions, changes, and challenges.

### Continuous Improvement
Always looking for ways to improve the project, our processes, and our community.

## 📞 Getting Help

### Stuck on Something?

1. **Check the documentation** - [Wiki](Home.md)
2. **Search existing issues** - Your question might be answered
3. **Ask in Discussions** - Community is here to help
4. **Join Discord/Slack** - Real-time help available

### Need Mentorship?

We offer mentorship for new contributors:
- Pair programming sessions
- Code review guidance
- Architecture discussions
- Career advice

Reach out in Discussions with the `mentorship` tag.

## 🎉 Community Events

### Regular Events (Planned)

- **Monthly Community Calls** - Discuss roadmap and recent changes
- **Office Hours** - Ask maintainers anything
- **Contributor Spotlights** - Showcase community contributions
- **Hackathons** - Build cool features together

## 🔒 Security

If you discover a security vulnerability, please follow our [Security Policy](SECURITY.md).

**Do NOT** open a public issue for security vulnerabilities.

## 📜 Code of Conduct

All community members must follow our [Code of Conduct](CODE_OF_CONDUCT.md).

## 📝 License

By contributing to OpenClaw, you agree that your contributions will be licensed under the project's license (see [LICENSE](../LICENSE)).

---

**Thank you for being part of the OpenClaw community!** 🎉

Every contribution, no matter how small, makes a difference. We're excited to see what we'll build together.

---

**Questions?** Open a [Discussion](https://github.com/openclaw/devops/discussions) or reach out to community@openclaw.dev

**Last Updated:** 2026-02-07
