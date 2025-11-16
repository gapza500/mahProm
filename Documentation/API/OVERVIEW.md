# PetReady API Overview (Phase 1)

Base URL: `https://api.petready.app/v1`

| Area | Endpoint | Method | Notes |
| --- | --- | --- | --- |
| Auth | `/auth/login` | POST | Phone + OTP login returning token + user payload. |
| Auth | `/auth/otp` | POST | OTP verification stub used for multi-step auth. |
| Pets | `/pets` | GET/POST | Owner pet list + create. |
| Clinics | `/clinics` | GET | Radius search for clinics/campaigns. |
| Chat | `/chat/conversations` | GET | Fetch conversation queue. |
| Transport | `/transport/jobs` | GET/POST | Rider assignments + job creation. |
| Admin | `/admin/announcements` | GET/POST | Central admin announcements. |
| SOS | `/sos` | POST | Emergency case creation (future wave). |

All requests require `Authorization: Bearer <token>` except auth routes.
