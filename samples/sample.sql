-- Line comment
/* Block comment */

/*
 * Multi-line
 * block comment
 */

-- ============================================
-- DDL: CREATE / ALTER / DROP
-- ============================================

-- --- Create schema ---
CREATE SCHEMA IF NOT EXISTS sample_schema;

-- --- Create tables ---
CREATE TABLE users (
    id          SERIAL PRIMARY KEY,
    username    VARCHAR(50) NOT NULL UNIQUE,
    email       VARCHAR(255) NOT NULL,
    password    TEXT NOT NULL,
    age         INTEGER CHECK (age >= 0),
    salary      DECIMAL(10, 2) DEFAULT 0.00,
    is_active   BOOLEAN DEFAULT TRUE,
    role        VARCHAR(20) DEFAULT 'user',
    metadata    JSONB,
    avatar      BYTEA,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMPTZ,
    birth_date  DATE,
    login_time  TIME,
    uuid_col    UUID DEFAULT gen_random_uuid()
);

CREATE TABLE posts (
    id          BIGSERIAL PRIMARY KEY,
    user_id     INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title       VARCHAR(200) NOT NULL,
    body        TEXT,
    published   BOOLEAN DEFAULT FALSE,
    view_count  INTEGER DEFAULT 0,
    tags        TEXT[],
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE comments (
    id          SERIAL PRIMARY KEY,
    post_id     INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id     INTEGER NOT NULL REFERENCES users(id) ON DELETE SET NULL,
    body        TEXT NOT NULL,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- --- Indexes ---
CREATE INDEX idx_users_email ON users(email);
CREATE UNIQUE INDEX idx_users_username ON users(username);
CREATE INDEX idx_posts_user ON posts(user_id);
CREATE INDEX idx_posts_tags ON posts USING GIN(tags);

-- --- Views ---
CREATE VIEW active_users AS
SELECT id, username, email, created_at
FROM users
WHERE is_active = TRUE;

CREATE VIEW post_summary AS
SELECT
    p.id,
    p.title,
    u.username AS author,
    p.view_count,
    COUNT(c.id) AS comment_count
FROM posts p
LEFT JOIN users u ON p.user_id = u.id
LEFT JOIN comments c ON c.post_id = p.id
GROUP BY p.id, p.title, u.username, p.view_count;

-- --- Alter table ---
ALTER TABLE users ADD COLUMN phone VARCHAR(20);
ALTER TABLE users ALTER COLUMN email SET NOT NULL;
ALTER TABLE users DROP COLUMN IF EXISTS phone;

-- --- Drop ---
DROP INDEX IF EXISTS idx_temp;
DROP VIEW IF EXISTS temp_view;
-- DROP TABLE IF EXISTS temp_table CASCADE;

-- ============================================
-- DML: INSERT / UPDATE / DELETE
-- ============================================

-- --- Insert ---
INSERT INTO users (username, email, password, age, salary, is_active)
VALUES
    ('alice', 'alice@example.com', 'hashed_pw1', 30, 75000.00, TRUE),
    ('bob', 'bob@example.com', 'hashed_pw2', 25, 60000.00, TRUE),
    ('charlie', 'charlie@example.com', 'hashed_pw3', 35, 90000.00, FALSE);

INSERT INTO posts (user_id, title, body, published, tags)
VALUES
    (1, 'First Post', 'Hello, World!', TRUE, ARRAY['intro', 'hello']),
    (1, 'Second Post', 'More content here.', FALSE, ARRAY['draft']),
    (2, 'Bobs Post', 'Bob writes too.', TRUE, ARRAY['blog']);

INSERT INTO comments (post_id, user_id, body)
VALUES
    (1, 2, 'Great post!'),
    (1, 1, 'Thanks!'),
    (3, 1, 'Nice one, Bob.');

-- --- Update ---
UPDATE users
SET salary = salary * 1.10,
    updated_at = CURRENT_TIMESTAMP
WHERE is_active = TRUE
  AND age >= 25;

-- --- Delete ---
DELETE FROM comments
WHERE created_at < CURRENT_TIMESTAMP - INTERVAL '1 year';

-- ============================================
-- DQL: SELECT (various forms)
-- ============================================

-- --- Basic select ---
SELECT * FROM users;
SELECT DISTINCT role FROM users;
SELECT id, username, email FROM users WHERE is_active = TRUE;

-- --- Operators ---
SELECT * FROM users WHERE age BETWEEN 20 AND 40;
SELECT * FROM users WHERE username LIKE 'a%';
SELECT * FROM users WHERE username ILIKE '%LIC%';
SELECT * FROM users WHERE role IN ('admin', 'user');
SELECT * FROM users WHERE metadata IS NOT NULL;
SELECT * FROM users WHERE age >= 18 AND salary > 50000 OR role = 'admin';
SELECT * FROM users WHERE NOT is_active;

-- --- Aggregate functions ---
SELECT
    COUNT(*) AS total_users,
    AVG(age) AS avg_age,
    MIN(salary) AS min_salary,
    MAX(salary) AS max_salary,
    SUM(salary) AS total_salary
FROM users
WHERE is_active = TRUE;

-- --- GROUP BY / HAVING ---
SELECT
    role,
    COUNT(*) AS user_count,
    AVG(salary) AS avg_salary
FROM users
GROUP BY role
HAVING COUNT(*) > 1
ORDER BY avg_salary DESC;

-- --- ORDER BY / LIMIT / OFFSET ---
SELECT * FROM users
ORDER BY created_at DESC NULLS LAST
LIMIT 10
OFFSET 20;

-- --- FETCH (SQL standard) ---
SELECT * FROM users
ORDER BY id
FETCH FIRST 5 ROWS ONLY;

-- --- JOINs ---
SELECT u.username, p.title, p.created_at
FROM users u
INNER JOIN posts p ON u.id = p.user_id
WHERE p.published = TRUE;

SELECT u.username, p.title
FROM users u
LEFT JOIN posts p ON u.id = p.user_id;

SELECT u.username, p.title
FROM users u
RIGHT JOIN posts p ON u.id = p.user_id;

SELECT u.username, p.title
FROM users u
FULL OUTER JOIN posts p ON u.id = p.user_id;

SELECT u1.username, u2.username
FROM users u1
CROSS JOIN users u2
WHERE u1.id < u2.id;

-- --- Subqueries ---
SELECT * FROM users
WHERE id IN (
    SELECT DISTINCT user_id FROM posts WHERE published = TRUE
);

SELECT u.*, (
    SELECT COUNT(*) FROM posts p WHERE p.user_id = u.id
) AS post_count
FROM users u;

-- --- CTE (Common Table Expressions) ---
WITH active_posters AS (
    SELECT user_id, COUNT(*) AS post_count
    FROM posts
    WHERE published = TRUE
    GROUP BY user_id
),
ranked AS (
    SELECT
        u.username,
        ap.post_count,
        RANK() OVER (ORDER BY ap.post_count DESC) AS rank
    FROM users u
    JOIN active_posters ap ON u.id = ap.user_id
)
SELECT * FROM ranked WHERE rank <= 3;

-- --- Recursive CTE ---
WITH RECURSIVE fibonacci(n, a, b) AS (
    VALUES (1, 0, 1)
    UNION ALL
    SELECT n + 1, b, a + b
    FROM fibonacci
    WHERE n < 10
)
SELECT n, a AS fib FROM fibonacci;

-- --- Set operations ---
SELECT username FROM users WHERE role = 'admin'
UNION
SELECT username FROM users WHERE age > 30;

SELECT id FROM users
INTERSECT
SELECT user_id FROM posts;

SELECT id FROM users
EXCEPT
SELECT user_id FROM comments;

-- --- CASE expression ---
SELECT
    username,
    CASE
        WHEN age < 18 THEN 'minor'
        WHEN age BETWEEN 18 AND 65 THEN 'adult'
        ELSE 'senior'
    END AS age_group,
    CASE role
        WHEN 'admin' THEN 'Administrator'
        WHEN 'user' THEN 'Regular User'
        ELSE 'Unknown'
    END AS role_label
FROM users;

-- --- Window functions ---
SELECT
    username,
    salary,
    AVG(salary) OVER () AS avg_salary,
    salary - AVG(salary) OVER () AS diff_from_avg,
    ROW_NUMBER() OVER (ORDER BY salary DESC) AS salary_rank,
    LAG(salary) OVER (ORDER BY salary) AS prev_salary,
    LEAD(salary) OVER (ORDER BY salary) AS next_salary
FROM users;

-- --- String functions ---
SELECT
    UPPER(username) AS upper_name,
    LOWER(email) AS lower_email,
    LENGTH(username) AS name_length,
    CONCAT(username, ' <', email, '>') AS display
FROM users;

-- ============================================
-- Functions / Procedures
-- ============================================

-- --- Function ---
CREATE OR REPLACE FUNCTION calculate_bonus(
    base_salary DECIMAL,
    performance_rating INTEGER
)
RETURNS DECIMAL
LANGUAGE SQL
IMMUTABLE
AS $$
    SELECT base_salary * (performance_rating / 10.0);
$$;

-- --- Procedure ---
CREATE OR REPLACE PROCEDURE deactivate_user(
    target_user_id INTEGER
)
LANGUAGE SQL
AS $$
    UPDATE users SET is_active = FALSE WHERE id = target_user_id;
$$;

-- --- Trigger ---
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER
LANGUAGE SQL
AS $$
    SELECT NEW.updated_at = CURRENT_TIMESTAMP;
$$;

CREATE TRIGGER users_update_timestamp
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_timestamp();

-- ============================================
-- Transactions
-- ============================================

BEGIN;
    UPDATE users SET salary = salary + 5000 WHERE username = 'alice';
    INSERT INTO posts (user_id, title, body) VALUES (1, 'Raise!', 'Got a raise!');
COMMIT;

-- ROLLBACK example
BEGIN;
    DELETE FROM users WHERE username = 'charlie';
ROLLBACK;

-- ============================================
-- Privileges
-- ============================================

GRANT SELECT, INSERT ON users TO readonly_role;
REVOKE DELETE ON users FROM readonly_role;

-- ============================================
-- Function calls
-- ============================================
SELECT
    NOW(),
    CURRENT_DATE,
    COALESCE(NULL, 'fallback'),
    NULLIF(1, 1),
    GREATEST(1, 2, 3),
    LEAST(1, 2, 3),
    ABS(-42),
    ROUND(3.14159, 2),
    CEIL(3.14),
    FLOOR(3.99);
