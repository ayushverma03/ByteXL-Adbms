-- ============================================
-- Part A: Prevent Duplicate Enrollments Using Locking
-- ============================================

CREATE TABLE StudentEnrollments (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_name VARCHAR(100),
    course_id VARCHAR(10),
    enrollment_date DATE,
    UNIQUE(student_name, course_id)  -- ensures no duplicate enrollment
);

INSERT INTO StudentEnrollments (student_name, course_id, enrollment_date)
VALUES
('Ashish', 'CSE101', '2024-07-01'),
('Smaran', 'CSE102', '2024-07-01'),
('Vaibhav', 'CSE101', '2024-07-01');

-- Try duplicate insert simulation
-- User A
START TRANSACTION;
INSERT INTO StudentEnrollments (student_name, course_id, enrollment_date)
VALUES ('Ashish', 'CSE101', '2024-07-02');  -- succeeds
COMMIT;

-- User B (at same time)
START TRANSACTION;
INSERT INTO StudentEnrollments (student_name, course_id, enrollment_date)
VALUES ('Ashish', 'CSE101', '2024-07-02');  -- fails: duplicate key violation
COMMIT;

-- ============================================
-- Part B: Use SELECT FOR UPDATE to Lock Student Record
-- ============================================

-- User A
START TRANSACTION;
SELECT * FROM StudentEnrollments
WHERE student_name = 'Ashish' AND course_id = 'CSE101'
FOR UPDATE;   -- locks the row, no one else can update until commit/rollback

-- We keep transaction open (don’t commit yet)

-- User B (runs in another session while User A is open)
START TRANSACTION;
UPDATE StudentEnrollments
SET enrollment_date = '2024-07-05'
WHERE student_name = 'Ashish' AND course_id = 'CSE101';
-- This query will wait until User A commits

-- User A finishes
COMMIT;

-- Now User B query executes successfully
COMMIT;


-- ============================================
-- Part C: Demonstrate Locking Preserving Consistency
-- ============================================

-- Without Locking (race condition)
-- User A
START TRANSACTION;
UPDATE StudentEnrollments
SET enrollment_date = '2024-07-10'
WHERE student_name = 'Ashish' AND course_id = 'CSE101';
COMMIT;

-- User B (almost at same time)
START TRANSACTION;
UPDATE StudentEnrollments
SET enrollment_date = '2024-07-20'
WHERE student_name = 'Ashish' AND course_id = 'CSE101';
COMMIT;

-- Result: only last committed value (2024-07-20) is kept, User A’s update lost.

-- With Locking
-- User A
START TRANSACTION;
SELECT * FROM StudentEnrollments
WHERE student_name = 'Ashish' AND course_id = 'CSE101'
FOR UPDATE;   -- lock row
UPDATE StudentEnrollments
SET enrollment_date = '2024-07-10'
WHERE student_name = 'Ashish' AND course_id = 'CSE101';
COMMIT;

-- User B (tries same after User A’s lock)
START TRANSACTION;
SELECT * FROM StudentEnrollments
WHERE student_name = 'Ashish' AND course_id = 'CSE101'
FOR UPDATE;   -- waits until User A commits
UPDATE StudentEnrollments
SET enrollment_date = '2024-07-20'
WHERE student_name = 'Ashish' AND course_id = 'CSE101';
COMMIT;

-- Final Result: Updates happen in serial order,
-- Ensures no lost updates and preserving consistency.
