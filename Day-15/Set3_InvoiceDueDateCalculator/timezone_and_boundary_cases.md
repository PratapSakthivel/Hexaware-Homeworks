# Set 3: Invoice Due-Date Calculator – Timezone & Boundary Cases

## 1. Instant vs LocalDateTime vs ZonedDateTime
- **`Instant`:** An unambiguous point on the universal timeline represented as epoch seconds from `1970-01-01T00:00:00Z`. Ideal for DB timestamps.
- **`LocalDateTime`:** Date and time without timezone context (e.g. `2026-11-28 10:00`). Context-free; ambiguous across geographic zones.
- **`ZonedDateTime`:** Full ISO-8601 representation with `ZoneId` (e.g. `Asia/Kolkata`, `America/New_York`), handling daylight saving time (DST) transitions.
