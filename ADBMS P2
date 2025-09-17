-- Here I am explaining here the code in detail which follows ACID properties :

-- First we will create the table with required constraints.
CREATE TABLE FeePayments (
    payment_id INT PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0),
    payment_date DATE NOT NULL
);

-- Checking the contents
SELECT * FROM FeePayments;

------------------------------------------------------------------

-- Part A: Demonstrating successful transaction
-- This part demonstrates ATOMICITY and DURABILITY

START TRANSACTION;
INSERT INTO FeePayments (payment_id, student_name, amount, payment_date) VALUES
(1, 'Ashish', 5000.00, '2024-06-01'),
(2, 'Smaran', 4500.00, '2024-06-02'),
(3, 'Vaibhav', 5500.00, '2024-06-03');
COMMIT;

-- Verifying the result that all changes are committed 
SELECT * FROM FeePayments;

------------------------------------------------------------------

-- Part B: Demonstrating a failed transaction
-- This part demonstrates ATOMICITY, CONSISTENCY and ROLLBACK


START TRANSACTION;

-- Attempting a valid insertion
INSERT INTO FeePayments (payment_id, student_name, amount, payment_date)
VALUES (4, 'Kiran', 6000.00, '2024-06-04');

-- Attempting an invalid insertion that will give error (violates Primary Key)
INSERT INTO FeePayments (payment_id, student_name, amount, payment_date)
VALUES (1, 'Duplicate Ashish', 3000.00, '2024-06-05');

-- Because an error occurred, we roll back the entire transaction.
ROLLBACK;

-- Verify the result: Kiran's record was not added. Entire transaction failed as whole.
SELECT * FROM FeePayments;

------------------------------------------------------------------

-- Part C: Demonstrating Atomicity using Partial Failure

START TRANSACTION;

-- Inserting a valid entry.
INSERT INTO FeePayments (payment_id, student_name, amount, payment_date)
VALUES (5, 'Priya', 7000.00, '2024-06-06');

-- Inserting an entry that will give error (violates the NOT NULL constraint)
INSERT INTO FeePayments (payment_id, student_name, amount, payment_date)
VALUES (6, NULL, 4000.00, '2024-06-07');

-- Roll back the transaction due to the error
ROLLBACK;

-- Verify the result. The table is still unchanged. Priya's record is not committed.
SELECT * FROM FeePayments;

------------------------------------------------------------------

-- Part D: Using different sessions demonstrate Isolation.
-- Transactions in sessions do not interfere with each other.

-- Session 1 
START TRANSACTION;
UPDATE FeePayments SET amount = 5200.00 WHERE student_name = 'Ashish';

-- Session 2 runs while Session 1 is still ongoing
SELECT * FROM FeePayments WHERE student_name = 'Ashish';

-- Session 1 is committed
COMMIT;

-- Session 2 runs its query
SELECT * FROM FeePayments WHERE student_name = 'Ashish';
-- Output will now show amount = 5200.00
