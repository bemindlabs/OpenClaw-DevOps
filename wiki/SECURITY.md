---
title: Security Policy
tags: [security, vulnerability, policy]
created: 2026-02-07
updated: 2026-02-07
---

# Security Policy

## 🔒 Reporting Security Vulnerabilities

The OpenClaw team takes security seriously. We appreciate your efforts to responsibly disclose your findings.

### ⚠️ DO NOT Create Public Issues

**Please DO NOT** report security vulnerabilities through public GitHub issues, discussions, or pull requests.

### How to Report

**Email:** security@openclaw.dev

**Subject:** `[SECURITY] Brief description of vulnerability`

**Include in your report:**

1. **Vulnerability Description**
   - Type of vulnerability (e.g., XSS, SQL Injection, RCE)
   - Affected component/service
   - Severity assessment (if possible)

2. **Steps to Reproduce**
   - Detailed reproduction steps
   - Proof of concept code (if applicable)
   - Screenshots or videos (if helpful)

3. **Impact Assessment**
   - What can be exploited?
   - What data is at risk?
   - Who is affected?

4. **Suggested Fix** (optional)
   - Proposed remediation
   - Code patches (if you've developed them)

5. **Contact Information**
   - Your name/handle
   - Email for follow-up
   - GPG key (if you want encrypted responses)

### Example Report

```
Subject: [SECURITY] SQL Injection in Gateway API

Description:
SQL injection vulnerability in the /api/users endpoint allows unauthorized
access to user database.

Steps to Reproduce:
1. Send POST request to /api/users
2. Include payload: {"username": "admin' OR '1'='1"}
3. Database returns all users without authentication

Impact:
- Attackers can access all user data
- Potential data exfiltration
- Affects all gateway instances

Environment:
- Version: 1.0.0
- Service: openclaw-gateway
- Database: PostgreSQL 15

Suggested Fix:
Use parameterized queries instead of string concatenation.
Patch available at: [gist link]

Contact:
- Name: John Doe
- Email: john@example.com
- GPG: [key fingerprint]
```

## 🎯 What to Report

### In Scope

Report these types of vulnerabilities:

- **Authentication/Authorization Bypass**
- **SQL Injection**
- **Cross-Site Scripting (XSS)**
- **Cross-Site Request Forgery (CSRF)**
- **Remote Code Execution (RCE)**
- **Server-Side Request Forgery (SSRF)**
- **Insecure Direct Object References**
- **Security Misconfigurations**
- **Sensitive Data Exposure**
- **XML External Entity (XXE)**
- **Broken Access Control**
- **Insecure Deserialization**
- **Using Components with Known Vulnerabilities**
- **Insufficient Logging & Monitoring**

### Out of Scope

Please do NOT report:

- **Missing security headers** (unless critical impact)
- **Denial of Service** attacks requiring significant resources
- **Social engineering** attacks
- **Physical attacks**
- **Issues in dependencies** (report to upstream project)
- **Issues requiring physical access** to servers
- **Theoretical vulnerabilities** without proof of concept

## ⏱️ Response Timeline

We aim to respond according to this timeline:

| Stage | Timeline |
|-------|----------|
| **Initial Response** | Within 48 hours |
| **Triage & Validation** | Within 5 business days |
| **Fix Development** | Depends on severity |
| **Release & Disclosure** | Coordinated with reporter |

### Severity Levels

| Severity | Response Time | Fix Timeline |
|----------|--------------|--------------|
| **Critical** | < 24 hours | < 7 days |
| **High** | < 48 hours | < 14 days |
| **Medium** | < 5 days | < 30 days |
| **Low** | < 10 days | Next release |

## 🛡️ Security Update Process

### How We Handle Vulnerabilities

1. **Acknowledge Receipt** - We confirm receipt of your report
2. **Validate Issue** - We reproduce and confirm the vulnerability
3. **Assess Severity** - We determine impact and severity
4. **Develop Fix** - We create and test a patch
5. **Coordinate Disclosure** - We work with you on disclosure timing
6. **Release Patch** - We release a security update
7. **Publish Advisory** - We publish security advisory

### Coordinated Disclosure

We follow **coordinated vulnerability disclosure**:

- We work with reporters to understand the issue
- We develop fixes before public disclosure
- We coordinate disclosure timing with the reporter
- We credit reporters (unless they prefer anonymity)

## 🏆 Security Researcher Recognition

### Hall of Fame

We maintain a Security Hall of Fame to recognize researchers who help us:

👉 [Security Hall of Fame](security/hall-of-fame.md)

### Attribution

If you'd like to be credited:
- Your name/handle will be listed in release notes
- Your name will be added to our Hall of Fame
- We'll link to your website/social media (if desired)

You can also choose to remain anonymous.

### Bounties

Currently, we do not offer monetary bug bounties. However:
- We provide public recognition
- We offer swag/merchandise (when available)
- We're exploring a bounty program for the future

## 🔐 Supported Versions

We provide security updates for these versions:

| Version | Supported | End of Support |
|---------|-----------|----------------|
| 1.x.x   | ✅ Yes    | TBD            |
| 0.x.x   | ❌ No     | 2026-01-01     |

### End of Life Policy

- **Major versions**: Supported for 12 months after next major release
- **Security fixes**: Backported to supported versions
- **Critical vulnerabilities**: May extend support temporarily

## 🔧 Security Best Practices

### For Deployment

If you're deploying OpenClaw, follow these security practices:

1. **Environment Variables**
   - Never commit `.env` files
   - Use strong, unique passwords
   - Rotate credentials regularly

2. **SSL/TLS**
   - Use valid SSL certificates in production
   - Enable HTTPS for all services
   - Configure proper SSL settings

3. **Network Security**
   - Use firewall rules to restrict access
   - Limit database access to internal network
   - Enable authentication on all services

4. **Access Control**
   - Use principle of least privilege
   - Implement role-based access control
   - Review access logs regularly

5. **Updates**
   - Keep all dependencies updated
   - Monitor security advisories
   - Apply security patches promptly

6. **Monitoring**
   - Enable security logging
   - Set up alerts for suspicious activity
   - Review logs regularly

### For Development

1. **Dependency Security**
   ```bash
   # Check for vulnerabilities
   pnpm audit

   # Fix vulnerabilities
   pnpm audit --fix
   ```

2. **Secret Scanning**
   - Never commit secrets to git
   - Use `.gitignore` properly
   - Review commits before pushing

3. **Code Review**
   - All changes require review
   - Security-sensitive changes need thorough review
   - Use automated security scanning

## 📋 Security Checklist

Before deploying to production:

- [ ] All default passwords changed
- [ ] SSL/TLS certificates configured
- [ ] Firewall rules in place
- [ ] Database authentication enabled
- [ ] Environment variables secured
- [ ] Security headers configured
- [ ] Logging and monitoring enabled
- [ ] Dependencies updated
- [ ] Security audit completed
- [ ] Backup strategy implemented

## 🔍 Security Audits

### Internal Audits

We perform regular security audits:
- **Code reviews** - All PRs reviewed for security
- **Dependency scanning** - Automated vulnerability checks
- **Configuration reviews** - Regular security configuration audits

### External Audits

We welcome:
- **Community security reviews**
- **Third-party penetration testing**
- **Security research**

If you're planning a security audit, please contact us first.

## 📚 Security Resources

### Documentation

- [Environment Variables Guide](setup/Configuration.md#environment-variables)
- [SSL Setup Guide](guides/SSL-Setup.md)
- [Firewall Configuration](deployment/GCE.md#firewall-setup)
- [Security Best Practices](Architecture-Overview.md#security)

### External Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [CWE Top 25](https://cwe.mitre.org/top25/)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [Node.js Security Best Practices](https://nodejs.org/en/docs/guides/security/)

## 📞 Contact

### Security Team

**Email:** security@openclaw.dev

**GPG Key:** (Coming Soon)
```
Key ID: [To be added]
Fingerprint: [To be added]
```

### PGP Key

For encrypted communications:
```
[PGP public key block to be added]
```

## 📄 License

By reporting security vulnerabilities, you agree:
- To give us reasonable time to fix the issue before disclosure
- Not to exploit the vulnerability beyond what's needed for PoC
- To follow responsible disclosure practices

---

**Thank you for helping keep OpenClaw secure!** 🛡️

Your responsible disclosure helps protect all users of the platform.

---

**Last Updated:** 2026-02-07
**Contact:** security@openclaw.dev
