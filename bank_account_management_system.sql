--created customer table 
CREATE TABLE customers (
    customer_id NUMBER PRIMARY KEY,
    customer_name VARCHAR2(50),
    mobile_no VARCHAR2(15),
    city VARCHAR2(30)
);
--created account table
CREATE TABLE accounts (
    account_id NUMBER PRIMARY KEY,
    customer_id NUMBER,
    balance NUMBER,
    account_type VARCHAR2(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
--created transactions table for transaction
CREATE TABLE transactions (
    trans_id NUMBER PRIMARY KEY,
    account_id NUMBER,
    trans_type VARCHAR2(10),
    amount NUMBER,
    trans_date DATE,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);
--cretaed sequence
create sequence seq
start with 1
increment by 1;

--created procedure for deposit money
create or replace procedure deposit_money(p_account_id IN NUMBER,  p_amount IN NUMBER)
IS
BEGIN
update accounts
set balance = balance + p_amount
where account_id=p_account_id;
  
  IF SQL%ROWCOUNT = 0 THEN
   RAISE_APPLICATION_ERROR(-20002, 'Account does not exist');
END IF;

INSERT INTO transactions
    (trans_id, account_id, trans_type, amount, trans_date)
    VALUES
    (seq.NEXTVAL, p_account_id, 'DEPOSIT', p_amount, SYSDATE);
commit;
end;
/

--created procedure for withdraw money
create or replace procedure withdraw_money(p_account_id IN NUMBER,  p_amount IN NUMBER)
IS
v_balance NUMBER;
BEGIN
    SELECT balance INTO v_balance
    FROM accounts
    WHERE account_id = p_account_id;

    IF v_balance < p_amount THEN
        RAISE_APPLICATION_ERROR(-20001, 'Insufficient Balance');
    END IF;
update accounts
set balance = balance - p_amount
where account_id=p_account_id;

IF SQL%ROWCOUNT = 0 THEN
   RAISE_APPLICATION_ERROR(-20002, 'Account does not exist');
END IF;

INSERT INTO transactions
    (trans_id, account_id, trans_type, amount, trans_date)
    VALUES
    (seq.NEXTVAL, p_account_id, 'WITHDRAW', p_amount, SYSDATE);
COMMIT;
END;
/

--created function get balance
CREATE or replace function get_balance( p_account_id IN NUMBER)
RETURN NUMBER IS
    v_balance NUMBER;
BEGIN
    SELECT balance INTO v_balance
    FROM accounts
    WHERE account_id = p_account_id;

    RETURN v_balance;
END;
/

--created trigger
create or replace trigger trg_transaction_log
after insert on transactions
for each row
BEGIN
    DBMS_OUTPUT.PUT_LINE('Transaction Successful: ' || :NEW.trans_type);
END;
/


insert into customers values (1, 'Amit', '9876543210', 'Delhi');
insert into customers values (2, 'vaishnavi', '9876543210', 'pune');
insert into customers values (3, 'riya', '9876543210', 'mumbai');
insert into customers values (4, 'nidhi', '9876543210', 'noida');
insert into customers values (5, 'aakanksha', '9876543210', 'goa');


insert into accounts values (101, 1, 5000, 'Savings');
insert into accounts values (102, 2, 6000, 'Savings');
insert into accounts values (103, 3, 7000, 'Savings');
insert into accounts values (104, 4, 8000, 'Savings');
insert into accounts values (105, 5, 4000, 'Savings');
commit;

EXEC deposit_money(101, 2000);
EXEC withdraw_money(101, 1000);
EXEC deposit_money(102, 3000);
EXEC withdraw_money(102, 15000);
SELECT get_balance(101) FROM dual;
SELECT get_balance(102) FROM dual;




SELECT * FROM transactions;

