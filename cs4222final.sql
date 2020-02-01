create database if not exists cs4222ProjectFinal;
use cs4222ProjectFinal;

-- drop table Loan;

create table if not exists Books(
book_id CHAR(5),
book_name VARCHAR(70) NOT NULL,
book_type VARCHAR(30) NOT NULL,
number_of_words VARCHAR(100),
introduction VARCHAR(1000), 
price decimal (7,2),
publish_date int,
publish_press VARCHAR(40),
date_in date NOT NULL,
ISBN VARCHAR(17) NOT NULL,
PRIMARY KEY(book_id)
);

create table if not exists Authors(
book_id CHAR(5),
author_name VARCHAR(50),
PRIMARY KEY(book_id)
);

create table  if not exists Library_branch(
branch_id int,
branch_name VARCHAR(50) UNIQUE NOT NULL ,
PRIMARY KEY(branch_id)
);

create table if not exists Book_copy (
book_id CHAR(5) NOT NULL,
branch_id int,
copy_id CHAR(5) NOT NULL,
book_status VARCHAR(20) NOT NULL,
PRIMARY KEY(copy_id),
FOREIGN KEY(branch_id) REFERENCES Library_branch(branch_id)
);

create table if not exists Loan_Type(
	borrower_type varchar(30) Not Null,
    book_type varchar(50) Not Null, 
	loan_limit int Not Null,
    loan_period int Not Null,
    extension int Not Null,
    overdue_fee decimal(4,2),
    PRIMARY KEY(borrower_type,book_type)
);

create table if not exists Borrower(
	
    borrower_id char(5),
    borrower_type varchar(50) Not Null,
    department varchar(50) Not Null,
    first_name varchar(20) Not Null,
    midinit char(1),
    last_name varchar(20) Not Null,
	Bdate date NOT NULL,
    email varchar(50) Not Null,
    gender char(1),
  
    PRIMARY KEY(borrower_id),
    FOREIGN KEY(borrower_type) REFERENCES Loan_Type(borrower_type)

);

create table if not exists Loan(
	loan_id char(5),
    borrower_id char(5) Not Null,
    copy_id char(5) Not Null,
    branch_id int Not Null,
    borrow_date date Not Null,
    due_date date Not Null,
    return_date date,
    extension int Not Null,
    fee decimal(9,2) Not Null Default 0.00,
    PRIMARY KEY(loan_id),
    FOREIGN KEY(copy_id) REFERENCES Book_Copy(copy_id),
    FOREIGN KEY( branch_id) REFERENCES Library_branch( branch_id),
	FOREIGN KEY( borrower_id) REFERENCES Borrower( borrower_id));
--     
create table if not exists Online_System(
    os_username char(5) Not Null,
    os_password date NOT NULL,
    
    PRIMARY KEY(os_username)
);


 

-- drop trigger if exists online_system_account;
-- DELIMITER //
-- create trigger online_system_acount after insert on Borrower
-- FOR EACH ROW
-- BEGIN
-- insert into Online_System(os_username, os_password) values (NEW.borrower_id, NEW.Bdate);
-- END //
-- DELIMITER ;

-- drop trigger if exists type_newbook;
-- DELIMITER //
-- create trigger type_newbook before insert on Books
-- FOR EACH ROW
-- BEGIN
-- IF datediff(CURDATE(),NEW.date_in) < 60 THEN 
-- SET NEW.book_type = "New";
-- Elseif datediff(CURDATE(),NEW.date_in) >= 60 And New.book_type = "New" THEN 
-- SET NEW.book_type = "Foreign";
-- END IF;
-- END //
-- DELIMITER ;

-- drop trigger if exists set_status_after_loan;
-- DELIMITER //
-- create trigger set_status_after_loan after insert on Loan
-- FOR EACH ROW
-- BEGIN
-- UPDATE Book_copy
-- SET
-- 	book_status = "Lent out"
--     where copy_id = NEW.copy_id;
-- END //
-- DELIMITER ;


-- drop trigger IF EXISTS set_status_after_return;
-- DELIMITER //
-- create trigger set_status_after_return after update on Loan
-- FOR EACH ROW
-- BEGIN
-- UPDATE Book_copy
-- SET
-- 	book_status = "Available"
--     where copy_id = OLD.copy_id;
-- END //
-- DELIMITER ;



-- DELIMITER //
-- drop trigger if exists check_action_on_book;
-- create trigger check_action_on_book before update on Loan
-- FOR EACH ROW
-- BEGIN
-- select datediff(CURDATE(),OLD.due_date) into @days from Loan where loan_id = OLD.loan_id;
-- select book_type into @bType from Books 
-- 	where book_id in 
-- 		(select book_id from Book_copy 
-- 			where copy_id in
-- 				(select copy_id from Loan 
-- 					where loan_id = NEW.loan_id
--                     )
-- 						);
-- IF(@days > 0 and NEW.return_date is null) THEN
-- 		Signal sqlstate "45000" SET message_text = "Borrow has not returned the overdued books";
-- END IF;
-- IF(@bType = "New" and NEW.return_date is null) THEN
-- 		Signal sqlstate "45000" SET message_text ="New books can not be renewed";
-- END IF;
-- IF(OLD.extension > 0) THEN
-- 		Signal sqlstate "45000" SET message_text = "Exceeds the renewal limitation";
-- END IF;
-- IF(OLD.branch_id != NEW.branch_id) THEN
-- 		Signal sqlstate "45000" SET message_text = "Returned to wrong branch";
-- END IF;
-- IF(OLD.borrow_date = NEW.return_date) THEN
-- 		Signal sqlstate "45000" SET message_text = "Can't return book on the borrowed day";
-- END IF;

-- END //
-- DELIMITER ;

-- drop trigger if exists before_borrow;

-- DELIMITER //
-- create trigger before_borrow before insert on Loan
-- FOR EACH ROW
-- BEGIN
-- 		select book_id, date_in, book_type into @id, @Din, @bType from Books as B
-- 			where B.book_id in (
-- 				select book_id from Book_copy where copy_id = NEW.copy_id);
-- 		select borrower_type into @boType from Borrower where borrower_id = NEW.borrower_id;
-- 		select Sum(fee) into @f from Loan where borrower_id = NEW.borrower_id;
-- 		select loan_limit, overdue_fee into @Llimit,@Ofee from Loan_Type where borrower_type = @boType and book_type = @bType;
-- 		select Count(copy_id) into @count from Loan
-- 			Where copy_id In
-- 				(select copy_id from Book_copy where book_id in
-- 					(select book_id from Books where book_type = @bType)) and borrower_id = NEW.borrower_id and NEW.return_date Is Null;
--     IF datediff(CURDATE(),@Din) >= 60 And @bType = "New" Then
-- 		Update Books Set book_type = "Foreign" Where book_id  = @id;
-- 		Set @bType = "Foreign";
-- 	End If;
-- 	IF @f > 0.00 Then
-- 		Signal sqlstate "45000" SET message_text = "Error, unpaid fee or overdue books";
-- 	End If;
--     If 	@count = @Llimit Then
-- 		Signal sqlstate "45000" SET message_text = "Exceed max limit";
-- 	End If;
-- END //
-- DELIMITER ;

-- DROP PROCEDURE IF EXISTS BORROW;
--  DELIMITER //
--  create procedure BORROW(in l_id char(5), in c_id char(5), b_id char(5), in bo_date date )
--  BEGIN
--      select book_type into @bType from Books 
-- 			where book_id in(select book_id from Book_copy
-- 							where copy_id = copy_id) limit 1;
--      select borrower_type into @boType from Borrower 
-- 			where borrower_id = b_id limit 1;
--      select branch_id into @branch from Book_copy 
-- 			where copy_id = c_id;
--      select overdue_fee,loan_period into @overdueFee,@period from Loan_Type 
-- 			where borrower_type = @boType and book_type = @bType;
-- 	 set @due_date = date_add(bo_date, Interval @period day);
--      set @dued_days = datediff(CURDATE(), @due_date);
--      set @due_fine = 0;
--     If (@dued_days > 0) Then
-- 		Set @due_fine = @dued_days* @overdueFee;
-- 	End If;
--     Insert Into Loan
--     Values(l_id,b_id,c_id,@branch,bo_date,@due_date,NULL,0,@due_fine);
--   END //
--  DELIMITER ;
 
-- DROP PROCEDURE IF EXISTS RENEWAL;
--  DELIMITER //
--  create procedure RENEWAL(in l_id char(5))
--  BEGIN
--     select book_type into @bType from Books 
-- 			where book_id in(select book_id from Book_copy
-- 							where copy_id in 
-- 								(select copy_id from Loan as L where L.loan_id = l_id )) ;
--      select borrower_type into @boType from Borrower 
-- 			where borrower_id in 
-- 				(select borrower_id from Loan as L where L.loan_id = l_id);
--      select due_date into @due from Loan as L where L.loan_id = l_id;
--      select overdue_fee,loan_period,extension into @overdueFee,@period, @ext from Loan_Type 
-- 			where borrower_type = @boType and book_type = @bType;
-- 	 set @due_fine = 0;
-- 	 set @new_due_date = date_add(@due, interval @ext day);
--      set @days_till_new_due = datediff(CURDATE(), @new_due_date);
--    
--      IF(@days_till_new_due > 0) THEN
-- 		set @due_fine = @days_till_new_due * @overdueFee;
-- 	 END IF;
-- 	
--     update Loan
--     set due_date = @new_due_date, extension = extension + 1, fee = @due_fine
--     where loan_id = l_id;
--  
--  END//
--   DELIMITER ;
  
  --  DROP PROCEDURE IF EXISTS B_RETURN;
--   DELIMITER //
--   create procedure B_RETURN(in br_id int, in l_id char(5), in r_date date)
--   BEGIN
--     select book_type into @bType from Books where book_id in 
-- 			(select book_id from Book_copy where copy_id in
-- 				(select copy_id from Loan where loan_id = l_id));
--     select borrower_type into @boType from Borrower where borrower_id in
-- 			(select borrower_id from Loan where loan_id = l_id);
-- 	select due_date into @due from Loan where loan_id = l_id;
--     select overdue_fee into @due_fee from Loan_type where borrower_type = @boType and book_type = @bType;
--     set @dued_days = datediff(r_date, @due);
--     if(@dued_days > 0)
-- 	then 
--     set @fee = @dued_days * @due_fee;
--     end if;
--     update Loan
--     set return_date = r_date, fee = @fee, branch_id = br_id
--     where loan_id = l_id;
--   END//
--   DELIMITER ;
  
--   DROP PROCEDURE IF EXISTS INQUIRY_BORROWER;
--   DELIMITER //
--   create procedure INQUIRY_BORROWER(in b_id char(5))
--   BEGIN
--     select loan_id, due_date, fee from Loan where borrower_id = b_id ;
--   END//
--   DELIMITER ;
--   
--   DROP PROCEDURE IF EXISTS INQUIRY_OFFICER;
--   DELIMITER //
--   create procedure INQUIRY_OFFICER(in borrow_id char(5), in bok_id char(5))
--   BEGIN
--   select * from Borrower where borrower_id = borrow_id;
--   select * from Books where book_id = bok_id;
--   END //
--   DELIMITER ;

  -- insert into Books values ("11111", "Harry Potter", "English","12345","Learn some magicccc!",80.23,2008, "Harry Publish", "2018-12-11","1111111111111111");
  --    insert into Books values ("00000", "Katty Potter", "Foreign","11345","Learn some language",80.23,2001, "Potter Publish", "2018-10-11","0000000000000000");
--   insert into Books values ("22222", "Intro to Algorithms", "Foreign","23456","Learn some algorithms!",76.56,2005, "CSULA Publish", "2019-12-01","2222222222222222");
-- insert into Books values ("33333", "Intro to automata", "English","45678","Learn some automata theories!",57.25,2015, "Math Publish", "2017-07-18","3333333333333333");
--   insert into Books values ("44444", "Intro to Calculas", "Foreign","21476","Learn some Calculus formulas!",123.25,2013, "Cali. Publish", "2014-03-14","4444444444444444");
--   insert into Books values ("55555", "Intro to Calculas II", "Foreign","12466","Learn some Calculus II formulas!",113.20,2015, "Cali. Publish", "2019-10-14","5555555555555555");
--   insert into Books values ("66666", "Intro to Calculas III", "English","20976","Learn some Calculus III formulas!",133.45,2017, "Cali. Publish", "2018-09-14","6666666666666666");
--   insert into Books values ("77777", "Sunset", "Foreign","12576","Story between two teenage lovers",33.25,2014, "Sunset. Publish", "2007-04-19","7777777777777777");
--   
-- select * from Books;

-- 	insert into Loan_type values ("Faculty","English", 12, 90, 30, 0.2);
--     insert into Loan_type values ("Staff","English", 7, 60, 30, 0.2);
--     insert into Loan_type values  ("Graduate Student","English", 12, 60, 30, 0.2);
--     insert into Loan_type values ("Undergraduate Student","English", 8, 60, 30, 0.2);
--     insert into Loan_type values ("Vocational Student","English", 5, 60, 15, 0.2);
-- --     
--     insert into Loan_type values ("Faculty","Foreign", 3, 60, 30, 0.5);
--     insert into Loan_type values ("Staff","Foreign", 1, 30, 30, 0.5);
--     insert into Loan_type values  ("Graduate Student","Foreign", 3, 60, 30, 0.5);
--     insert into Loan_type values ("Undergraduate Student","Foreign", 2, 60, 30, 0.5);
--     insert into Loan_type values ("Vocational Student","Foreign", 1, 30, 15, 0.5);
-- --     
--     insert into Loan_type values ("Faculty","New", 1, 7, 0, 0.5);
--     insert into Loan_type values ("Staff","New", 1, 7, 0, 0.5);
--     insert into Loan_type values  ("Graduate Student","New", 1, 7, 0, 0.5);
--     insert into Loan_type values ("Undergraduate Student","New", 1, 7, 0, 0.5);
--     insert into Loan_type values ("Vocational Student","New", 1, 7, 0, 0.5);
--     


    
-- 	insert into Library_branch values (1, "Focusing on Business and Management");
-- 	insert into Library_branch values (2, "Focusing on Science and Technology");
-- 	insert into Library_branch values (3, "Focusing on Law, Arts and Literature");

--     select * from Library_branch;

-- 		insert into Book_copy values("00000",2,"00001","Available");
-- 	 insert into Book_copy values ("11111",1,"01111","Available");
-- 	insert into Book_copy values ("11111",2,"01211","Available");
-- 	insert into Book_copy values ("11111",3,"01311","Available");
-- 	insert into Book_copy values ("11111",1,"01411","Available");
-- 	insert into Book_copy values ("22222",1,"02222","Available");
-- 	insert into Book_copy values ("22222",2,"02322","Available");
--     insert into Book_copy values ("22222",3,"02422","Available");
--     insert into Book_copy values ("33333",1,"03333","Available");
--     insert into Book_copy values ("33333",2,"03433","Available");
--     insert into Book_copy values ("33333",3,"03533","Available");
--     insert into Book_copy values ("44444",1,"04444","Available");
--     insert into Book_copy values ("44444",2,"04544","Available");
--     insert into Book_copy values ("44444",3,"04644","Available");
--     insert into Book_copy values ("44444",1,"04744","Available");
--     insert into Book_copy values ("55555",1,"05555","Available");
-- 	insert into Book_copy values ("55555",2,"05655","Available");
--     insert into Book_copy values ("55555",3,"05755","Available");
--     insert into Book_copy values ("66666",1,"06666","Available");
--     insert into Book_copy values ("66666",2,"06766","Available");
--     insert into Book_copy values ("66666",3,"06866","Available");
--     insert into Book_copy values ("77777",1,"07777","Available");
--     insert into Book_copy values ("77777",2,"07877","Available");
--     insert into Book_copy values ("77777",3,"07977","Available");
--     
--     select * from Book_copy;
-- 		insert into Borrower values ("01811", "Faculty", "Computer Science", "Kang","S","Lim", "1982-09-12","kang@gmail.com","F");
   -- insert into Borrower values("11112", "Faculty", "Electrical Engineering", "Fadi","H","Haddad","1996-09-20","fadi@gmail.com","M");
--    insert into Borrower values("22223", "Faculty", "Electrical Engineering", "John", "J",  "Hurley","1980-09-22","john@gmail.com","M");
--    insert into Borrower values("33334", "Undergraduate Student", "Computer Science", "Jenny", "J", "Lee", "1998-08-12","jenny@gmail.com","F");
--    insert into Borrower values("44445", "Undergraduate Student", "Computer Science", "Michael", "M", "Wang","1997-03-24", "michael@gmail.com","M");
--    insert into Borrower values("55556", "Staff", "Communication", "Jesicca", "L", "Lee", "1998-09-22","jesicca@gmail.com","F");
--    insert into Borrower values("66667", "Vocational Student", "Computer Science", "Nathen", "T",  "Yu","1999-11-02","nathen@gmail.com","M");
--   insert into Borrower values("77778", "Graduate Student", "Electrical Engineering", "Veronica", "J",  "Toriz","1995-12-12","veronica@gmail.com","F");
--   insert into Borrower values("88889", "Undergraduate Student", "Computer Science", "Jenny", "J",  "Lee","1998-09-22","michael@gmail.com","F");
--   insert into Borrower values("99990", "Staff", "Computer Science", "Thomas", "Z",  "Torez","1979-08-09","thomas@gmail.com","M");
--   insert into Borrower values("01111", "Vocational Student", "Communication", "Jennifer", "L",  "Anshil","1998-10-19", "jeniffer@gmail.com","F");
--      insert into Borrower values("01211", "Undergraduate Student", "Finance", "Susan","M","Lopi","1997-10-02", "susan@calstatela.edu","F");
--     insert into Borrower values("01311", "Vocational Student", "Finance", "Brandon","S","Lopez","1997-10-02", "brandon@gmail.com","M");
--     insert into Borrower values("01411", "Graduate Student", "Finance", "Jose","T","Wangi","1997-10-02", "jose@yahoo.com","M");
--  insert into Borrower values("01511", "Graduate Student", "Computer Science", "Kid","T","Yu","1997-11-02", "kidN@yahoo.com","M");
--   insert into Borrower values("01611", "Graduate Student", "Computer Science", "Nancy","S","Smith","1996-10-22", "nancyS@yahoo.com","F");
--    insert into Borrower values("01711", "Graduate Student", "Computer Science", "Kevin","K","Sky","1995-02-18", "kkk@yahoo.com","M");

-- select * from Borrower;

-- insert into Authors value("11111", "HarryP Anthor");
-- insert into Authors value("22222", "Keean Leva");
-- insert into Authors value("11111", "HPotter Anthor");
-- insert into Authors value("33333", "Yu Chen");
-- insert into Authors value("44444", "Justin Nah");
-- insert into Authors value("55555", "Khloe Zahava");
-- insert into Authors value("66666", "Sam Zabi");
-- insert into Authors value("77777", "Johnson Lee");
-- insert into Authors value("00000", "Johnathon Hamson");

--  select * from Authors;
 --  call BORRROW("99765", "04644", "01811","2019-11-02");
--  call BORROW("11223", "01111", "11112","2019-10-23");
--  call BORROW("22334", "02222","33334", "2019-08-25");
--  call BORROW("33445","01311","77778","2019-07-20");
--  call BORROW("44445","03333","55556", "2019-05-29");
--  call BORROW("55556", "05655", "01111", "2019-11-20");
--   call BORROW("66771", "07877","01211","2019-10-10");
--     call BORROW("77882", "06866","01311","2019-10-05");
--      call BORROW("88993", "04544","01411","2019-11-03");
-- call BORROW("99887","03333","01511","2019-11-29");
-- call BORROW("99787","05755","01611","2019-12-01");
-- CALL BORROW("88989", "06866","01711","2019-09-22");
  show procedure;
-- show triggers;

 --  call RENEWAL("66771");
--  call RENEWAL("88993");
 -- call RENEWAL("66771");
 --  select * from Loan;
 
 --  CALL B_RETURN(1, "44445","2019-12-07") ;
--   SELECT * FROM Loan;
-- select * from Loan;
     
-- call INQUIRY_BORROWER("11112");
-- call INQUIRY_OFFICER("11112","11111");






