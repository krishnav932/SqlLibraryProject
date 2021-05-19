--creating the database
create database LibraryProject

--using the database
use LibraryProject

--creating Books table
create table Books
(
BookId int primary key,
BookName varchar(30) unique not null,
BookAuthor varchar(30) not null,
Branch varchar(30), 
BookQuantity int not null
)


--drop table Books

--inserting into Books Table without using StoredProcedure
insert into Books values(1001,'JAVA','James Gosling','CSE',2)
insert into Books values(1002,'VLSI','Ben Forta','ECE',1)
insert into Books values(1003,'CIRCUITS','Rossum','EEE',3)
insert into Books values(1004,'THERMODYNAMICS','David Herman','MECH',4)
insert into Books values(1005,'HYDRAULICS','Berners Lee','CIVIL',2)

--StoredProcedure to insert in books table
create procedure InsertsBooks
@BkId int,
@BkName varchar(20),
@BkAuthor varchar(20),
@Brnch varchar(20),
@BkQnt int
as
insert into Books values(@BkId,@BkName,@BkAuthor,@Brnch,@BkQnt)

--Executing InsertsBooks StoredProcedure
execute InsertsBooks @BkId=1006, @BkName='Networking',@BkAuthor='Peterson',@Brnch='IT',@BkQnt=5

select * from Books

--creating Students table
create table Students
(
StudentId int primary key,
StudentName varchar(30) unique not null,
Branch varchar(30) 
)

--drop table Students

--inserting values into Students table without using StoredProcecdure
insert into Students values(2001,'Ram','CSE')
insert into Students values(2002,'Shyam','ECE')
insert into Students values(2003,'Rohan','EEE')
insert into Students values(2004,'Kumar','MECH')
insert into Students values(2005,'Surya','CIVIL')

select * from Students


--creating Assign table
create table Assign
(
StudentId int not null references students(studentId),
BookId int not null references Books(BookId),
StudentName varchar(20),
BookName varchar(20),
IssueDate date default(getdate()),
ReturnDate date default(dateadd(dd,10,getdate())),
primary key(studentId, BookId)
)

--drop table Assign
--delete from assign 

--inserting values into Assing table without using StoredProcedure
insert into Assign values(2001,1001,'Ram','JAVA',GETDATE(),DATEADD(DD,10,GETDATE()))
insert into Assign values(2002,1002,'Shyam','VLSI',GETDATE(),DATEADD(DD,10,GETDATE()))
insert into Assign values(2003,1001,'Suraj','JAVA',GETDATE(),DATEADD(DD,10,GETDATE()))
insert into Assign values(2004,1001,'Neeraj','JAVA',GETDATE(),DATEADD(DD,10,GETDATE()))
insert into Assign values(2005,1001,'vishnu','JAVA',GETDATE(),DATEADD(DD,10,GETDATE()))

select * from Assign

--stored procedure to insert values into assign table
create procedure AssiggnInserts
@StudentId int,
@BookId int
as
begin
declare @qnt int
select @qnt=BookQuantity from Books where BookId = @BookId
if @qnt>0				--if booksquantity is greater than zero i.e if books are available
insert into Assign(StudentId,BookId) values(@StudentId,@BookId)
else
print 'No books available to assign'
end


--DROP PROCEDURE dbo.AssiggnInserts
--GO

--executing AssiggnInserts StoredProcedure 
execute AssiggnInserts @StudentId=2001,@BookId=1002
execute AssiggnInserts @StudentId=2001,@BookId=1001
execute AssiggnInserts @StudentId=2002,@BookId=1003
execute AssiggnInserts @StudentId=2003,@BookId=1002

--using Trigger to automatically update studentname and bookname without entering manually
create trigger TAssign on Assign
after insert
as
begin
declare @BookName varchar(20),@StudentName varchar(20),@BookId int,@StudentId int
select @BookId=BookId from inserted
select @StudentId=StudentId from inserted
select @StudentName= StudentName from Students where StudentId = @StudentId
select @BookName =BookName from Books where BookId = @BookId
update Assign set StudentName=@StudentName, BookName = @BookName where StudentId=@StudentId and BookId = @BookId
end
--

select * from Assign
--drop table Assign
--delete from Assign
--delete from books


--Trigger to update number of books available after Book is assigned
create trigger BkQnt 
on Assign
after insert
as
begin
declare @quantity int,@BookId int
select @BookId= BookId from INSERTED
select @quantity = BookQuantity from Books where BookId=@BookId
update Books set BookQuantity = @quantity-1 where BookId=@BookId
end

--Trigger to update number of books available after Book is deleted
create trigger BkQntDel 
on Assign
after delete
as
begin
declare @quantity int,@BookId int
select @BookId= BookId from DELETED
select @quantity = BookQuantity from Books where BookId=@BookId
update Books set BookQuantity = @quantity+1 where BookId=@BookId
end

--drop trigger TReturn
--
--procedure to Return books from assign table
create procedure ReturnBook
@BkId int,
@StId int
as
delete from Assign where BookId= @BkId and StudentId=@StId

--execution of StoredProcedure ReturnBook
execute ReturnBook @BkId=1002,@StId=2001
execute ReturnBook @BkId=1001,@StId=2001
execute ReturnBook @BkId=1003,@StId=2002
execute ReturnBook @BkId=1003,@StId=2002


select * from Assign


---
select * from Books


---