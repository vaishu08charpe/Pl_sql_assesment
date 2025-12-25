--Library Management System.

--TABLE FOR BOOK MANAGEMENT
Create table books(
book_id NUMBER PRIMARY KEY,
book_name VARCHAR2(100),
author_name VARCHAR2(50),
available_book_quantity NUMBER
);



--input values for book 
insert into books values (101, 'Clean Code', 'Robert C', 5);
insert into books values(102, 'Atomic Habits', 'James clear', 6);
insert into books values(103, 'Wings', 'Abdul Kalam', 2);
insert into books values(104, 'Rich Dad', 'Robert', 4);
insert into books values(105, 'Think Fast', 'Daniel', 3);
insert into books values(106, '1984', 'George', 10);
--(book_id, book_name, author_name, available_book_quantity )



--TABLE FOR MEMBERS MANAGEMNET
Create table members(
member_id NUMBER PRIMARY KEY,
member_name VARCHAR2(50),
member_type VARCHAR2(100)
);


insert into members values(1, 'vaishnavi', 'student');
insert into members values(2, 'riya', 'student');
insert into members values(3, 'nidhi', 'student');
insert into members values(4, 'aakanksha', 'student');
insert into members values(5, 'divyanshu', 'student');

--(member_id, member_name, member_type)


--TABLE FOR ISSUE-RETURN
Create table issue_return(
issue_id NUMBER PRIMARY KEY,
book_id NUMBER,
member_id NUMBER,
issue_date DATE,
return_date DATE,
due_date DATE,
fine NUMBER,
status VARCHAR2(10),
CONSTRAINT fk_book FOREIGN KEY (book_id) REFERENCES books(book_id), 
CONSTRAINT fk_member FOREIGN KEY (member_id) REFERENCES members(member_id)
);
 
 --create suquence
create sequence issue_seq
START WITH 1
INCREMENT BY 1;


--CREATE PROCEDURE FOR BOOK ISSUE 
Create or replace procedure book_issue(p_book_id NUMBER, p_member_id NUMBER)
IS 
v_quantity NUMBER;

Begin
select available_book_quantity into v_quantity
from books 
where book_id = p_book_id;


if v_quantity > 0 then
insert into issue_return
values(issue_seq.NEXTVAL, p_book_id, p_member_id,
      SYSDATE, NULL, SYSDATE + 7, 0, 'ISSUED');
  
  
  update books
  set available_book_quantity = available_book_quantity -1
  where book_id = p_book_id;
        
        
  DBMS_OUTPUT.PUT_LINE('Book issued successfully');        
else
  DBMS_OUTPUT.PUT_LINE('Book not available');
END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Invalid Book ID');
   
END;
/



CREATE OR REPLACE PROCEDURE return_book_proc(
    p_issue_id NUMBER
)
IS
    v_book_id NUMBER;
BEGIN
    SELECT book_id
    INTO v_book_id
    FROM issue_return
    WHERE issue_id = p_issue_id
    AND status = 'ISSUED';

    UPDATE issue_return
    SET return_date = SYSDATE,
        status = 'RETURNED'
    WHERE issue_id = p_issue_id;

    UPDATE books
    SET available_book_quantity = available_book_quantity + 1
    WHERE book_id = v_book_id;

    DBMS_OUTPUT.PUT_LINE('Book returned successfully');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Invalid Issue ID');
END;
/


--CREATE FUNCTTION FOR CALCULATION OF FINE 
create or replace function calculate_fine( p_due_date DATE,
                                          p_return_date DATE)
    return NUMBER IS
    Begin
    IF p_return_date > p_due_date THEN
        RETURN (p_return_date - p_due_date) * 10;
    ELSE
        RETURN 0;
    END IF;
END;
/






CREATE OR REPLACE TRIGGER trg_auto_fine
BEFORE UPDATE OF return_date
ON issue_return
FOR EACH ROW
BEGIN
    IF :NEW.return_date IS NOT NULL THEN
   :NEW.fine := calculate_fine(:OLD.due_date, :NEW.return_date);
END IF;
END;
/


SET SERVEROUTPUT ON

DECLARE
    CURSOR overdue_cur IS
        SELECT member_id, book_id, due_date
        FROM issue_return
        WHERE status = 'ISSUED'
        AND due_date < SYSDATE;
BEGIN
    FOR rec IN overdue_cur LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Member: ' || rec.member_id ||
            ' | Book: ' || rec.book_id ||
            ' | Due Date: ' || rec.due_date
        );
    END LOOP;
END;
/



CREATE OR REPLACE PACKAGE library_pkg IS
    PROCEDURE issue_book(p_book_id NUMBER, p_member_id NUMBER);
    PROCEDURE return_book(p_issue_id NUMBER);
END;
/

CREATE OR REPLACE PACKAGE BODY library_pkg IS

    PROCEDURE issue_book(p_book_id NUMBER, p_member_id NUMBER) IS
    BEGIN
        book_issue(p_book_id, p_member_id);
    END;

    PROCEDURE return_book(p_issue_id NUMBER) IS
    BEGIN
        return_book_proc(p_issue_id);
    END;

END;
/



--select *  from books;
--select * from members;
SET SERVEROUTPUT ON

EXEC library_pkg.issue_book(101,1);
EXEC library_pkg.return_book(1);

UPDATE issue_return
SET return_date = issue_date + 3
WHERE issue_id = 1;

SELECT * FROM issue_return;
