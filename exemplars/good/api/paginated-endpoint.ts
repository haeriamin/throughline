// Exemplar: cursor-paginated collection endpoint (Express + TypeScript).
// Demonstrates: API-02 (pagination), API-03 (error envelope), API-04 (boundary validation),
// ENG-02 (explicit error handling), SEC-04 (explicit field selection).
import { Router, Request, Response, NextFunction } from "express";
import { z } from "zod";

const listOrdersQuery = z.object({
  cursor: z.string().min(1).optional(),
  limit: z.coerce.number().int().min(1).max(100).default(50),
});

export interface OrderSummary {
  id: string;
  status: "pending" | "shipped" | "delivered";
  totalCents: number;
  createdAt: string;
}

export interface Page<T> {
  items: T[];
  nextCursor: string | null;
}

export interface OrderReader {
  listAfter(cursor: string | null, limit: number): Promise<Page<OrderSummary>>;
}

export function ordersRouter(orders: OrderReader): Router {
  const router = Router();

  router.get("/orders", async (req: Request, res: Response, next: NextFunction) => {
    // API-04: validate at the boundary; domain code never re-parses raw input.
    const parsed = listOrdersQuery.safeParse(req.query);
    if (!parsed.success) {
      // API-03: structured error envelope; status matches semantics.
      return res.status(400).json({
        code: "INVALID_QUERY",
        message: "cursor must be a non-empty string; limit must be 1-100",
        details: parsed.error.flatten().fieldErrors,
      });
    }

    try {
      const { cursor, limit } = parsed.data;
      // API-02: bounded page with a continuation cursor — never the whole table.
      const page = await orders.listAfter(cursor ?? null, limit);
      // SEC-04: OrderSummary is an explicit DTO, not a raw entity dump.
      return res.json({ items: page.items, next_cursor: page.nextCursor });
    } catch (err) {
      // ENG-02: never swallow — propagate to the error middleware.
      return next(err);
    }
  });

  return router;
}
