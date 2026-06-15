"""Reference pattern: a pure operation that validates each input against an explicit
spec rule *before* computing, raising ValueError on every rejected input rather than
coercing or silently proceeding. Returns a new value and never mutates its arguments.

This is the Python counterpart to the TypeScript exemplars: it shows the negative-space
discipline (TST-07) — one guard per "must reject" rule — and explicit error propagation
(ENG-02), which is exactly where one-shot code most often slips.
"""
from typing import Mapping


def reserve_stock(stock: Mapping[str, int], item_id: str, qty: int) -> dict:
    """Return a NEW stock map with ``qty`` units of ``item_id`` reserved (subtracted).

    Rules, each enforced explicitly and tested one-for-one:
      * R1 — ``qty`` must be a positive integer (reject 0, negatives, non-int, bool).
      * R2 — ``item_id`` must exist in ``stock``.
      * R3 — ``qty`` must not exceed the item's available stock (no oversell).
      * R4 — the input ``stock`` is never mutated; a new dict is returned.

    Raises:
        ValueError: when R1, R2, or R3 is violated, with a message naming the rule.
    """
    # bool is a subclass of int, so screen it out before the positivity check (R1).
    if not isinstance(qty, int) or isinstance(qty, bool) or qty <= 0:
        raise ValueError("qty must be a positive integer")
    if item_id not in stock:
        raise ValueError(f"unknown item: {item_id!r}")

    available = stock[item_id]
    if qty > available:  # R3: reject rather than allow a negative balance.
        raise ValueError("qty exceeds available stock")

    new_stock = dict(stock)  # R4: copy first; the caller's map is left untouched.
    new_stock[item_id] = available - qty
    return new_stock
