#  Artisans Marketplace — Architecture & Trust Boundaries
---

## Trust Boundaries

The system defines two trust boundaries that enforce security isolation between external entities, internal processes, and the data layer.

### Boundary 1 — Internet (External Zone)

```
[ Client ] ──HTTPS──► [ Nginx Proxy ] ──► [ P1: Auth ] ──► Internal Zone
```

> Separates **external entities** from backend processes.

All incoming requests originating from the public internet must:

- Be encrypted over **HTTPS / TLS 1.3**
- Pass through the **Nginx reverse proxy** as the sole entry point
- Be **authenticated** before reaching any internal process
- Be **validated** — malformed or unauthorized requests are rejected at the edge

No process inside the internal zone is directly reachable from the internet.

---

### Boundary 2 — Internal (App → Data Zone)

```
[ P1 / P2 / P3 ] ──internal network──► [ MongoDB ]
```

> Separates **backend processes** from the database layer.

Rules enforced at this boundary:

- Only **authenticated service processes** (P1, P2, P3) may access the data store
- MongoDB is bound to the internal Docker bridge network — no public port exposure
- Database credentials are injected at runtime via environment variables — never hardcoded
- Each process uses a least-privilege database user scoped to its required collections

---

##  Data Flow Summary

| Flow | Process | Description |
|---|---|---|
| **Authentication** | `P1` | All entities (users, admins, services) authenticate through P1. Issues and validates JWT tokens. |
| **Business Operations** | `P2` | Orders and products are created, read, updated, and deleted via P2. Requires valid auth token from P1. |
| **File Management** | `P3` | Product images are uploaded and managed through P3. Handles multipart form data and storage routing. |
| **Data Persistence** | All (`P1`, `P2`, `P3`) | All processes interact with MongoDB across dedicated collections. Cross-process direct DB access is not permitted. |
| **Admin Control** | Admin role | Full access to auth management (P1) and business operations (P2). Granted via role claim in JWT. |

---
-

##  Architecture Diagram

``'
![Architecture Diagram](./Architecture Diagram/ArchitectureDiagram.png)
```

---

