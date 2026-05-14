# Artisans Marketplace: Comprehensive Security Assessment & Remediation Report

## 1. Executive Summary

### Project Overview

Artisans Marketplace is a full-stack e-commerce platform built for local artisans, developed as part of the Habib University Cybersecurity course. The application consists of a Flutter frontend (targeting web/Chrome), a FastAPI Python backend, and a MongoDB database, deployed via Docker Compose with an nginx TLS reverse proxy.

### Scope of Assessment

This security assessment covers the full application stack:

- **Frontend:** Flutter/Dart web application
- **Backend API:** FastAPI (Python), exposed on port 8000
- **Database:** MongoDB (port 27017)
- **Infrastructure:** Docker Compose deployment, nginx reverse proxy, GitHub Actions CI/CD pipeline

### Assessment Activities

Three classes of security testing were performed:

1. **SAST (Static Application Security Testing):** Bandit and Semgrep for the Python backend; `flutter analyze` for the frontend. This identifies insecure code patterns without running the application.
2. **SCA (Software Composition Analysis):** `pip-audit`, `safety`, and `Trivy` to identify known CVEs in third-party dependencies.
3. **DAST (Dynamic Application Security Testing):** OWASP ZAP scans against the running containerized application, targeting the frontend on port 51235 and the API on port 8000.

### Overall Risk Rating

- **Before Remediation:** Medium-High
- **After Remediation:** Low-Medium

---

## 2. Key Findings & Vulnerability Summary

The initial assessment identified several critical and high-severity issues across the stack.

| Severity | Count | Examples |
|----------|-------|---------|
| **Critical** | 1 | Hardcoded JWT secret in source code |
| **High** | 3 | No token revocation, CORS wildcard, no refresh token rotation |
| **Medium** | 2 | SHA-256 password hashing (remediated), missing rate limiting |
| **Low** | 4 | Missing security headers, verbose error messages, no idle timeout |

---

## 3. Static Application Security Testing (SAST)

### 3.1 Overview and Methodology

Our DevSecOps pipeline integrates Semgrep and Bandit to automate detection. The pipeline serves as a Quality Gate; any commit introducing a High or Critical vulnerability automatically fails the CI/CD build.

### 3.2 Summary of Findings

The initial automated scan on May 12, 2026, identified vulnerabilities across two scan rounds.

**First-Pass & Second-Pass Findings Table**

| ID | Vulnerability | OWASP 2021 Category | Severity | Status |
|----|---------------|---------------------|----------|--------|
| V-01 | Wildcard CORS Policy | A05: Security Misconfiguration | Medium | ✓ Fixed |
| V-02 | Hardcoded Bcrypt Hashes | A07: Identification & Auth Failures | High | ✓ Fixed |
| V-03 | Missing SSL Protocols (TLS) | A02: Cryptographic Failures | Medium | ✓ Fixed |
| V-04 | Hardcoded Password String ('bearer') | A07: Identification & Auth Failures | Low | ✓ Resolved |
| V-05 | Flask Debug Mode Enabled (False Positive) | A05: Security Misconfiguration | Critical | ✓ Resolved |
| V-06 | Use of Insecure MD5 Hash | A02: Cryptographic Failures | Medium | Open |
| V-07 | Use of Insecure SHA-1 Hash | A02: Cryptographic Failures | Medium | Open |

### 3.3 Detailed SAST Remediation Highlights

- **V-01 (CORS Wildcard):** Transitioned from a wildcard `*` to a whitelist approach, permitting only the specific frontend domain.
- **V-02 (Hardcoded Credentials):** Removed static bcrypt hashes from `users.json`. The app now uses environment variables to seed the database securely.
- **V-03 (TLS Hardening):** Updated `nginx.conf` to explicitly require TLSv1.2 and TLSv1.3, disabling legacy protocols like TLSv1.0.
- **V-05 (FastAPI Debug Hardening):** Although the Flask finding was a false positive, `main.py` was updated to programmatically disable `/docs` and `/redoc` in production.

---

## 4. Software Composition Analysis (SCA)

**SCA Tool:** `safety 3.7.0`
**Scan Target:** `BackEnd/requirements.txt`
**Report Artifacts:**
- `Docs/Remediation Report/safety-output-multipart.txt`
- `Docs/Remediation Report/safety-output-jose.txt`
- `Docs/Remediation Report/flutter-outdated.txt`

### 4.1 Workflow Validation

The backend workflow was validated manually by installing backend dependencies and compiling Python source files:

```bash
cd BackEnd
python3 -m pip install --user -r requirements.txt
find app -name '*.py' | sort | xargs python3 -m py_compile
```

During validation, a merge conflict marker was discovered in `BackEnd/app/core/config.py` and corrected prior to fixing the SCA issues.

### 4.2 Dependency Vulnerabilities (Backend)

Scans via `Trivy` and `safety` identified critical vulnerabilities in third-party packages.

| Issue | Package | CVE | Estimated Severity | CVSS | Branch | Fix |
|-------|---------|-----|--------------------|------|--------|-----|
| Path traversal in multipart upload handling | `python-multipart` | CVE-2026-24486 | High | 8.8 | `fix/sca-python-multipart` | Updated to `==0.0.28` |
| DoS via malformed multipart boundaries | `python-multipart` | CVE-2024-53981 | High | 7.5 | `fix/sca-python-multipart` | Updated to `==0.0.28` |
| JWT JWE decoding DoS via high-compression token | `python-jose` | CVE-2024-33664 | High | 7.5 | `fix/sca-python-jose` | Updated to `==3.5.0` |
| JWT algorithm confusion / key parsing issue | `python-jose` | CVE-2024-33663 | High | 8.8 | `fix/sca-python-jose` | Updated to `==3.5.0` |
| Arbitrary file overwrite via symbolic links | `python-dotenv` | CVE-2026-28684 | Medium | — | — | Upgrade to `>=1.2.2` |

> Note: CVSS scores are estimated based on vulnerability type and attack surface. Scanner output files contain the detected advisories and full metadata.

### 4.3 Fix Branches

**`fix/sca-python-multipart`**
- Updated `BackEnd/requirements.txt` from `python-multipart==0.0.9` to `python-multipart==0.0.28`.
- Confirmed the `python-multipart` advisories were no longer reported by the backend SCA scan.

**`fix/sca-python-jose`**
- Updated `BackEnd/requirements.txt` from `python-jose[cryptography]==3.3.0` to `python-jose[cryptography]==3.5.0`.
- Confirmed the `python-jose` advisories were no longer reported by the backend SCA scan.

### 4.4 Frontend Dependency Status

An audit using `flutter pub outdated` identified several packages requiring updates to mitigate potential security risk vectors. The following direct or transitive packages were detected as having newer available versions:

| Package | Current | Latest |
|---------|---------|--------|
| `fl_chart` | 0.68.0 | 1.2.0 |
| `flutter_lints` | 3.0.2 | 6.0.0 |
| `go_router` | 13.2.5 | 17.2.3 |
| `image_picker` | 1.2.1 | 1.2.2 |
| `image_picker_android` | 0.8.13+16 | 0.8.13+17 |
| `image_picker_ios` | 0.8.13+3 | 0.8.13+6 |
| `lints` | 3.0.0 | 6.1.0 |
| `matcher` | 0.12.17 | 0.12.20 |
| `material_color_utilities` | 0.11.1 | 0.13.0 |
| `meta` | 1.16.0 | 1.18.2 |
| `mime` | 1.0.6 | 2.0.0 |
| `path_provider_android` | 2.2.23 | 2.3.1 |
| `path_provider_foundation` | 2.5.1 | 2.6.0 |
| `smooth_page_indicator` | 1.2.1 | 2.0.1 |
| `sqflite` | 2.4.2 | 2.4.2+1 |
| `sqflite_android` | 2.4.2+2 | 2.4.2+3 |
| `sqflite_common` | 2.5.6 | 2.5.7 |
| `synchronized` | 3.4.0 | 3.4.0+1 |
| `test_api` | 0.7.6 | 0.7.12 |
| `vector_math` | 2.2.0 | 2.3.0 |
| `vm_service` | 15.0.2 | 15.2.0 |

The full frontend outdated package report is available at `Docs/Remediation Report/flutter-outdated.txt`.

### 4.5 Screenshots & Evidence
 
The actual scanner outputs were saved as text artifacts in the remediation report directory and can be attached as evidence for the final report.
 
- `Docs/Remediation Report/safety-output-multipart.txt`
- `Docs/Remediation Report/safety-output-jose.txt`
- `Docs/Remediation Report/flutter-outdated.txt`
---

## 5. Dynamic Application Security Testing (DAST) & Exploitation

### 5.1 OWASP ZAP Findings

The DAST phase identified vulnerabilities active in the running environment prior to hardening.

- **Clickjacking (X-Frame-Options):** Missing headers allowed the site to be loaded in an invisible iframe.
- **MIME-Sniffing:** Missing `X-Content-Type-Options: nosniff` header, risking XSS if a script is disguised as an image.
- **CSP Weaknesses (CVSS 7.4 - 8.1):**
  - `script-src` included `unsafe-eval` and `unsafe-inline`.
  - Wildcard directives allowed broad sources (`https:`, `blob:`), increasing risk if external CDNs are compromised.

### 5.2 Possible Impact Summary

- Cross-Site Scripting (XSS) and Session Hijacking
- UI Redressing (Clickjacking) and Phishing Overlays
- Token Theft and Data Exfiltration

### 5.3 nginx Hardening (ZAP-Driven Remediation)

The nginx reverse proxy was hardened to enforce modern security standards. The following table maps identified risks to their specific technical fixes.

| Vulnerability | Remediation Action | nginx Implementation |
|--------------|-------------------|----------------------|
| **Weak Encryption** | Disabled TLS 1.0/1.1; enforced strong ciphers | `ssl_protocols TLSv1.2 TLSv1.3;` |
| **Clickjacking** | Restricted framing to same origin | `add_header X-Frame-Options "SAMEORIGIN";` |
| **MIME Sniffing** | Disabled browser content-type guessing | `add_header X-Content-Type-Options "nosniff";` |
| **MitM / Hijacking** | Enforced HSTS (Strict HTTPS) | `add_header Strict-Transport-Security ... always;` |
| **Information Leak** | Disabled nginx version signatures | `server_tokens off;` |
| **CORS Conflict** | Unified headers via proxy_hide_header | `proxy_hide_header 'Access-Control-Allow-Origin';` |

**Security Headers Applied**

```nginx
add_header X-Content-Type-Options "nosniff" always;
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Permissions-Policy "camera=(), microphone=(), geolocation=()" always;
```

**Cross-Origin Hardening**

```nginx
add_header Cross-Origin-Opener-Policy "same-origin" always;
add_header Cross-Origin-Embedder-Policy "require-corp" always;
add_header Cross-Origin-Resource-Policy "same-origin" always;
```

**Content Security Policy (Final)**

```nginx
add_header Content-Security-Policy "
  default-src 'self';
  script-src 'self' 'unsafe-inline' 'unsafe-eval' 'wasm-unsafe-eval' https://www.gstatic.com https://unpkg.com blob:;
  style-src 'self' 'unsafe-inline' https://fonts.googleapis.com;
  connect-src 'self' https: wss:;
  img-src 'self' data: https: blob:;
  object-src 'none';
  base-uri 'self';
  frame-ancestors 'self';
" always;
```

**Cache Control**

```nginx
add_header Cache-Control "no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0" always;
```
> **Note:** Initial fixes were too aggressive and prevented the app from functioning correctly. The final configuration above was determined after thorough testing to balance security and functionality.
 
**Evidence — Aggressive Fixes (caused blank screen):**
![Aggressive Fixes](../Remediation%20Report/Aggressive_Fixes.png)
 
**Evidence — Accepted Risks (final working state):**
![Accepted Risks](../Remediation%20Report/Accepted_Risks.png)
 

### 5.4 Residual Risk Justification (Accepted Risks)

Some Medium risks remained after hardening. These are necessary for the Flutter Web framework to function and have been mitigated as much as possible.

**`unsafe-inline` and `unsafe-eval` in CSP**
Flutter's CanvasKit (WebAssembly) engine requires these directives for high-performance rendering. Blocking them results in a blank screen error. Mitigation: `script-src` is limited to trusted domains (`'self'`, `gstatic.com`, `unpkg.com`) and `blob:` sources only.

**Wildcard and Blob Directives**
Flutter uses Web Workers and Blobs for background image processing. Mitigation: directives are scoped specifically to `blob:` and the internal backend address (`http://127.0.0.1:8000`) rather than a global `*`.

**`style-src unsafe-inline`**
Flutter generates dynamic CSS styles to position UI elements. This is a standard requirement for SPA frameworks like Flutter and React, and no alternative exists without breaking the UI.

### 5.5 Benefits of nginx Hardening

- Prevents sensitive data caching
- Reduces data leakage risk
- Clickjacking and MIME sniffing protection
- Browser API restrictions via Permissions-Policy
- Prevents cross-origin data leaks
- Isolates browser context via COOP/COEP/CORP headers

---

## 6. Remediation Implementation

Three primary phases of remediation were implemented to harden the application:

- **Phase 1: Refresh Token System:** Implemented short-lived access tokens (40 min) and long-lived refresh tokens (7 days) with silent re-authentication.
- **Phase 2: Session Revocation:** Created a MongoDB `sessions` collection with TTL indexes, allowing for per-session and bulk admin revocation.
- **Phase 3: Configuration Hardening:** Enforced non-default secrets at startup, whitelisted CORS origins, and applied rate limiting (10 req/min/IP) to the refresh endpoint.

---

## 7. Conclusion

The integration of SAST, SCA, and DAST into the development cycle allowed the team to address root causes before production. While Medium-severity findings (MD5 and SHA-1 usage) remain open, they have clear remediation paths for the next sprint and do not block the current Quality Gate. The application has transitioned from a **Medium-High** risk profile to a **Low-Medium** baseline.
