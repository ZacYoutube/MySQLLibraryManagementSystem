use cs4222ProjectFinal;
-- 1.
--   SELECT book_name FROM Books
--   WHERE book_id in 
-- 			(SELECT book_id FROM Book_copy as BC
--             WHERE BC.copy_id in 
--             (SELECT copy_id FROM Loan as L 
--             WHERE L.borrower_id in (SELECT borrower_id FROM Borrower as B 
--             WHERE B.borrower_type = "Faculty" and B.department = "Electrical Engineering")));

-- 2.
-- SELECT AVG(a.count) 
-- 	FROM
-- 	(SELECT count(copy_id) as count from Loan where borrower_id in
-- 		(select borrower_id from Borrower where
-- 			department = "Computer Science" and 
--             borrower_type = "Graduate Student")
--               ) as a;
-- 3.
-- 	SELECT first_name, last_name, fee FROM Borrower as B 
--     JOIN Loan as L ON B.borrower_id = L.borrower_id and B.borrower_type = "Undergraduate Student" and fee > 0.0;
-- 4.
 SELECT branch_name from Library_branch where not exists(
 select borrower_id from Loan where borrower_id in 
 (select borrower_id from Borrower where department = "Computer Science" and borrower_type = "Faculty")
 and (branch_id, branch_name) not in 
 (select branch_id, branch_name from Library_branch));

-- 5.
-- select book_name 
-- from books
-- where book_id in (
--     select book_id
--     from book_copy
--     where branch_id in (
--         select branch_id 
--         from library_branch B1
--         where branch_name = "Focusing on Science and Technology"))
--     and book_id not in(
--     select book_id
--     from book_copy
--     where branch_id in (
--         select branch_id 
--         from library_branch B1
--         where branch_name <> "Focusing on Science and Technology"));
             
-- 6
-- 	SELECT first_name, last_name FROM Borrower WHERE borrower_id in
-- 		(SELECT borrower_id FROM Loan WHERE extension > 0);

-- 7.
--  SELECT book_name FROM Books WHERE book_type = "New" and book_id in
-- 	(SELECT book_id FROM Book_copy WHERE branch_id = 3 and book_status = "Available")

-- 8

		

             