# Database schema — Supabase (PostgreSQL)

Authentication uses **Supabase Auth** with **email/password only** (`auth.users` is managed by Supabase; app tables reference `auth.users.id`).

## Entity-Relationship Diagram

```mermaid
erDiagram
    AUTH_USERS {
        uuid id PK "Supabase-managed PK"
    }

    PROFILES {
        uuid id PK_FK "FK → auth.users.id"
        text full_name "nullable"
        timestamptz created_at "NOT NULL, default now()"
        timestamptz updated_at "NOT NULL, default now()"
    }

    PRODUCTS {
        uuid id PK "gen_random_uuid()"
        uuid user_id FK "FK → auth.users.id"
        text name "NOT NULL, trimmed non-empty"
        jsonb features "NOT NULL, object or array"
        text description "nullable"
        text seo_title "nullable"
        jsonb bullet_points "NOT NULL, JSON array"
        text meta_description "nullable"
        boolean is_published "NOT NULL, default true"
        timestamptz created_at "NOT NULL, default now()"
        timestamptz updated_at "NOT NULL, default now()"
    }

    AUTH_USERS ||--|| PROFILES : "1:1 (profile per user)"
    AUTH_USERS ||--o{ PRODUCTS : "1:N (products per user)"
```

### Relationship summary

| Relationship | Cardinality | FK |
|--------------|-------------|-----|
| `auth.users` → `profiles` | **1 : 1** | `profiles.id` → `auth.users.id` |
| `auth.users` → `products` | **1 : N** | `products.user_id` → `auth.users.id` |

### Critical indexes (performance)

| Index | Table | Columns / type | Purpose |
|-------|---------|------------------|---------|
| PK | `profiles` | `id` (B-tree) | Joins and lookups by user |
| PK | `products` | `id` (B-tree) | Detail `GET /products/:id` |
| `idx_products_user_id` | `products` | `user_id` (B-tree) | FK joins, owner-scoped queries |
| `idx_products_user_created_at` | `products` | `(user_id, created_at DESC)` | Admin list newest-first |
| `idx_products_created_at` | `products` | `created_at DESC` | Global recency (if used) |
| `idx_products_published_created_at` | `products` | `(is_published, created_at DESC)` partial `WHERE is_published` | Public catalog listings |
| `idx_products_features_gin` | `products` | `features` (GIN) | JSON containment / optional filter on attributes (e.g. material) |

### Notes

- **`features`**: Store structured attributes (e.g. material, use cases) as JSON **object** or **array**; optional filtering can target keys via expression indexes later if needed.
- **`bullet_points`**: JSON **array** of strings (PRD: 3–5 highlights).
- **RLS**: Owners have full CRUD on their rows; **SELECT** on `products` also allows reading rows with `is_published = true` so anonymous storefront traffic can list/view published catalog entries without `auth.uid()` (aligns with PRD public product browsing). Drafts stay private to the owner.
