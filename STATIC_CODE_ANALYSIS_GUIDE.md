# Static Code Analysis (SCA & SAST) Comprehensive Guide

## Overview

This document provides a comprehensive understanding of the static code analysis tools, methodology, and findings in the Artisans Marketplace Cybersecurity Project. The analysis focuses on both **Source Code Analysis (SAST)** and **Supply Chain Analysis (SCA)** to identify and remediate security vulnerabilities.

---

## Part 1: Tools & Technologies

### 1.1 Backend Static Analysis Tools

#### **Bandit**
- **Purpose**: Security linter for Python code to identify common security issues
- **What it checks**:
  - Hardcoded credentials/secrets
  - SQL injection vulnerabilities
  - Insecure randomness (`random` vs `secrets`)
  - File permissions issues
  - Insecure deserialization
  - Use of dangerous functions (`exec`, `eval`)
- **Command**: `bandit -r BackEnd -f json -o bandit-report.json`
- **Output**: JSON report with severity levels (HIGH, MEDIUM, LOW)

#### **Semgrep**
- **Purpose**: Static analysis tool using predefined security patterns
- **Configurations used**:
  - `p/security-audit` - General security patterns
  - `p/secrets` - Credential detection
  - `p/python` - Python-specific issues
  - `p/javascript` - JavaScript patterns
- **Command**: `semgrep --config p/security-audit --config p/secrets --config p/python --config p/javascript --json --output semgrep-report.json .`
- **Output**: JSON report with detected pattern violations

#### **pip-audit**
- **Purpose**: Dependency vulnerability scanner for Python packages
- **What it does**: Scans `requirements.txt` against known vulnerabilities in the Python Package Index (PyPI)
- **Command**: `pip-audit -r BackEnd/requirements.txt --format json > pip-audit-report.json`
- **Output**: JSON report listing vulnerable packages with CVE references

### 1.2 Frontend Static Analysis Tools

#### **Flutter Analyzer**
- **Purpose**: Dart language analyzer for Flutter applications
- **What it checks**:
  - Type safety violations
  - Unused imports and variables
  - Deprecated API usage
  - Code style issues
  - Null safety violations
- **Command**: `flutter analyze` (runs without pub updates: `flutter analyze --no-pub`)
- **Output**: Text output with file paths and issue descriptions

### 1.3 Dependency Scanning Tools

#### **Trivy**
- **Purpose**: Comprehensive vulnerability scanner for container images, filesystems, and dependencies
- **What it does**: 
  - Scans entire filesystem for known vulnerabilities
  - Detects vulnerable packages across all languages (Python, Node.js, Go, etc.)
  - Identifies misconfigurations
- **Command**: `trivy fs . --format json --output trivy-report.json`
- **Output**: JSON report with detected vulnerabilities, their severity, and fix recommendations

---

## Part 2: SCA vs SAST - Key Differences

### Source Code Analysis (SAST)
- **Focus**: Analyzes application source code for coding errors and security flaws
- **Tools in project**: Bandit, Semgrep, Flutter Analyzer
- **Examples of findings**:
  - Use of insecure functions
  - Hardcoded secrets in code
  - Type mismatches and unsafe operations
  - Unused imports/variables
  - Deprecated API usage

### Supply Chain Analysis (SCA)
- **Focus**: Identifies vulnerabilities in third-party dependencies
- **Tools in project**: pip-audit, Trivy
- **Examples of findings**:
  - Known CVEs in package versions
  - License compliance issues
  - Outdated dependency versions
- **Why it matters**: Your code may be secure, but vulnerabilities in your dependencies can be exploited

---

## Part 3: CI/CD Workflow (GitHub Actions)

### Pipeline Architecture

```
┌─────────────────────┐
│ Push to any branch  │
└──────────┬──────────┘
           │
      ┌────▼────────────────┐
      │  backend-test       │ ← Validates Python syntax
      │  (Prerequisite)     │   Compiles all .py files
      └────┬─────────┬──────┘
           │         │
      ┌────▼──┐   ┌──▼──────┐
      │ SAST  │   │   SCA   │
      │ (5m)  │   │  (5m)   │
      └────┬──┘   └──┬──────┘
           │         │
      ┌────▼─────────▼───┐
      │  Docker Build    │ ← Containerization
      │  (10m)          │   Verifies buildability
      └────┬────────────┘
           │
      ┌────▼──────────┐
      │    DAST       │ ← Dynamic security test
      │  (15-20m)     │   OWASP ZAP scanning
      └───────────────┘
```

### Detailed Workflow Steps

#### Job 1: Backend Test (Prerequisite)
```yaml
Steps:
1. Checkout code
2. Setup Python 3.12
3. Install requirements.txt
4. Compile all .py files (py_compile)
   → Catches syntax errors early
   → Validates import structure
```

#### Job 2: SAST (Parallel after backend-test)
```yaml
Steps:
1. Setup Python 3.11
2. Install requirements.txt
3. Install and run Bandit
   → Scans BackEnd/ directory
   → Outputs: bandit-report.json
4. Install and run Semgrep
   → Scans entire repository
   → Uses security/secrets/python configs
   → Outputs: semgrep-report.json
5. Setup Flutter 3.x
6. Install Flutter dependencies (pub get)
7. Run Flutter Analyzer
   → No public updates (--no-pub)
   → Analyzes Dart code in FrontEnd/lib/
8. Upload artifacts: sast-reports/
```

#### Job 3: SCA (Parallel after backend-test)
```yaml
Steps:
1. Setup Python 3.11
2. Install pip-audit
3. Run pip-audit on BackEnd/requirements.txt
   → Outputs: pip-audit-report.json
4. Run Trivy file system scan
   → Scans entire repository
   → Detects all dependency vulnerabilities
   → Outputs: trivy-report.json
5. Upload artifacts: sca-reports/
```

#### Job 4: Docker Build (After SAST & SCA pass)
```yaml
Steps:
1. Checkout code
2. docker compose build
   → Verifies Dockerfile builds successfully
   → Ensures build pipeline integrity
```

#### Job 5: DAST (After Docker succeeds)
```yaml
Steps:
1. Checkout code
2. Start containers with docker compose
3. Run OWASP ZAP scanning
   → Dynamic testing of running application
   → Tests security at runtime
```

### Artifact Storage

All reports are uploaded and can be downloaded from GitHub Actions:

```
sast-reports/
├── bandit-report.json      (Backend security issues)
├── semgrep-report.json     (Pattern-based issues)
└── flutter-analyze output

sca-reports/
├── pip-audit-report.json   (Python dependency CVEs)
└── trivy-report.json       (All filesystem CVEs)
```

---

## Part 4: Vulnerabilities Found & Fixes

### 4.1 Vulnerability #1: python-dotenv (CVE-2026-28684)

#### Finding Details
- **Package**: `python-dotenv==1.0.1`
- **Source**: `BackEnd/requirements.txt`
- **Type**: SCA - Dependency Vulnerability
- **Severity**: Medium
- **CVE**: CVE-2026-28684

#### What's the Problem?
- Arbitrary file overwrite via symbolic link attack
- Affects `set_key()` and `unset_key()` operations on `.env` files
- An attacker can create symlinks to system files and potentially overwrite them

#### Why It Matters
- Even though the code doesn't directly call `set_key()`, the dependency is installed
- If any code (including transitive dependencies) uses these functions, it's vulnerable
- Increases attack surface of the application

#### Fix Applied
```diff
requirements.txt
- python-dotenv==1.0.1
+ python-dotenv>=1.2.2
```

#### Implementation Steps
1. Update `BackEnd/requirements.txt`
2. Run: `pip install --upgrade python-dotenv`
3. Test that environment loading still works
4. Verify in `BackEnd/app/core/config.py` that Settings loads correctly

---

### 4.2 Vulnerability #2: python-jose (CVE-2024-33663 & CVE-2024-33664)

#### Finding Details
- **Package**: `python-jose[cryptography]==3.3.0`
- **Source**: `BackEnd/requirements.txt`
- **Type**: SCA - Dependency Vulnerability
- **Severity**: High
- **CVEs**: 
  - CVE-2024-33663: Algorithm confusion with OpenSSH ECDSA keys
  - CVE-2024-33664: Denial-of-service via crafted JWE tokens

#### What's the Problem?

**CVE-2024-33663**: Algorithm Confusion
- JWT library may accept ECDSA keys with different algorithms than intended
- An attacker could forge tokens by exploiting algorithm confusion
- Example: Sending RS256 token but library treats it as HS256

**CVE-2024-33664**: DoS via JWE
- Specially crafted JWE (JSON Web Encryption) tokens can crash the parser
- Can lead to service unavailability

#### Why It Matters
- `python-jose` is critical for the application:
  - Used in `BackEnd/app/core/security.py`:
    - `create_access_token()` - Creates JWT tokens
    - `create_refresh_token()` - Creates refresh tokens
    - `decode_token()` - Validates JWT tokens
    - `decode_refresh_token()` - Validates refresh tokens
  - All authentication flows depend on this library
  - A compromised token could bypass authentication

#### Fix Applied
```diff
requirements.txt
- python-jose[cryptography]==3.3.0
+ python-jose[cryptography]>=3.4.0
```

#### Implementation Steps
1. Update `BackEnd/requirements.txt`
2. Run: `pip install --upgrade python-jose`
3. Verify JWT operations still work:
   - Test login endpoint: `POST /api/v1/auth/login`
   - Test token refresh: `POST /api/v1/auth/token/refresh`
   - Verify tokens are correctly decoded in protected routes
4. No code changes needed (API remains compatible)

#### Code Locations Affected
```python
# BackEnd/app/core/security.py

# JWT creation
jwt.encode(
    {"sub": subject, "exp": expire, **extra_claims},
    settings.SECRET_KEY,
    algorithm="HS256"
)

# JWT validation
payload = jwt.decode(
    token,
    settings.SECRET_KEY,
    algorithms=["HS256"]
)
```

---

### 4.3 Vulnerability #3: python-multipart (Multiple CVEs)

#### Finding Details
- **Package**: `python-multipart==0.0.9`
- **Source**: `BackEnd/requirements.txt`
- **Type**: SCA - Dependency Vulnerability
- **Severity**: High
- **CVEs**: 
  - CVE-2024-53981: DoS via malformed boundaries
  - CVE-2026-24486: Path traversal in multipart parsing
  - CVE-2026-40347: Unbounded header parsing
  - CVE-2026-42561: Memory exhaustion attacks

#### What's the Problem?

**CVE-2024-53981**: Malformed Boundary DoS
- Parser crashes when given specially crafted multipart boundaries
- Can cause service interruption

**CVE-2026-24486**: Path Traversal
- Attacker can use `../` in uploaded file names to write outside upload directory
- Potential for overwriting application files

**CVE-2026-40347**: Header Parsing DoS
- Unlimited header sizes can exhaust memory
- Crafted requests with huge headers cause memory exhaustion

**CVE-2026-42561**: Memory Attacks
- Various memory-based attack vectors in parser

#### Why It Matters
- `python-multipart` handles file upload parsing in FastAPI
- Used by all file upload endpoints:
  - `BackEnd/app/routes/uploads.py` - `POST /uploads/image`
  - Any user can trigger multipart parsing
  - Attack doesn't require authentication
- File uploads are high-risk operations by design

#### Fix Applied
```diff
requirements.txt
- python-multipart==0.0.9
+ python-multipart>=0.0.27
```

#### Implementation Steps
1. Update `BackEnd/requirements.txt`
2. Run: `pip install --upgrade python-multipart`
3. Test file upload functionality:
   - Upload valid image: `POST /uploads/image`
   - Test upload validation (size, type)
   - Verify uploaded files are stored securely
4. Additional hardening in `BackEnd/app/routes/uploads.py`:

```python
# Current implementation already has good practices:
- Validates file suffix against ALLOWED_SUFFIXES
- Checks MAX_FILE_SIZE (20MB)
- Uses token_hex() for random filenames (prevents path traversal)
- Stores files safely: destination.write_bytes(data)
```

#### Code Location
```python
# BackEnd/app/routes/uploads.py

ALLOWED_SUFFIXES = {".jpg", ".jpeg", ".png", ".webp"}
MAX_FILE_SIZE = 5 * 2048 * 2048  # 20MB

@router.post("/image", status_code=status.HTTP_201_CREATED)
async def upload_image(file: UploadFileParam, user: CurrentUser) -> dict:
    """Upload an image and return a reference to the stored file."""
    suffix = Path(file.filename or "").suffix.lower()
    if suffix not in ALLOWED_SUFFIXES:
        raise HTTPException(...)
    
    data = await file.read()
    # Size validation
    if len(data) > MAX_FILE_SIZE:
        raise HTTPException(...)
    
    # Safe filename generation
    safe_name = f"{token_hex(16)}{suffix}"
    destination = UPLOAD_DIR / safe_name
    destination.write_bytes(data)
```

---

### 4.4 SAST Findings & Fixes

#### Code Quality Improvements (Backend)

##### Issue: Type Annotations in `BackEnd/app/services/deps.py`
- **Type**: SAST - Type Safety
- **Problem**: Missing type hints in dependency functions
- **Fix**: Added proper type annotations to all parameters and return types
  ```python
  def require_roles(*allowed_roles: str) -> Callable[[dict], dict]:
      """Dependency factory for role-based access control."""
  ```

##### Issue: Dependency Parameters in `BackEnd/app/routes/uploads.py`
- **Type**: SAST - Code Style
- **Problem**: Inconsistent FastAPI dependency declaration
- **Fix**: Converted to `Annotated` dependency pattern
  ```python
  # Before
  file: UploadFile = File(...)
  
  # After
  UploadFileParam = Annotated[UploadFile, File(...)]
  file: UploadFileParam
  ```

#### Code Quality Improvements (Frontend)

##### Issue: Unused Imports in `FrontEnd/lib/screens/app_screens.dart`
- **Type**: SAST - Unused Code
- **Problem**: Imported widgets not used in code
- **Fix**: Removed unused import statement
  ```dart
  // Removed: import 'package:flutter/material.dart'; (unused)
  ```

##### Issue: Deprecated Flutter API Usage in `FrontEnd/lib/widgets/widgets.dart`
- **Type**: SAST - Deprecated API
- **Problem**: `withOpacity()` is deprecated in newer Flutter
- **Fix**: Replaced with `withValues(alpha: ...)`
  ```dart
  // Before
  color.withOpacity(0.5)
  
  // After
  color.withValues(alpha: 0.5)
  ```

##### Issue: Type Mismatches in `FrontEnd/lib/services/auth_service.dart`
- **Type**: SAST - Type Safety
- **Problem**: `getSessions()` returned wrong type
- **Fix**: Used proper `api.getList()` with correct type mapping
  ```dart
  // Fixed to properly handle List<Session> type
  ```

##### Issue: Unused Widgets in Frontend Screens
- **Type**: SAST - Unused Code
- **Problem**: Dead code increases maintenance burden
- **Fix**: Removed unused widget classes:
  - `_StatusChip` from seller_screens.dart
  - `_SummaryCard` simplified to remove bloat
  - `_StatCard` from app_screens.dart

---

## Part 5: Execution Flow & Remediation Strategy

### How Vulnerabilities Were Identified

1. **Initial SCA Scan**
   - Ran `pip-audit` on requirements.txt
   - Ran `Trivy` filesystem scan
   - Identified 3 critical package vulnerabilities

2. **Classification**
   - Categorized by severity (High, Medium, Low)
   - Mapped to application code using them
   - Assessed exploitability and impact

3. **Documentation**
   - Created `Docs/Exploitation Report/exploitation-report.md`
   - Documented each CVE with:
     - Finding type and source
     - Risk assessment
     - Evidence (screenshot paths)
     - Manual exploitation notes
     - Remediation steps

### Remediation Process

#### Step 1: Update Dependencies
```bash
# In BackEnd/
pip install --upgrade python-dotenv>=1.2.2
pip install --upgrade "python-jose[cryptography]>=3.4.0"
pip install --upgrade python-multipart>=0.0.27
```

#### Step 2: Verify Application Functionality
```bash
# Test each affected area
pytest BackEnd/  # Run any test suite
# Manual test: Login, refresh token, upload image
```

#### Step 3: Run SAST Scanning
```bash
# Backend
ruff check BackEnd/
bandit -r BackEnd/

# Frontend
cd FrontEnd && flutter analyze --no-pub
```

#### Step 4: Run SCA Scanning
```bash
# Backend dependencies
pip-audit -r BackEnd/requirements.txt

# All filesystem vulnerabilities
trivy fs .
```

#### Step 5: Documentation
- Update `Docs/Exploitation Report/exploitation-report.md`
- Add screenshots of:
  - GitHub Actions SCA report success
  - Trivy JSON showing CVE details
  - Source code showing affected dependencies

### Ongoing Maintenance

- **Monthly**: Re-run SCA scans to detect new vulnerabilities
- **Per Release**: Run full CI pipeline before deployment
- **On Update**: When upgrading dependencies, verify no new vulnerabilities introduced
- **Monitoring**: GitHub's security alerts for this repository

---

## Part 6: Key Takeaways

### Security Analysis Layers

| Layer | Tool | Coverage | Speed |
|-------|------|----------|-------|
| **Source Code** | Bandit, Semgrep, Flutter | Application logic | ~2 min |
| **Dependencies** | pip-audit, Trivy | Package vulnerabilities | ~3 min |
| **Container** | Docker build verification | Image integrity | ~10 min |
| **Runtime** | OWASP ZAP (DAST) | Dynamic behavior | ~20 min |

### Best Practices Implemented

1. **Automated Scanning**: CI/CD runs on every push, not manual
2. **Multiple Tools**: Combining Bandit + Semgrep catches more issues
3. **Dependency Monitoring**: SCA catches supply chain attacks
4. **Clear Documentation**: Each finding links to code and remediation
5. **Evidence Collection**: Screenshots prove vulnerability and fix
6. **Zero Trust**: Even if code looks good, dependencies might not be

### Why This Matters for the Course

This project demonstrates:
- **Real-world security testing**: Not just theoretical concepts
- **Supply chain security**: Dependencies are part of your attack surface
- **CI/CD integration**: Security isn't an afterthought, it's automated
- **Vulnerability management**: Find → Document → Fix → Verify
- **Defense in depth**: Multiple scanning layers catch different issues

---

## References

- [Bandit Documentation](https://bandit.readthedocs.io/)
- [Semgrep Rules](https://semgrep.dev/explore)
- [pip-audit Documentation](https://pip-audit.readthedocs.io/)
- [Trivy Documentation](https://aquasecurity.github.io/trivy/)
- [OWASP ZAP](https://www.zaproxy.org/)
- [CVE Details](https://www.cvedetails.com/)

