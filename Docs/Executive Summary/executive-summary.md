# Executive Summary — Artisans Marketplace Security Assessment

## Project Overview
Artisans Marketplace is a full-stack e-commerce platform built for local artisans, developed as part of the Habib University Cybersecurity course. The application consists of a Flutter frontend (targeting web/Chrome), a FastAPI Python backend, and a MongoDB database, deployed via Docker Compose with an nginx TLS reverse proxy.

## Scope of Assessment
This security assessment covers the full application stack:
- **Frontend:** Flutter/Dart web application
- **Backend API:** FastAPI (Python), exposed on port 8000
- **Database:** MongoDB (port 27017)
- **Infrastructure:** Docker Compose deployment, nginx reverse proxy, GitHub Actions CI/CD pipeline

## Assessment Activities
Three classes of security testing were performed:
1. **SAST (Static Application Security Testing):** Bandit and Semgrep for Python backend; flutter analyze for the frontend. Identifies insecure code patterns without running the application.
2. **SCA (Software Composition Analysis):** pip-audit and Trivy to identify known CVEs in third-party dependencies.
3. **DAST (Dynamic Application Security Testing):** OWASP ZAP scans against the running containerized application, targeting the frontend on port 51235 and the API on port 8000.

## Key Findings Summary

| Severity | Count | Examples |
|----------|-------|---------|
| Critical | 1 | Hardcoded JWT secret in source code |
| High | 3 | No token revocation, CORS wildcard, no refresh token rotation |
| Medium | 2 | SHA-256 password hashing (now remediated), missing rate limiting |
| Low | 4 | Missing security headers, verbose error messages, no idle timeout |

## Remediation Implemented
Three phases of remediation were implemented as part of this project:
- **Phase 1:** Refresh token system — short-lived access tokens (40 min) paired with long-lived refresh tokens (7 days) stored server-side, with silent re-authentication in the Flutter client.
- **Phase 2:** Server-side session revocation — MongoDB `sessions` collection with TTL index, per-session and bulk revocation endpoints, admin force-revoke capability.
- **Phase 3:** Configuration hardening — startup enforcement of non-default secrets, CORS origin whitelist, rate limiting on the refresh endpoint (10 req/min/IP), CI/CD pipeline fixes.

## Overall Risk Rating
**Medium-High** before remediation. **Low-Medium** after remediation phases are applied.
