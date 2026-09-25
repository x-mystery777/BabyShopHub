# Backend Handoff

The Backend Lead owns this directory.

## Foundation deliverables

- Create the Spring Boot project and build configuration.
- Configure profiles for local development and testing.
- Add a health endpoint at `GET /api/health`.
- Add the initial package structure for controllers, services, repositories, entities, DTOs, security, and configuration.
- Document API requests and responses in `docs/api/`.
- Keep secrets outside committed source files.

## Expected first package layout

```text
backend/
  src/main/java/.../
    controller/
    service/
    repository/
    entity/
    dto/
    security/
    config/
```

Do not implement product, authentication, cart, or order features in the foundation task beyond the agreed scaffolding and health check.
