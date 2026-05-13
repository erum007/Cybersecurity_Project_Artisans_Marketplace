# Remediation Report

## Overview

This report documents the Software Composition Analysis (SCA) findings for the backend and frontend dependency state, the vulnerabilities discovered, and the applied remediation branches.

- Backend SCA tool: `safety 3.7.0`
- Backend scan target: `BackEnd/requirements.txt`
- Frontend dependency status: `flutter pub outdated`
- Report artifacts:
  - `Docs/Remediation Report/safety-output-multipart.txt`
  - `Docs/Remediation Report/safety-output-jose.txt`
  - `Docs/Remediation Report/flutter-outdated.txt`

## Workflow Validation

The backend workflow was validated manually by installing backend dependencies and compiling Python source files:

```bash
cd BackEnd
python3 -m pip install --user -r requirements.txt
find app -name '*.py' | sort | xargs python3 -m py_compile
```

During validation, a merge conflict marker was discovered in `BackEnd/app/core/config.py` and corrected prior to fixing the SCA issues.

## Vulnerabilities Found

| Issue | Package | CVE | Estimated Severity | CVSS Mapping | Branch | Fix |
|---|---|---|---|---|---|---|
| Path traversal in multipart upload handling | `python-multipart` | CVE-2026-24486 | High | 8.8 | `fix/sca-python-multipart` | Updated `python-multipart==0.0.28` |
| Denial of service via malformed multipart boundaries | `python-multipart` | CVE-2024-53981 | High | 7.5 | `fix/sca-python-multipart` | Updated `python-multipart==0.0.28` |
| JWT JWE decoding DoS via high-compression token | `python-jose` | CVE-2024-33664 | High | 7.5 | `fix/sca-python-jose` | Updated `python-jose[cryptography]==3.5.0` |
| JWT algorithm confusion / key parsing issue | `python-jose` | CVE-2024-33663 | High | 8.8 | `fix/sca-python-jose` | Updated `python-jose[cryptography]==3.5.0` |

> Note: CVSS scores are estimated based on vulnerability type and attack surface. The scanner output files contain the detected advisories and full metadata.

## Fix Branches

1. `fix/sca-python-multipart`
   - Updated `BackEnd/requirements.txt` from `python-multipart==0.0.9` to `python-multipart==0.0.28`.
   - Confirmed the `python-multipart` advisories were no longer reported by the backend SCA scan.

2. `fix/sca-python-jose`
   - Updated `BackEnd/requirements.txt` from `python-jose[cryptography]==3.3.0` to `python-jose[cryptography]==3.5.0`.
   - Confirmed the `python-jose` advisories were no longer reported by the backend SCA scan.

## Frontend Dependency Status

The frontend dependency audit was performed using `flutter pub outdated`.
The following direct or transitive packages were detected as having newer available versions; this represents a maintenance and potential security risk vector.

- `fl_chart`: 0.68.0 → 1.2.0
- `flutter_lints`: 3.0.2 → 6.0.0
- `go_router`: 13.2.5 → 17.2.3
- `image_picker`: 1.2.1 → 1.2.2
- `image_picker_android`: 0.8.13+16 → 0.8.13+17
- `image_picker_ios`: 0.8.13+3 → 0.8.13+6
- `lints`: 3.0.0 → 6.1.0
- `matcher`: 0.12.17 → 0.12.20
- `material_color_utilities`: 0.11.1 → 0.13.0
- `meta`: 1.16.0 → 1.18.2
- `mime`: 1.0.6 → 2.0.0
- `path_provider_android`: 2.2.23 → 2.3.1
- `path_provider_foundation`: 2.5.1 → 2.6.0
- `smooth_page_indicator`: 1.2.1 → 2.0.1
- `sqflite`: 2.4.2 → 2.4.2+1
- `sqflite_android`: 2.4.2+2 → 2.4.2+3
- `sqflite_common`: 2.5.6 → 2.5.7
- `synchronized`: 3.4.0 → 3.4.0+1
- `test_api`: 0.7.6 → 0.7.12
- `vector_math`: 2.2.0 → 2.3.0
- `vm_service`: 15.0.2 → 15.2.0

The frontend outdated package report is available at `Docs/Remediation Report/flutter-outdated.txt`.

## Screenshots and Evidence

The actual scanner outputs were saved as text artifacts in the remediation report directory. These can be converted to screenshots or attached as evidence for the final report.

- `Docs/Remediation Report/safety-output-multipart.txt`
- `Docs/Remediation Report/safety-output-jose.txt`
- `Docs/Remediation Report/flutter-outdated.txt`

