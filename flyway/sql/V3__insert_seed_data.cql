INSERT INTO customer2 (customer_id, full_name, email, created_at, phone)
VALUES ('cust-001', 'Siva Bankapalli', 'siva@example.com', toTimestamp(now()), '+64-000-0000');

INSERT INTO customer_by_email (email, customer_id, full_name)
VALUES ('siva@example.com', 'cust-001', 'Siva Bankapalli');