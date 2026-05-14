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
 
| Severity | Count | Examples (across SAST, SCA, and DAST) |
|----------|-------|---------------------------------------|
| Critical | 1 | Hardcoded JWT secret committed in source code |
| High | 8 | No token revocation, no refresh token rotation, CORS wildcard; 4 critical CVEs in third-party libraries (python-multipart, python-jose) |
| Medium | 10 | Weak password hashing, missing rate limiting, outdated hashing algorithms (MD5, SHA-1), insecure TLS configuration, vulnerable dependency (python-dotenv), clickjacking exposure, MIME sniffing, CSP policy weaknesses |
| Low | 4 | Missing security headers, verbose error messages, no idle session timeout, hardcoded token string in code |
 

### SAST Findings: Code-Level Issues Identified
 
The automated code scans surfaced seven distinct vulnerabilities. All but two have been resolved:
 
| ID | Issue | Severity | Status |
|----|-------|----------|--------|
| V-01 | Overly permissive cross-origin access policy (CORS wildcard) | Medium | ✓ Fixed |
| V-02 | Hardcoded credential values embedded in source files | High | ✓ Fixed |
| V-03 | Missing enforcement of modern encryption protocols (TLS) | Medium | ✓ Fixed |
| V-04 | Hardcoded authentication token string in code | Low | ✓ Resolved |
| V-05 | Debug mode flag — confirmed false positive, no real risk | Critical (FP) | ✓ Resolved |
| V-06 | Use of outdated hashing algorithm (MD5) | Medium | ✓ Resolved |
| V-07 | Use of outdated hashing algorithm (SHA-1) | Medium | ✓ Resolved|
 
## Remediation Implemented
Three phases of remediation were implemented as part of this project:
- **Phase 1:** Refresh token system — short-lived access tokens (40 min) paired with long-lived refresh tokens (7 days) stored server-side, with silent re-authentication in the Flutter client.
- **Phase 2:** Server-side session revocation — MongoDB `sessions` collection with TTL index, per-session and bulk revocation endpoints, admin force-revoke capability.
- **Phase 3:** Configuration hardening — startup enforcement of non-default secrets, CORS origin whitelist, rate limiting on the refresh endpoint (10 req/min/IP), CI/CD pipeline fixes.

## Overall Risk Rating
**Medium-High** before remediation. **Low-Medium** after remediation phases are applied.
