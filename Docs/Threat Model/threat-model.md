# Security Architecture & Threat Model Report
## Artisans Marketplace — Web Application

> **Classification:** Confidential  
> **Version:** 1.0  
> **Methodology:** STRIDE 
> **Stack:** FastAPI · MongoDB · React · Nginx · Docker Compose · HTTPS

---

## Table of Contents

1. [System Definition & Architecture](#1-system-definition--architecture)
2. [Asset Identification & Security Objectives](#2-asset-identification--security-objectives)
3. [Threat Modeling (STRIDE)](#3-threat-modeling-stride)
4. [Secure Architecture Design](#4-secure-architecture-design)
5. [Risk Treatment & Residual Risk](#5-risk-treatment--residual-risk)
6. [MITRE ATT&CK Mapping](#6-mitre-attck-mapping)
7. [Security Posture Summary](#7-security-posture-summary)

---

## 1. System Definition & Architecture

### System Overview

The **Artisans Marketplace** is a containerized, multi-tier web application designed for a secure, internet-facing deployment. It uses an **Nginx Proxy** as the single entry point to manage traffic, separating the FastAPI backend from the frontend. The system is orchestrated via **Docker Compose** with **MongoDB**.
### Application Components

| Component | Technology | Role |
|---|---|---|
| **Frontend** | `nginx:alpine` (Dockerized) | Serves static Flutter assets; enforces TLS 1.3 |
| **Backend API** | FastAPI (Dockerized) | Handles business logic, request validation, routing |
| **Database** | MongoDB (Dockerized) | NoSQL persistent store; isolated on internal Docker network |
| **Secrets Management** | `.env` + `.gitignore` | Runtime environment injection; prevents credential leakage in image layers |

### Architecture Diagram

![Architecture Diagram](./Architecture Diagram/ArchitectureDiagram.png)


---

## 2. Asset Identification & Security Objectives

| Asset ID | Asset | Type | Description | Confidentiality | Integrity | Availability | Accountability |
|---|---|---|---|---|---|---|---|
| **A1** | User PII | Data | Artisan/buyer profiles in MongoDB | 🔴 Critical | 🟠 High | 🟠 High | 🔴 Critical |
| **A2** | Auth Secrets | Data | `.env` credentials & `DEFAULT_USER_PASSWORD` | 🔴 Critical | 🔴 Critical | 🟠 High | 🔴 Critical |
| **A3** | TLS Certificates | Data | `artisan.crt` and keys for HTTPS encryption | 🔴 Critical | 🔴 Critical | 🔴 Critical | 🔴 Critical |
| **A4** | Docker Images | System | Hardened alpine images for service delivery | 🟡 Medium | 🔴 Critical | 🟠 High | 🟠 High |
| **A5** | Audit Logs | Data | Record of all system and DB access events | 🟠 High | 🔴 Critical | 🟠 High | 🔴 Critical |

---

## 3. Threat Modeling (STRIDE)

### STRIDE Categories

| Symbol | Category | Description |
|---|---|---|
| **S** | Spoofing | Impersonating another user or system |
| **T** | Tampering | Unauthorized modification of data |
| **R** | Repudiation | Denying actions without audit trail |
| **I** | Information Disclosure | Exposing data to unauthorized parties |
| **D** | Denial of Service | Making the system unavailable |
| **E** | Elevation of Privilege | Gaining unauthorized access levels |

### Threat Register

| ID | Threat | STRIDE | Affected Component | Impact | Risk Level |
|---|---|---|---|---|---|
| **T1** | Secret Leakage | Information Disclosure | `.env` / Source Repository | Exposure of DB/Admin credentials | 🔴 High |
| **T2** | NoSQL Injection | Tampering | MongoDB via Backend API | Unauthorized data theft or deletion | 🔴 High |
| **T3** | MITM Attack | Spoofing | Nginx / HTTPS layer | Interception of PII via cert failure | 🔴 High |
| **T4** | Container Escape | Elevation of Privilege | Docker Engine / Host | Attacker gains host-level access | 🟠 Medium |
| **T5** | Resource DoS | Denial of Service | App Containers | Application downtime/exhaustion | 🔴 High |

### Threat Detail

#### T1 — Secret Leakage
- **Vector:** Secrets committed to version control or baked into Docker image layers
- **Impact:** Full compromise of database and admin credentials
- **Controls:** `.dockerignore` enforcement; runtime environment variable injection; no secrets in `Dockerfile` or image history

#### T2 — NoSQL Injection
- **Vector:** Unsanitized user input passed directly into MongoDB queries using `$where`, `$regex`, or operator injection
- **Impact:** Unauthorized read, modify, or delete of any collection; full data breach
- **Controls:** `pymongo` with parameterized query logic; Pydantic request validation at FastAPI layer

#### T3 — MITM Attack
- **Vector:** Expired, self-signed, or misconfigured TLS certificates; HTTP fallback without redirect
- **Impact:** Interception of authentication tokens and PII in transit
- **Controls:** Enforced TLS 1.3 at Nginx; HSTS headers; disable HTTP (port 80) or redirect to HTTPS

#### T4 — Container Escape
- **Vector:** Use of `--privileged` mode; exposed Docker socket; running as root inside container
- **Impact:** Attacker escapes container and gains full host OS access
- **Controls:** Alpine base images; non-root container users; drop unnecessary Linux capabilities; no socket mounting

#### T5 — Resource DoS
- **Vector:** Unauthenticated flood of requests to API endpoints; large payload attacks; no rate limiting
- **Impact:** Application unavailability; service degradation for all users
- **Controls:** Nginx rate limiting; Docker resource limits (`cpus`, `memory`); FastAPI body size limits

---

## 4. Secure Architecture Design

### 4.1 Identity & Access Management (IAM)

- **Environment Injection:** Secrets are managed via `.env` files and injected at container runtime, prevents secrets from persisting in image layers or being pushed to registries.
- **Default Credential Checks:** Automated startup logic ensures the system does not run with unconfigured default passwords (`DEFAULT_USER_PASSWORD` validation).
- **JWT Best Practices:**
  - Use `RS256` or `HS256` with a minimum 256-bit secret stored in environment variables
  - Set short access token expiry (15–30 minutes) with refresh token rotation
  - Reject `none` algorithm explicitly in token validation
  - Store tokens in `HttpOnly`, `Secure`, `SameSite=Strict` cookies — not `localStorage`

### 4.2 Network Segmentation

- **Private Bridge Isolation:** Internal communication is restricted to a named private Docker bridge network. MongoDB has no published host port (`ports:` section removed from `docker-compose.yml`).
- **Nginx Hardening:** The Nginx proxy is the **only** internet-facing component. Configuration enforces:
  - TLS 1.3 (disable TLS 1.0 / 1.1)
  - HSTS (`Strict-Transport-Security: max-age=31536000; includeSubDomains`)
  - Rate limiting (`limit_req_zone`)
  - Security headers: `X-Content-Type-Options`, `X-Frame-Options`, `Content-Security-Policy`

```nginx
# Recommended Nginx security headers
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-Frame-Options "DENY" always;
add_header Content-Security-Policy "default-src 'self'" always;
```

### 4.3 Data Protection

- **Encryption at Rest:** Data protected via host-level encryption (BitLocker on Windows / FileVault on macOS / LUKS on Linux) for underlying storage volumes.
- **Encryption in Transit:** All client-to-server traffic encrypted via TLS 1.3. Internal Docker network traffic should use TLS between FastAPI and MongoDB for defense-in-depth.
- **Minimalist Base Images:** All services use `alpine` base images to reduce attack surface and remove unnecessary binaries and package managers.

### 4.4 Container Hardening

```dockerfile
# Dockerfile hardening example (FastAPI service)
FROM python:3.12-slim

# Create non-root user
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

# Drop to non-root
USER appuser

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

```yaml
# docker-compose.yml resource limits
services:
  api:
    deploy:
      resources:
        limits:
          cpus: "0.5"
          memory: 512M
  mongo:
    # No ports: section — internal network only
    networks:
      - internal
```

---

## 5. Risk Treatment & Residual Risk

### Risk Treatment Plan

| Threat ID | Threat Summary | Treatment Strategy | Implementation |
|---|---|---|---|
| **T1** | Secret Leakage | **Mitigate** | `.dockerignore` + runtime environment variable injection; secret scanning in CI |
| **T2** | NoSQL Injection | **Mitigate** | `pymongo` parameterized queries; Pydantic input validation on all FastAPI endpoints |
| **T3** | MITM Attack | **Mitigate** | Enforced TLS 1.3 + HSTS at Nginx; HTTP → HTTPS redirect; valid certificate |
| **T4** | Container Escape | **Mitigate** | Alpine base images; non-root user; drop `ALL` capabilities; no `--privileged` |
| **T5** | Resource DoS | **Mitigate** | Nginx rate limiting; Docker resource limits; FastAPI max body size |

### Residual Risks

> Residual risks are accepted after controls are applied. These should be reviewed periodically.

**R1 — Host OS Vulnerability**
- If the underlying host OS is compromised, Docker isolation can be bypassed
- **Accepted with:** Host-level security monitoring, OS patch management, and access controls

**R2 — Self-Signed Certificate Trust**
- Use of `artisan.crt` requires manual client-side trust configuration
- **Accepted with:** Operational awareness; recommended to replace with a CA-signed certificate.

---

## 6. Security Posture Summary

| Domain | Control Strength | Notes |
|---|---|---|
| **Identity & Secrets Management** | 🟡 Moderate | Env-based injection is adequate; recommend Vault or AWS Secrets Manager for production |
| **Network Segmentation** | 🟢 Strong | Nginx proxy + private Docker bridge effectively isolates tiers |
| **Data Protection (PII)** | 🟢 Strong | Host-level AES-256 encryption; TLS 1.3 in transit |
| **Container Hardening** | 🟢 Strong | Alpine-based; non-root recommended; resource limits in place |
| **Logging & Audit** | 🟡 Moderate | Audit logs defined as asset (A5); implementation detail not confirmed — recommend structured logging with external persistence |
| **Rate Limiting / DoS** | 🟡 Moderate | Nginx rate limiting recommended; confirm FastAPI-level body size limits |

### Overall Risk Rating: 🟠 Medium — Controlled

> The application demonstrates a solid security baseline with strong network segmentation and data protection controls. The primary areas requiring attention before production exposure are: confirmed non-root container execution, rate limiting implementation, and replacement of the self-signed certificate with a CA-signed alternative.

---

## Implementation Checklist

| Status | Control | Priority |
|---|---|---|
| ☐ | Remove MongoDB `ports:` from `docker-compose.yml` | 🔴 Critical |
| ☐ | Run all containers as non-root user (`USER` directive in Dockerfile) | 🔴 Critical |
| ☐ | Validate `.dockerignore` excludes `.env` and all secret files | 🔴 Critical |
| ☐ | Enforce TLS 1.3 only; disable TLS 1.0/1.1 in Nginx | 🔴 Critical |
| ☐ | Add Nginx rate limiting on authentication endpoints | 🟠 High |
| ☐ | Implement Pydantic validation on all FastAPI request bodies | 🟠 High |
| ☐ | Set Docker CPU and memory resource limits | 🟠 High |
| ☐ | Add HSTS, CSP, and security headers in Nginx config | 🟠 High |
| ☐ | Configure structured logging with external log persistence | 🟡 Medium |
| ☐ | Replace self-signed cert with CA-signed certificate | 🟡 Medium |
| ☐ | Enable MongoDB authentication with least-privilege app user | 🟡 Medium |
| ☐ | Scan Docker images with `trivy` or `docker scout` | 🟢 Low |

---

*End of Report — Confidential*  
*Artisans Marketplace Security Architecture & Threat Model — v1.0*