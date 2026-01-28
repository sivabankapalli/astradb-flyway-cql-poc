CREATE TABLE IF NOT EXISTS customer2 (
  customer_id text PRIMARY KEY,
  full_name text,
  email text,
  created_at timestamp
);

CREATE TABLE IF NOT EXISTS customer_by_email (
  email text PRIMARY KEY,
  customer_id text,
  full_name text
);
