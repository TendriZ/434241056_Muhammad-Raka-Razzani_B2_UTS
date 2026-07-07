## Table `profiles`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `name` | `text` |  |
| `username` | `text` |  Unique |
| `role` | `text` |  Nullable |
| `created_at` | `timestamptz` |  |

## Table `tickets`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `int8` | Primary Identity |
| `user_id` | `uuid` |  |
| `title` | `text` |  |
| `description` | `text` |  |
| `category` | `text` | Default: 'hardware' |
| `priority` | `text` | Default: 'medium' |
| `status` | `text` |  Nullable |
| `assigned_to` | `uuid` |  Nullable |
| `image_url` | `text` |  Nullable |
| `created_at` | `timestamptz` |  |
| `updated_at` | `timestamptz` |  |

## Table `ticket_history`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `int8` | Primary Identity |
| `ticket_id` | `int8` |  |
| `user_id` | `uuid` |  |
| `action` | `text` |  |
| `message` | `text` |  Nullable |
| `created_at` | `timestamptz` |  |

