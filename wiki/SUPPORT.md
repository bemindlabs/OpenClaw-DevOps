---
title: Support
tags: [support, help, community]
created: 2026-02-07
updated: 2026-02-07
---

# Getting Support

Need help with OpenClaw DevOps? You're in the right place! This guide will help you find the support you need.

## 📚 Self-Service Resources

Before asking for help, check these resources:

### Documentation

1. **[Quick Start Guide](setup/Quick-Start-Guide.md)** - Get up and running quickly
2. **[Architecture Overview](Architecture-Overview.md)** - Understand the system
3. **[Troubleshooting](troubleshooting/Common-Issues.md)** - Common problems and solutions
4. **[FAQ](troubleshooting/FAQ.md)** - Frequently asked questions
5. **[Wiki Home](Home.md)** - Complete documentation index

### Guides

- [Database Backup](guides/Database-Backup.md)
- [SSL Setup](guides/SSL-Setup.md)
- [Monitoring Setup](guides/Monitoring-Setup.md)
- [Development Environment](guides/Development-Environment.md)

## 🔍 Search First

Before opening an issue, please search:

1. **[Existing Issues](https://github.com/openclaw/devops/issues)**
   - Your question might already be answered
   - Use GitHub's search with filters

2. **[Discussions](https://github.com/openclaw/devops/discussions)**
   - Check Q&A section
   - Browse past discussions

3. **[Closed Issues](https://github.com/openclaw/devops/issues?q=is%3Aissue+is%3Aclosed)**
   - Solutions to previously resolved problems

## 💬 Community Support

### GitHub Discussions (Recommended)

Best for:
- General questions
- How-to questions
- Sharing ideas
- Community discussions

👉 [Start a Discussion](https://github.com/openclaw/devops/discussions/new)

**Tips for getting help:**
- Use a clear, descriptive title
- Provide context and details
- Include relevant code/config snippets
- Share what you've already tried

### Discord/Slack (Coming Soon)

Real-time chat for:
- Quick questions
- Community interaction
- Live troubleshooting
- Pair debugging

## 🐛 Bug Reports

Found a bug? Help us fix it!

### Before Reporting

1. ✅ Confirm it's actually a bug (not expected behavior)
2. ✅ Check if it's already reported
3. ✅ Gather necessary information
4. ✅ Create a minimal reproduction

### How to Report

1. **Open a new issue**: [Create Bug Report](https://github.com/openclaw/devops/issues/new?template=bug_report.md)

2. **Include this information:**
   ```markdown
   ### Description
   Clear description of the bug

   ### Steps to Reproduce
   1. Step one
   2. Step two
   3. See error

   ### Expected Behavior
   What should happen

   ### Actual Behavior
   What actually happens

   ### Environment
   - OS: [e.g., Ubuntu 22.04]
   - Docker: [e.g., 24.0.6]
   - Node: [e.g., 20.10.0]
   - pnpm: [e.g., 9.0.0]

   ### Logs
   ```
   Relevant error logs
   ```

   ### Screenshots
   If applicable
   ```

### Bug Report Template

Use our [bug report template](.github/ISSUE_TEMPLATE/bug_report.md) which includes all necessary sections.

## 💡 Feature Requests

Have an idea? We'd love to hear it!

### Before Requesting

1. ✅ Check if it already exists in [Roadmap](ROADMAP.md)
2. ✅ Search existing feature requests
3. ✅ Consider if it fits the project scope

### How to Request

1. **Open a discussion first**: [Feature Requests](https://github.com/openclaw/devops/discussions/categories/feature-requests)

2. **Describe your idea:**
   ```markdown
   ### Problem
   What problem does this solve?

   ### Proposed Solution
   How should it work?

   ### Alternatives Considered
   What other approaches could work?

   ### Additional Context
   Any mockups, examples, or references
   ```

3. **Gather feedback** from the community

4. **If approved**, create an issue with the refined proposal

## 🚨 Critical Issues

### Production Issues

If you're experiencing a critical production issue:

1. **Check service status**: `docker-compose ps`
2. **View logs**: `docker-compose logs -f [service]`
3. **Consult** [Troubleshooting Guide](troubleshooting/Common-Issues.md)
4. **Open a high-priority issue** with `[URGENT]` in the title

### Security Vulnerabilities

**DO NOT** open a public issue for security vulnerabilities!

Follow our [Security Policy](SECURITY.md):
- Email: security@openclaw.dev
- GPG Key: [Available in SECURITY.md](SECURITY.md)

## 📖 Documentation Help

### Found a Documentation Issue?

- **Typo or small fix**: Open a PR directly
- **Missing documentation**: Open an issue with `documentation` label
- **Unclear instructions**: Open a discussion

### Want to Improve Docs?

See [Contributing to Documentation](CONTRIBUTING.md#documentation)

## 🎓 Learning Resources

### Tutorials & Guides

- [Quick Start Guide](setup/Quick-Start-Guide.md)
- [First Deployment Guide](setup/First-Deployment.md)
- [GCE Deployment Guide](deployment/GCE.md)

### External Resources

- [Docker Documentation](https://docs.docker.com/)
- [pnpm Documentation](https://pnpm.io/)
- [Next.js Documentation](https://nextjs.org/docs)
- [Nginx Documentation](https://nginx.org/en/docs/)

## 🤝 Professional Support

### Enterprise Support (Coming Soon)

For organizations needing dedicated support:
- Priority response times
- Custom feature development
- Training and onboarding
- Architecture consulting

Contact: enterprise@openclaw.dev

### Consulting Services

Need help with:
- Custom deployments
- Performance optimization
- Security audits
- Migration assistance

Contact: consulting@openclaw.dev

## ⏱️ Response Times

### Community Support (Best Effort)

- **Discussions**: Usually within 24-48 hours
- **Issues**: Triaged within 48 hours
- **Pull Requests**: Initial review within 3-5 days

### What to Expect

- **Simple questions**: Quick responses from community
- **Complex issues**: May take time to investigate
- **Feature requests**: Discussed and considered for roadmap

**Note:** This is a community project. Response times are not guaranteed.

## 🎯 Getting the Best Help

### Do's ✅

- **Be specific** - Provide details and context
- **Be patient** - Maintainers and community members are volunteers
- **Be respectful** - Follow [Code of Conduct](CODE_OF_CONDUCT.md)
- **Be helpful** - Help others when you can
- **Follow up** - Update the issue/discussion with your resolution

### Don'ts ❌

- **Don't** post the same question in multiple places
- **Don't** bump issues aggressively
- **Don't** demand immediate responses
- **Don't** share sensitive information publicly
- **Don't** hijack other people's issues

## 📞 Contact Information

### General Questions
- Discussions: [GitHub Discussions](https://github.com/openclaw/devops/discussions)
- Email: community@openclaw.dev

### Security Issues
- Email: security@openclaw.dev
- See: [SECURITY.md](SECURITY.md)

### Business Inquiries
- Email: business@openclaw.dev

### Code of Conduct Violations
- Email: conduct@openclaw.dev

## 🌟 Help Others

Once you've been helped, consider:
- **Documenting your solution** - Update the wiki
- **Answering questions** - Help others with similar issues
- **Contributing** - Turn your learning into improvements

## 📊 Support Metrics

We track support metrics to improve:
- Average response time
- Issue resolution rate
- Community satisfaction
- Documentation effectiveness

Your feedback helps us improve!

---

**Remember:** The best way to get help is to help others. The more we all contribute, the stronger our community becomes! 🎉

---

**Last Updated:** 2026-02-07
**Questions?** Open a [Discussion](https://github.com/openclaw/devops/discussions)
