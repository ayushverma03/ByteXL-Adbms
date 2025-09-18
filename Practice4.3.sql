-- ============================================
-- Setup: StudentEnrollments Table
-- ============================================

DROP TABLE IF EXISTS StudentEnrollments;

CREATE TABLE StudentEnrollments (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100),
    course_id VARCHAR(10),
    enrollment_date DATE
);

INSERT INTO StudentEnrollments VALUES
(1, 'Ashish', 'CSE101', '2024-06-01'),
(2, 'Smaran', 'CSE102', '2024-06-01'),
(3, 'Vaibhav', 'CSE103', '2024-06-01');

-- ============================================
-- Part A: Simulating a Deadlock
-- ============================================
-- Run these in TWO different sessions (User A & User B)

-- User A
START TRANSACTION;
UPDATE StudentEnrollments
SET enrollment_date = '2024-07-01'
WHERE student_id = 1;

-- Keep transaction open, then try to update student_id = 2
UPDATE StudentEnrollments
SET enrollment_date = '2024-07-05'
WHERE student_id = 2;
-- (This will wait if User B already locked student_id = 2)

-- User B
START TRANSACTION;
UPDATE StudentEnrollments
SET enrollment_date = '2024-08-01'
WHERE student_id = 2;

-- Keep transaction open, then try to update student_id = 1
UPDATE StudentEnrollments
SET enrollment_date = '2024-08-05'
WHERE student_id = 1;
-- Deadlock occurs: one transaction will be rolled back by the DB

-- ============================================
-- Part B: Applying MVCC (Multiversion Concurrency Control)
-- ============================================
-- Requirement: User A sees old value, User B updates without blocking

-- User A
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
SELECT enrollment_date
FROM StudentEnrollments
WHERE student_id = 1;
-- User A sees: 2024-06-01 (old snapshot)

-- Keep transaction open

-- User B
START TRANSACTION;
UPDATE StudentEnrollments
SET enrollment_date = '2024-07-10'
WHERE student_id = 1;
COMMIT;
-- Update succeeds immediately, no blocking

-- User A (still in same transaction)
SELECT enrollment_date
FROM StudentEnrollments
WHERE student_id = 1;
-- Still sees: 2024-06-01 (consistent snapshot due to MVCC)

-- User A commits
COMMIT;

-- User A (new transaction)
SELECT enrollment_date
FROM StudentEnrollments
WHERE student_id = 1;
-- Now sees: 2024-07-10

-- ============================================
-- Part C: Comparing Behavior With and Without MVCC
-- ============================================

-- Case 1: Traditional Locking (SELECT FOR UPDATE) → Reader blocks
-- User A
START TRANSACTION;
SELECT enrollment_date
FROM StudentEnrollments
WHERE student_id = 1
FOR UPDATE;   -- locks the row

-- User B
START TRANSACTION;
SELECT enrollment_date
FROM StudentEnrollments
WHERE student_id = 1;
-- This will BLOCK until User A commits (traditional locking)

-- Case 2: With MVCC → Reader does not block
-- User A
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
UPDATE StudentEnrollments
SET enrollment_date = '2024-07-20'
WHERE student_id = 1;
-- Don’t commit yet

-- User B
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
SELECT enrollment_date
FROM StudentEnrollments
WHERE student_id = 1;
-- User B still sees old snapshot (2024-07-10), not blocked

-- User A commits
COMMIT;

-- User B (still in same transaction)
SELECT enrollment_date
FROM StudentEnrollments
WHERE student_id = 1;
-- Still sees 2024-07-10 due to snapshot isolation

-- User B commits
COMMIT;

-- User B (new transaction)
SELECT enrollment_date
FROM StudentEnrollments
WHERE student_id = 1;
-- Now sees latest value: 2024-07-20
-- Code demonstrates required conditions.
