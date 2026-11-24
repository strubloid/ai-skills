---
name: named-mapping-consts
description: Use when writing or reviewing a mapper that turns an API payload into a domain object — an API → domain mapper, a `to*` function, a payload-to-view-model transformer. Enforces computing every derived value into a named const above the return instead of embedding the logic in the object literal. Triggered by "move it out of the return", "const before the return", "the return is too dense", "extract that expression", "name the value", or when writing/reviewing a mapper.
---

# Name every computed value before the return

A mapper returns a domain object. Every value in that object that is
**computed** — a conditional, a conversion, a fallback chain, a call that
builds a nested object — is computed into a named `const` **above** the
`return`. The returned object then lists names, not logic.

## Why

- **The return becomes a table of contents.** The reader sees the shape of the
  domain object at a glance, in the order the domain declares it. The
  transformations live above, each with its own name.
- **A named value can be reused.** `nestedRecord.updatedAt ?? payload.updatedAt ?? 0`
  has to be re-read (and re-understood) at every use. As `quotedAt` it is
  read once.
- **A conditional inside an object literal is invisible.** Three lines of
  ternary between two properties look like part of the shape. Hoisted, they
  are a line of logic you can name, test and review.
- **It survives the next field.** When a fourth field needs the same value,
  the const is already there — the logic is not copied into the literal.

## Rule

```ts
export function toDomainRecord(payload: RecordPayload): DomainRecord {
  const nestedRecord = toNestedRecord(payload.nestedRecord);
  const updatedAt = nestedRecord.updatedAt ?? payload.updatedAt ?? 0;
  const distance =
    payload.distance === null || payload.distance === undefined
      ? null
      : String(payload.distance);

  return {
    updatedAt,
    distance,
    id: payload.id ?? 0,
    nestedRecord,
  };
}
```

Not this:

```ts
export function toDomainRecord(payload: RecordPayload): DomainRecord {
  const nestedRecord = toNestedRecord(payload.nestedRecord);

  return {
    id: payload.id ?? 0,
    updatedAt: nestedRecord.updatedAt ?? payload.updatedAt ?? 0,
    distance:
      payload.distance === null || payload.distance === undefined
        ? null
        : String(payload.distance),
    nestedRecord,
  };
}
```

## What stays inline

A **plain field read with a single default** is not a computation — it stays
in the literal, it is one token and it says exactly what it does.

```ts
return {
  id: payload.id ?? 0,
  status: payload.status ?? 0,
  comment: payload.comment ?? null,
  isDedicated: payload.isDedicated ?? true,
  nestedRecord,
};
```

Everything else gets a name:

| Computed value | Const |
|---|---|
| a conditional (`x === null ? a : b`) | `const x = ...` |
| a conversion (`String(x)`, `Number(x)`) | `const x = ...` |
| a fallback chain across two sources (`a ?? b ?? 0`) | `const x = ...` |
| a call that builds a nested object (`toWaypoint(payload.origin)`) | `const origin = ...` |
| a `.map()` that builds a list of objects | `const vehicles = ...` |

## Where the consts go

Above the `return`, in the same order as the fields they feed — so the
reader can walk the consts and the object in the same direction. The const
block ends right before the `return`.

```ts
const nestedRecord = toNestedRecord(payload.nestedRecord);
const updatedAt = nestedRecord.updatedAt ?? payload.updatedAt ?? 0;
const distance = ...;
const origin = toDomainRecord(payload.origin);

return {
  updatedAt,
  distance,
  origin,
  nestedRecord,
  ...
};
```

## When to break the rule

- The whole return is one short expression with no logic — a const block
  would be noise.
- The value is a one-word cast of a field that is already the right type
  (`payload.status ?? 0`).
- The mapper is a thin pass-through of a payload that is already the domain
  shape — then there is nothing to compute.
