// ANTI-PATTERN: "god service" — one class owning validation, persistence, formatting,
// transport, and secrets. Each numbered comment marks a standards violation.
// Curated as a cautionary specimen; never use as an implementation basis.
import { createPool } from "mysql2/promise";

export class UserService {
  // (1) SEC-01: literal credentials in source.
  private pool = createPool({ host: "db", user: "root", password: "hunter2" });

  // (2) ENG-01: validation + persistence + formatting + email in one unit.
  async handle(action: string, payload: any): Promise<string> {
    if (action === "create") {
      // (3) API-04 violated upstream: raw payload reaches domain logic unvalidated.
      // (4) SEC-02: string-concatenated SQL with external input.
      await this.pool.query(
        `INSERT INTO users (name, email) VALUES ('${payload.name}', '${payload.email}')`
      );
      // (5) ENG-02: swallowed failure — caller can't distinguish success from error.
      try {
        await this.sendWelcomeEmail(payload.email);
      } catch (e) {}
      return "<div>created!</div>"; // (6) ENG-01 again: HTML rendering inside a service.
    }
    if (action === "list") {
      // (7) API-02: unbounded read — returns every row.
      const [rows] = await this.pool.query("SELECT * FROM users");
      // (8) SEC-04: raw entity dump, password hashes and all.
      return JSON.stringify(rows);
    }
    return "unknown"; // (9) API-03: stringly-typed quasi-error instead of an envelope.
  }

  private async sendWelcomeEmail(_to: string): Promise<void> {
    /* ... */
  }
}
