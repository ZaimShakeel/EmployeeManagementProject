
-- =========================================================
-- Company Z - Employee Management System (EMS)
-- MySQL 8.0+ schema, views, procedures, and sample queries
-- =========================================================

-- Safety: create a dedicated database
DROP DATABASE IF EXISTS companyz_ems;
CREATE DATABASE companyz_ems CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE companyz_ems;

-- ---------- Core reference tables ----------
CREATE TABLE divisions (
  division_id      INT AUTO_INCREMENT PRIMARY KEY,
  name             VARCHAR(120) NOT NULL UNIQUE,
  created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE job_titles (
  job_title_id     INT AUTO_INCREMENT PRIMARY KEY,
  title            VARCHAR(120) NOT NULL UNIQUE,
  pay_grade        VARCHAR(20) NULL,
  created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ---------- Users / Auth ----------
-- App-level auth is recommended (OIDC/JWT). These tables can back RBAC/audit if DB-auth is desired.
CREATE TABLE users (
  user_id          INT AUTO_INCREMENT PRIMARY KEY,
  username         VARCHAR(120) NOT NULL UNIQUE,
  email            VARCHAR(255) NOT NULL UNIQUE,
  password_hash    CHAR(97) NULL,      -- e.g., Argon2id encoded hash (length varies by encoder)
  mfa_secret       VARBINARY(128) NULL, -- TOTP secret (encrypt at rest if used)
  is_active        TINYINT(1) NOT NULL DEFAULT 1,
  created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_login_at    TIMESTAMP NULL
) ENGINE=InnoDB;

CREATE TABLE roles (
  role_id          INT AUTO_INCREMENT PRIMARY KEY,
  name             VARCHAR(64) NOT NULL UNIQUE  -- 'HR_ADMIN', 'EMPLOYEE'
) ENGINE=InnoDB;

CREATE TABLE user_roles (
  user_id          INT NOT NULL,
  role_id          INT NOT NULL,
  PRIMARY KEY (user_id, role_id),
  CONSTRAINT fk_user_roles_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  CONSTRAINT fk_user_roles_role FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------- Employees ----------
CREATE TABLE employees (
  employee_id          INT AUTO_INCREMENT PRIMARY KEY,
  emp_number           VARCHAR(20) NOT NULL UNIQUE,           -- Human-friendly employee ID
  first_name           VARCHAR(80) NOT NULL,
  last_name            VARCHAR(80) NOT NULL,
  middle_name          VARCHAR(80) NULL,
  dob                  DATE NOT NULL,
  email                VARCHAR(255) NOT NULL UNIQUE,
  phone                VARCHAR(32) NULL,
  address_line1        VARCHAR(255) NULL,
  address_line2        VARCHAR(255) NULL,
  city                 VARCHAR(120) NULL,
  state_province       VARCHAR(120) NULL,
  postal_code          VARCHAR(20) NULL,
  country              VARCHAR(120) NULL DEFAULT 'USA',
  hire_date            DATE NOT NULL,
  termination_date     DATE NULL,
  status               ENUM('ACTIVE','ON_LEAVE','TERMINATED') NOT NULL DEFAULT 'ACTIVE',
  division_id          INT NOT NULL,
  job_title_id         INT NOT NULL,
  manager_employee_id  INT NULL,                               -- self-referencing FK (optional)
  ssn_last4            CHAR(4) NULL,
  ssn_enc              VARBINARY(256) NULL,                    -- application-level AES-GCM encrypted SSN (full)
  created_at           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_emp_div FOREIGN KEY (division_id) REFERENCES divisions(division_id),
  CONSTRAINT fk_emp_job FOREIGN KEY (job_title_id) REFERENCES job_titles(job_title_id),
  CONSTRAINT fk_emp_mgr FOREIGN KEY (manager_employee_id) REFERENCES employees(employee_id)
) ENGINE=InnoDB;

CREATE INDEX idx_emp_last_first ON employees(last_name, first_name);
CREATE INDEX idx_emp_dob ON employees(dob);
CREATE INDEX idx_emp_empnumber ON employees(emp_number);

-- Optional mapping between users and employees (if every employee has an app user account)
CREATE TABLE user_employee_map (
  user_id      INT NOT NULL UNIQUE,
  employee_id  INT NOT NULL UNIQUE,
  PRIMARY KEY (user_id, employee_id),
  CONSTRAINT fk_uemap_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  CONSTRAINT fk_uemap_emp  FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------- Compensation (current + history) ----------
CREATE TABLE salary_history (
  salary_id       INT AUTO_INCREMENT PRIMARY KEY,
  employee_id     INT NOT NULL,
  amount          DECIMAL(12,2) NOT NULL,             -- Annual salary in USD
  effective_date  DATE NOT NULL,
  reason          VARCHAR(255) NULL,
  updated_by      INT NULL,                            -- user_id of HR admin
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_sal_emp FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE,
  CONSTRAINT fk_sal_upd FOREIGN KEY (updated_by) REFERENCES users(user_id)
) ENGINE=InnoDB;

CREATE INDEX idx_sal_emp_eff ON salary_history(employee_id, effective_date DESC);

-- A view to get the current salary (latest by effective_date) for each employee
CREATE OR REPLACE VIEW v_employee_current_salary AS
SELECT sh.employee_id, sh.amount AS current_salary, sh.effective_date
FROM salary_history sh
JOIN (
  SELECT employee_id, MAX(effective_date) AS max_eff
  FROM salary_history
  GROUP BY employee_id
) last_sh
ON sh.employee_id = last_sh.employee_id AND sh.effective_date = last_sh.max_eff;

-- ---------- Pay Statements ----------
CREATE TABLE pay_statements (
  pay_statement_id INT AUTO_INCREMENT PRIMARY KEY,
  employee_id      INT NOT NULL,
  period_start     DATE NOT NULL,
  period_end       DATE NOT NULL,
  pay_date         DATE NOT NULL,
  gross_pay        DECIMAL(12,2) NOT NULL,
  taxes            DECIMAL(12,2) NOT NULL,
  deductions       DECIMAL(12,2) NOT NULL,
  net_pay          DECIMAL(12,2) NOT NULL,
  created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_pay_emp FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_pay_emp_date ON pay_statements(employee_id, pay_date DESC);

-- ---------- Audit ----------
CREATE TABLE audit_log (
  audit_id     BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id      INT NULL,
  action       VARCHAR(64) NOT NULL,         -- e.g., 'EMPLOYEE_UPDATE', 'SALARY_INCREASE_RANGE'
  entity       VARCHAR(64) NOT NULL,         -- e.g., 'EMPLOYEE', 'SALARY', 'PAY_STATEMENT'
  entity_id    VARCHAR(64) NULL,             -- string to allow composite keys if needed
  details_json JSON NULL,
  ip_address   VARCHAR(64) NULL,
  created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_audit_user FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB;

-- ---------- Employee self-view (mask SSN, join current salary) ----------
CREATE OR REPLACE VIEW v_employee_self_profile AS
SELECT
  e.employee_id,
  e.emp_number,
  e.first_name,
  e.last_name,
  e.middle_name,
  e.dob,
  e.email,
  e.phone,
  e.address_line1, e.address_line2, e.city, e.state_province, e.postal_code, e.country,
  e.hire_date, e.termination_date, e.status,
  e.division_id, e.job_title_id, e.manager_employee_id,
  CONCAT('***-**-', COALESCE(e.ssn_last4, 'XXXX')) AS ssn_masked,
  cs.current_salary,
  cs.effective_date AS salary_effective_date,
  e.created_at, e.updated_at
FROM employees e
LEFT JOIN v_employee_current_salary cs ON cs.employee_id = e.employee_id;

-- ---------- Reports (views + sample queries) ----------
-- Monthly total pay by job title (net or gross? This example uses gross_pay)
CREATE OR REPLACE VIEW v_monthly_total_pay_by_job_title AS
SELECT
  DATE_FORMAT(ps.pay_date, '%Y-%m') AS yyyy_mm,
  jt.title AS job_title,
  SUM(ps.gross_pay) AS total_gross_pay
FROM pay_statements ps
JOIN employees e       ON e.employee_id = ps.employee_id
JOIN job_titles jt     ON jt.job_title_id = e.job_title_id
GROUP BY yyyy_mm, job_title;

-- Monthly total pay by division
CREATE OR REPLACE VIEW v_monthly_total_pay_by_division AS
SELECT
  DATE_FORMAT(ps.pay_date, '%Y-%m') AS yyyy_mm,
  d.name AS division_name,
  SUM(ps.gross_pay) AS total_gross_pay
FROM pay_statements ps
JOIN employees e   ON e.employee_id = ps.employee_id
JOIN divisions d   ON d.division_id = e.division_id
GROUP BY yyyy_mm, division_name;

-- Employees hired within a date range (parameterized in app; here a sample SELECT)
-- SELECT * FROM employees WHERE hire_date BETWEEN '2025-01-01' AND '2025-12-31' ORDER BY hire_date DESC;

-- ---------- Procedures ----------
DELIMITER $$

-- Range salary increase: increase current salary by pct for employees whose CURRENT salary is within [min_salary, max_salary)
CREATE PROCEDURE sp_apply_salary_increase_range (
  IN p_percent DECIMAL(6,4),           -- e.g., 0.032 for 3.2%
  IN p_min_salary DECIMAL(12,2),
  IN p_max_salary DECIMAL(12,2),
  IN p_effective_date DATE,
  IN p_reason VARCHAR(255),
  IN p_updated_by INT
)
BEGIN
  -- Use a temporary table to collect target employees with their latest salary
  CREATE TEMPORARY TABLE tmp_targets (
    employee_id INT PRIMARY KEY,
    current_salary DECIMAL(12,2)
  ) ENGINE=MEMORY;

  INSERT INTO tmp_targets (employee_id, current_salary)
  SELECT cs.employee_id, cs.current_salary
  FROM v_employee_current_salary cs
  WHERE cs.current_salary >= p_min_salary
    AND cs.current_salary <  p_max_salary;

  -- Insert new rows into salary_history with increased amounts
  INSERT INTO salary_history (employee_id, amount, effective_date, reason, updated_by)
  SELECT
    t.employee_id,
    ROUND(t.current_salary * (1 + p_percent), 2) AS new_amount,
    p_effective_date,
    CONCAT('Bulk increase ', ROUND(p_percent*100,3), '%, range [', p_min_salary, ', ', p_max_salary, '): ', p_reason),
    p_updated_by
  FROM tmp_targets t;

  -- Audit one record per run; detailed per-employee changes can be derived from salary_history diff
  INSERT INTO audit_log (user_id, action, entity, entity_id, details_json)
  VALUES (p_updated_by, 'SALARY_INCREASE_RANGE', 'SALARY', NULL,
          JSON_OBJECT('percent', p_percent, 'min', p_min_salary, 'max', p_max_salary, 'effective_date', p_effective_date, 'reason', p_reason));

  DROP TEMPORARY TABLE IF EXISTS tmp_targets;
END $$

-- HR admin: update employee (basic example; application should validate fields and enforce authorization)
CREATE PROCEDURE sp_update_employee_basic (
  IN p_employee_id INT,
  IN p_first_name VARCHAR(80),
  IN p_last_name  VARCHAR(80),
  IN p_email      VARCHAR(255),
  IN p_phone      VARCHAR(32),
  IN p_address1   VARCHAR(255),
  IN p_address2   VARCHAR(255),
  IN p_city       VARCHAR(120),
  IN p_state      VARCHAR(120),
  IN p_postal     VARCHAR(20),
  IN p_country    VARCHAR(120),
  IN p_division_id INT,
  IN p_job_title_id INT,
  IN p_manager_employee_id INT,
  IN p_updated_by INT
)
BEGIN
  UPDATE employees
  SET first_name = p_first_name,
      last_name  = p_last_name,
      email      = p_email,
      phone      = p_phone,
      address_line1 = p_address1,
      address_line2 = p_address2,
      city = p_city,
      state_province = p_state,
      postal_code = p_postal,
      country = p_country,
      division_id = p_division_id,
      job_title_id = p_job_title_id,
      manager_employee_id = p_manager_employee_id
  WHERE employee_id = p_employee_id;

  INSERT INTO audit_log (user_id, action, entity, entity_id, details_json)
  VALUES (p_updated_by, 'EMPLOYEE_UPDATE', 'EMPLOYEE', CAST(p_employee_id AS CHAR),
          JSON_OBJECT('fields', JSON_ARRAY('name','email','phone','address','division','job_title','manager')));
END $$

DELIMITER ;

-- ---------- Minimal seed data (safe to delete) ----------
INSERT INTO divisions(name) VALUES ('Engineering'), ('Sales'), ('Operations');
INSERT INTO job_titles(title, pay_grade) VALUES ('Software Engineer', 'P3'), ('Sales Manager', 'M2'), ('HR Generalist','P2');

INSERT INTO users(username, email) VALUES ('admin', 'admin@companyz.example'); -- assign hash in app
INSERT INTO roles(name) VALUES ('HR_ADMIN'), ('EMPLOYEE');
INSERT INTO user_roles(user_id, role_id) VALUES (1, 1); -- admin -> HR_ADMIN

-- Sample employees (SSN fields left NULL for demo; application should set ssn_last4 + ssn_enc securely)
INSERT INTO employees(emp_number, first_name, last_name, dob, email, phone, hire_date, division_id, job_title_id, ssn_last4)
VALUES
('E0001','Ava','Lee','1990-02-15','ava.lee@companyz.example','404-555-0101','2021-07-01',1,1,'1234'),
('E0002','Noah','Kim','1987-09-23','noah.kim@companyz.example','404-555-0102','2022-03-14',2,2,'9876');

INSERT INTO salary_history(employee_id, amount, effective_date, reason)
VALUES
(1, 95000.00, '2024-01-01','Initial'),
(2, 110000.00,'2024-01-01','Initial');

INSERT INTO pay_statements(employee_id, period_start, period_end, pay_date, gross_pay, taxes, deductions, net_pay)
VALUES
(1,'2025-09-01','2025-09-15','2025-09-20', 3653.85, 800.00, 200.00, 2653.85),
(1,'2025-09-16','2025-09-30','2025-10-05', 3653.85, 800.00, 200.00, 2653.85),
(2,'2025-09-01','2025-09-15','2025-09-20', 4230.77, 950.00, 250.00, 3030.77);

-- ---------- Sample Report Queries ----------
-- 1) Pay statement history for a given employee (most recent first)
-- SELECT * FROM pay_statements WHERE employee_id = 1 ORDER BY pay_date DESC;

-- 2) Total pay for month by job title
-- SELECT * FROM v_monthly_total_pay_by_job_title WHERE yyyy_mm = '2025-09';

-- 3) Total pay for month by division
-- SELECT * FROM v_monthly_total_pay_by_division WHERE yyyy_mm = '2025-09';

-- 4) Employees hired within a given date range
-- SELECT employee_id, emp_number, first_name, last_name, hire_date
-- FROM employees
-- WHERE hire_date BETWEEN '2025-01-01' AND '2025-12-31'
-- ORDER BY hire_date DESC;

-- ---------- Helpful indexes ----------
-- Already added in table creation; consider adding: 
-- CREATE INDEX idx_emp_email ON employees(email);
-- CREATE INDEX idx_ps_period ON pay_statements(period_start, period_end);
