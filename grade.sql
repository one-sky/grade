if exists(select name from sysdatabases where name='grade')
drop database grade
go

use master
create database grade
go

use grade
if(OBJECT_ID('students') is not null) drop table students
go
create table students(
 sno varchar(8) not null primary key check(sno like '[A-Z][0-9][0-9][0-9][0-9][0-9][0-9][FM]'),
 sname varchar(20),
 gender char(1) check(gender in ('F','M')),
 birthdate date,
 class varchar(20)
)
go
declare @sno char(8),@sname varchar(20),@gender char(1),@birthdate date,@class varchar(20),@i int
set @i=1
while @i<=150
begin
  set @gender=CHAR(63+round(rand()+1,0,0)*7)
  set @sno=CHAR(65+RAND()*10)+right(str(RAND()*1000000+1000000,7,0),6)+CHAR(63+round(rand()+1,0,0)*7)
  print @sno
  set @sname=NCHAR(20000+20000*RAND())+NCHAR(20000+20000*RAND())+NCHAR(20000+20000*RAND())
  set @birthdate=DATEADD(DAY,-RAND()*10000-RAND()*1000-2345,GETDATE())
  set @class=right(RAND()+1,1)
  insert into students(sno,sname,gender,birthdate,class) values(@sno,@sname,@gender,@birthdate,@class)
  set @i=@i+1
end
go
select * from students


use grade
if(OBJECT_ID('courses') is not null) drop table courses
go
create table courses(
 cno varchar(5) not null primary key check(cno like '[A-B][0-9][0-9][0-9]'),
 cname varchar(20),
 pcno varchar(5) constraint fk_courses_pcno references courses(cno),
 ctype char(1) check(ctype in('A','B')),
 score decimal(4,1) check(score>=0.5 and score<=10.0)
)
go
create index courses_pcno_ind on courses(pcno)
go
declare @cno varchar(5),@cname varchar(20),@pcno varchar(5),@ctype char(1),@score decimal(4,1),@i int
set @i=1
while @i<=20
begin
 while 1=1
 begin
  set @cno=CHAR(64+ROUND(1+rand(),0,0))+RIGHT(RAND(),3)
  if(select COUNT(*) from courses where cno=@cno)=0 break
 end
  set @cname=NCHAR(20000+20000*RAND())+NCHAR(20000+20000*RAND())+NCHAR(20000+20000*RAND())
  set @pcno=(select top 1 cno from courses order by NEWID())
  set @ctype=CHAR(64+round(rand()+1,0,0))
  set @score=0.5+cast(RAND()*19 as int)*0.5
  print @score
  insert into courses(cno,cname,pcno,ctype,score) values(@cno,@cname,@pcno,@ctype,@score)
  set @i=@i+1
end
go
select * from courses


use grade
if(OBJECT_ID('teachers') is not null) drop table teachers
go
create table teachers(
 tno int not null primary key identity(20131,1),
 tname varchar(20),
 gender char(1) check(gender in ('F','M')),
 birthdate date,
 title varchar(10)
)
go
declare @tname varchar(20),@gender char(1),@birthdate datetime,@title varchar(10),@i int
set @i=1
while @i<=20
begin
  set @tname=NCHAR(20000+20000*RAND())+NCHAR(20000+20000*RAND())+NCHAR(20000+20000*RAND())
  set @gender=CHAR(63+round(rand()+1,0,0)*7)
  set @birthdate=DATEADD(DAY,-RAND()*60000-RAND()*1000-2345,GETDATE())
  set @title=NCHAR(20000+20000*RAND())+NCHAR(20000+20000*RAND())
  insert into teachers(tname,gender,birthdate,title)  values(@tname,@gender,@birthdate,@title)
  set @i=@i+1
end
go
select * from teachers


use grade
if(OBJECT_ID('stucourses') is not null) drop table stucourses
go
create table stucourses(
 sno varchar(8) not null constraint fk_stucourses_sno references students(sno),
 cno varchar(5) not null constraint fk_stucourses_cno references courses(cno),
 stuterm char(11) check(stuterm like '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]-[12]'),
 grade decimal(5,1)
)
alter table stucourses
add constraint pk_stucourses primary key(sno,cno)
go
declare @stuterm char(11),@grade decimal(5,1),@s1 varchar(30),@s2 varchar(30),
@s3 int,@s4 int,@i int
set @i=1
while @i<=400
begin
  while 1=1
  begin
    select top 1 @s1=sno from students order by NEWID()
    select top 1 @s2=cno from courses order by NEWID()
    if(select COUNT(*) from stucourses where sno=@s1 and cno=@s2)=0 break
  end
  set @s3=year(GETDATE())-left(RAND()*10,1)
  set @s4=@s3+1
  set @stuterm=cast(@s3 as CHAR(4))+'-'+cast(@s4 as CHAR(4))+'-'
  +cast(ROUND(1+RAND(),0) as CHAR(4))
  set @grade=right(RAND()*15+RAND()*15,2)
  print @stuterm
  insert into stucourses(sno,cno,stuterm,grade) values(@s1,@s2,@stuterm,@grade)
  set @i=@i+1
end
go
select * from stucourses

use grade
if(OBJECT_ID('teacnos') is not null) drop table teacnos
go
create table teacnos(
 tno int not null constraint fk_teacnos_tno references teachers(tno),
 cno varchar(5) not null constraint fk_teacnos_cno references courses(cno),
 teaterm char(11) not null check(teaterm like '[1-9][0-9][0-9][0-9]-[1-9][0-9][0-9][0-9]-[12]'),
)
alter table teacnos
add constraint pk_teacnos primary key(tno,cno,teaterm)
go
declare @s1 varchar(30),@s2 varchar(30),@s3 varchar(30),@i int
set @i=1
while @i<=400
begin
  while 1=1
  begin
    select top 1 @s1=tno from teachers order by NEWID()
    select top 1 @s2=cno from courses order by NEWID()
    select top 1 @s3=stuterm from stucourses order by NEWID()
    if (select COUNT(*) from teacnos where tno=@s1 and cno=@s2 and teaterm=@s3)=0 break
  end
  insert into teacnos(tno,cno,teaterm) values(@s1,@s2,@s3)
  set @i=@i+1
end
go
select * from teacnos


--(1)	根据学生成绩表中的数据显示全部学生的成绩，要求按班级、学号的次序显示，输出内容中包括学生姓名和课程名称，并使用中文标题。
select b.sname '学生姓名', c.cname '课程名称', a.grade '成绩' from stucourses a 
join students b on a.sno = b.sno
join courses c on a.cno = c.cno order by b.class,a.sno asc
go
--(2)	根据学生基本信息表与成绩表中的数据，显示姓名为x的这个学生第一学期的全部课程成绩。
-- todo
declare @sname varchar(8)
set @sname=(select top 1 sname from students order by NEWID())
select a.cno, a.grade from stucourses a
join students b on a.sno=b.sno
where b.sname=@sname and a.stuterm like '%1' 
go
--(3)	根据课程表与成绩表中的数据，显示输出课程名称为x.的该课程的平均成绩及格人数比例。
declare @cname varchar(8)
set @cname=(select top 1 cname from courses order by NEWID())
select b.cname, avg(a.grade) as avg from stucourses a 
join courses b on a.cno = b.cno 
where b.cname = @cname group by b.cname
select 100*(select COUNT(*) from courses a
join stucourses b on a.cno=b.cno
where cname=@cname and grade>=60)/(select COUNT(*) from students) as rate
go
--(4)	根据课程表与成绩表中的数据，显示学号为x的这个学生最近这个学期所得到的学分数。
declare @sno varchar(5)
set @sno=(select top 1 sno from students order by NEWID())
select SUM(score) as sum from courses a join stucourses b on a.cno=b.cno 
where sno=@sno and grade>=60 and stuterm=(select top 1 stuterm from stucourses
where sno=@sno order by stuterm desc)
go
--(5)	根据各表数据，列出最近这个学期哪些学生选修的课程数量最多，要求列出姓名。
--CTE
;with tmp as (select a.sno, b.sname, count(*) as count, RANK()over(order by count(*) desc) as rank
 from stucourses a 
 join students b on a.sno = b.sno
 join courses c on a.cno = c.cno
 where a.stuterm = (select top 1 stuterm from stucourses order by stuterm desc)
 group by a.sno, b.sname)
 select * from tmp where rank=1
go
--(6)	根据各表数据，列出最近这个学期哪些学生至少选了两门或两门以上的选修课程，要求列出姓名。
;with tmp as(select  a.sno,sname,count(*) as count from students a 
join stucourses b on a.sno=b.sno
join courses c on c.cno=b.cno
where stuterm=(select top 1 stuterm from stucourses order by stuterm desc)
and ctype='B'
group by a.sno,sname)
select * from tmp where count>=2
go
--(7)	根据课程表与成绩表数据，列出哪些选修课程学生选修的学生人数最多。
;with tmp as(select a.cno,count(*) as count,RANK()over(order by count(*) desc) as rank from courses a join stucourses b on a.cno=b.cno
where ctype='B' group by a.cno)
select * from tmp where rank=1
go
--(8)	分别列出课程名称为X的这门课程考试成绩排名前5位与后5位的学生姓名。
declare @cname varchar(8)
set @cname=(select top 1 cname from courses order by NEWID())
select top 5 sname as name from courses a join stucourses b on a.cno=b.cno
join students c on b.sno=c.sno 
where cname=@cname
order by grade desc
select top 5 sname as name from courses a join stucourses b on a.cno=b.cno
join students c on b.sno=c.sno 
where cname=@cname
order by grade
go
--(9)	列出必修课程成绩不及格其累计学分超过15分的那些学生的姓名。
select sname from students where sno in 
(select a.sno from stucourses a 
join courses b on a.cno = b.cno where b.ctype='B' and a.grade < 60 
group by a.sno having SUM(b.score) >15)
go
--(10)	列出课程名称为x的这门课考试成绩平均分最高的班级。
declare @cname varchar(8)
set @cname=(select top 1 cname from courses order by NEWID())
;with tmp as(select b.class as class,avg(grade) as avg from stucourses a join courses d on a.cno=d.cno
join students b on a.sno=b.sno
where cname=@cname
group by b.class)
select class,avg from tmp where avg=(select MAX(avg) from tmp)
go
--(11)	分班级和性别，输出最近这个学期全部必修课课程的平均考试成绩。
select cname,b.class,b.gender,avg(grade) as avg from stucourses a join courses d on a.cno=d.cno
join students b on a.sno=b.sno
where ctype='A'
group by cname,b.class,b.gender
go
--(12)	根据成绩表中的数据，计算学生基本信息表中每个学生每个学期的平均考试成绩。
select sno,stuterm,avg(grade) as avg from stucourses group by sno,stuterm
go
--(13)	列出第2011-1学期中各个班级平均考试成绩排名前5位学生的姓名，要求按各班按成绩排序。
;with tmp as(select class,a.sno as sno,sname,AVG(grade)as avg1,
RANK()over(PARTITION by class order by AVG(grade)) as rank from students a join stucourses b on a.sno=b.sno 
where stuterm='2011-2012-1' group by class,a.sno,sname)
select * from tmp where rank<=5
go
--(14)	将成绩表中选修课的成绩按五级制（优、良、中、及格、不及格）形式进行输出 
select *,'pricearange'=case
 when grade between 90.01 and 100.00 then '优'
 when grade between 80.01 and 90.00  then '良'
 when grade between 70.01 and 80.00  then '中'
 when grade between 60.00 and 70.00  then '及格'
 else '不及格' end
from stucourses a join courses b on a.cno=b.cno and ctype='B'
go
--(15)	将成绩表中必修课成绩按实际分数输出，同时选修课的成绩按五级制形式输出。
select a.cno,'pricearange'=case
 when grade between 90.01 and 100.00 then '优'
 when grade between 80.01 and 90.00  then '良'
 when grade between 70.01 and 80.00  then '中'
 when grade between 60.00 and 70.00  then '及格'
 else '不及格' end
from stucourses a join courses b on a.cno=b.cno and ctype='B'
union all
select a.cno,cast(grade as CHAR) from stucourses a 
join courses b on a.cno=b.cno and ctype='A'
go
--(16)	在学生表中添加4个列分别存储2008~2011四个学年的学生综合智育成绩（利用系统表判断这4列是否已经存在，如果已经存在，则不必添加）。已知每个学生每个学年的综合智育成绩计算公式如下：
--综合智育成绩=该学期全部必修课成绩的平均分+每门选修课成绩的档次值，其中选修课成绩档次值规定为： >=90分：加4分；80～89分：加3分；70～79分：加2分；60～69分：加1分；<60分：加0分。
if(select COUNT(*) from INFORMATION_SCHEMA.COLUMNS where table_name='students' and column_name='two008')=0 
alter table students add two008 decimal(6,2)
go
if(select COUNT(*) from INFORMATION_SCHEMA.COLUMNS where table_name='students' and column_name='two009')=0 
alter table students add two009 decimal(6,2)
go
if(select COUNT(*) from INFORMATION_SCHEMA.COLUMNS where table_name='students' and column_name='two010')=0 
alter table students add two010 decimal(6,2)
go
if(select COUNT(*) from INFORMATION_SCHEMA.COLUMNS where table_name='students' and column_name='two011')=0 
alter table students add two011 decimal(6,2)
go
--(17)	在学生表中添加4个列分别存储2008~2011四个学年的学生综合智育成绩，根据以上公式使用相关子查询和UPDATE语句计算每个学生每个学年的综合智育成绩。
if(OBJECT_ID('tempdb..#tmp') is not null)drop table #tmp
;with tmp1 as(select sno,stuterm,sum(grade)/(select COUNT(*) from courses where ctype='A') as grade1
from courses a join stucourses b on a.cno=b.cno 
where ctype='A' and left(b.stuterm,4) between 2008 and 2011 group by sno,stuterm
union all
select sno,stuterm,'grade2'=case
 when grade between 90.01 and 100.00 then 4
 when grade between 80.01 and 90.00  then 3
 when grade between 70.01 and 80.00  then 2
 when grade between 60.00 and 70.00  then 1
 else 0 end
from stucourses a join courses b on a.cno=b.cno and ctype='B' and left(stuterm,4) between 2008 and 2011
group by sno,stuterm,grade)
select a.sno,a.stuterm,a.grade1+b.grade1 as grade into #tmp from tmp1 a join tmp1 b on a.sno=b.sno
select * from #tmp
if(select COUNT(*) from INFORMATION_SCHEMA.COLUMNS where table_name='students' and column_name='two008')=0 
alter table students add two008 decimal(6,2)
update students set two008=(select sum(grade) from #tmp where sno=students.sno and stuterm like '2008%')
go
if(select COUNT(*) from INFORMATION_SCHEMA.COLUMNS where table_name='students' and column_name='two009')=0 
alter table students add two009 decimal(6,2)
update students set two009=(select sum(grade) from #tmp where sno=students.sno and stuterm like '2009%')
go
if(select COUNT(*) from INFORMATION_SCHEMA.COLUMNS where table_name='students' and column_name='two010')=0 
alter table students add two010 decimal(6,2)
update students set two010=(select sum(grade) from #tmp where sno=students.sno and stuterm like '2010%')
go
if(select COUNT(*) from INFORMATION_SCHEMA.COLUMNS where table_name='students' and column_name='two011')=0 
alter table students add two011 decimal(6,2)
update students set two011=(select sum(grade) from #tmp where sno=students.sno and stuterm like '2011%')
go
--(18)	根据各表数据与前面的计算结果，统计列出第2011学年综合智育成绩排名前40%，且该学年每门课程成绩都及格的学生的名单。 
select top 40 percent sname,two011 from students a join stucourses b on a.sno=b.sno
join courses c on b.cno=c.cno
where grade>=60 and stuterm like '2011%' group by a.sno,sname,two011
order by two011
go
--(19)	查询每个学期中平均成绩都在班级排名前30%的学生的姓名。
;with tmp1 as(select a.sno,sname,class,stuterm,avg(grade)as avg,
rank()over(partition by class,stuterm order by avg(grade) desc) as rank
from students a 
join stucourses b on a.sno=b.sno
group by stuterm,class,a.sno,sname),
tmp2 as(select class,stuterm,MAX(avg)as max from tmp1 group by class,stuterm)
select sname from students where sno not in(select sno from tmp1 a join tmp2 b
on a.class=b.class and a.stuterm=b.stuterm where a.avg/b.max>0.3)
go
--(20)	计算姓名为x的这个学生第2011-1学期平均成绩在班级中的排名名次。
declare @sname varchar(8)
set @sname=(select top 1 sname from students order by NEWID())
;with tmp as(select sname,class,AVG(grade) as avg from students a join stucourses b on a.sno=b.sno
and stuterm='2011-2012-1' 
group by class,sname)
select COUNT(*) from tmp where avg>(select avg from tmp where sname=@sname)
and class=(select class from tmp where sname=@sname) 
--(21)	查询选修过“数据库”和“数据结构”这两门课程的学生姓名。
declare @cname1 varchar(8),@cname2 varchar(8)
set @cname1=(select top 1 cname from courses order by NEWID())
set @cname2=(select top 1 cname from courses order by NEWID())
;with tmp as(select sname from students a join stucourses b on a.sno=b.sno
join courses c on c.cno=b.cno
where cname=@cname1 or cname=@cname2)
select sname from tmp  group by sname having COUNT(*)>1
go
--(22)	查询没有选修过“数据库”这门课程的学生姓名。
declare @cname varchar(8)
set @cname=(select top 1 cname from courses order by NEWID())
select sname from students where sno not in (select a.sno from students a join stucourses b on a.sno=b.sno
join courses c on c.cno=b.cno
where cname=@cname)
go
--(23)	查询选修过“数据库”但没有选修其先行课的学生姓名。
declare @cname1 varchar(8),@cname2 varchar(8)
set @cname1=(select top 1 cname from courses order by NEWID())
select @cname2=cname from courses where cno=(select pcno from courses where cname=@cname1)
select sname from students where sno in (select a.sno from students a join stucourses b on a.sno=b.sno
join courses c on c.cno=b.cno and cname=@cname1
where a.sno not in(select a.sno from students a join stucourses b on a.sno=b.sno
join courses c on c.cno=b.cno and cname=@cname2))
go
--(24)	查询所有课程成绩全部及格的学生姓名。
select distinct sname from students a join stucourses b on a.sno=b.sno
where grade>=60
go
--(25)	查询每个学期必修课成绩全部及格的学生姓名。
select distinct sname from students a join stucourses b on a.sno=b.sno
join courses c on c.cno=b.cno
where grade>=60 and ctype='A'
go
--(26)	查询选修过教师“达尔文”所授的全部课程的学生姓名。
declare @tname varchar(8)
set @tname=(select top 1 tname from teachers order by NEWID())
;with tmp as(select sname,cno from students a join stucourses b on a.sno=b.sno 
where cno in (select cno from teacnos a join teachers b on a.tno=b.tno where tname=@tname))
select sname from tmp group by sname having COUNT(*)=(select COUNT(*) from teacnos a join teachers b on a.tno=b.tno where tname=@tname)
go
--(27)	查询哪些学生选修的课程中其前修课程还没有选修过。
select sno,sname from students where sno in
(select sno from stucourses a join courses b on a.cno=b.cno
join courses c on b.cno=c.cno where b.pcno=c.cno group by sno)
go
--(28)	查询哪些学生至少选修了学号为“S105401F”这个学生选修的全部课程。
declare @sno varchar(8)
set @sno=(select top 1 sno from students order by NEWID())
select sno from students as p where not exists
(select 1 from stucourses a where a.sno=@sno and not exists(
 select 1 from stucourses b where p.sno=b.sno and a.cno=b.cno))
 and sno<>@sno
 go
--(29)	查询哪些学生与学号为“S105401F”的学生选修了完全相同的课程。
declare @sno varchar(8)
set @sno=(select top 1 sno from students order by NEWID())
select sno from stucourses where sno not in(select sno from stucourses 
where cno not in(select cno from stucourses where sno=@sno))
and sno<>@sno
group by sno
having COUNT(*)=(select COUNT(*) from stucourses where sno=@sno)
go
--(30)	查询哪些学生没有选修过教师“达尔文”所授的任何一门课程。
declare @tname varchar(8)
set @tname=(select top 1 tname from teachers order by NEWID())
select sno from stucourses where cno not in(select cno from teacnos a join teachers b on a.tno=b.tno where tname=@tname)
go
--(31)	查询哪些学生至少选修了教师“达尔文”所授的两门不同的课程。
declare @tname varchar(8)
set @tname=(select top 1 tname from teachers order by NEWID())
select sno from stucourses where cno in(select cno from teacnos a join teachers b on a.tno=b.tno where tname=@tname)
group by sno
having COUNT(*)>=2
go
--(32)	查询2011学年哪些老师授课们数最多。
;with tmp as(select tno,COUNT(*)as count,rank()over(order by count(*))as rank from teacnos
group by tno)
select tno,count from tmp where RANK=1
go
--(33)	查询2011学年哪些老师选修课学生选课人数最多。
;with tmp as(select a.cno,COUNT(*) as count from stucourses a join courses b on a.cno=b.cno
where ctype='B' group by a.cno)
select distinct tno from teacnos where cno=(
select cno from tmp where count=(select MAX(count) from tmp))
go
--(34)	查询哪些学生已经获得的必修课学分不少于150，选修课学分不少于100。
;with tmp as(select sno,SUM(score)as sum from courses a join stucourses b on a.cno=b.cno
and grade>=60 where ctype='A' group by sno having SUM(score)>1.5
union all
select sno,SUM(score)as sum from courses a join stucourses b on a.cno=b.cno
and grade>=60 where ctype='B' group by sno having SUM(score)>5)
select sno from tmp group by sno having COUNT(*)=2
go
--(35)	建立一个存储过程，输入一个学生的姓名，返回该学生全部必修课课程的平均成绩。
if(OBJECT_ID('myprocedure') is not null) drop procedure myprocedure
go
create procedure myprocedure @sname varchar(20),@x decimal(5,2) output
as
  select @x=AVG(grade) from stucourses a join students b on a.sno=b.sno
  where sname=@sname
  group by a.sno
go
declare @sname varchar(8)
set @sname=(select top 1 sname from students order by NEWID())
declare @x decimal(5,2)
exec myprocedure @sname,@x output
print @x
go
--(36)	建立一个存储过程，输入一门课程的编号以及要求查询成绩的区间（x~y)，输出该课程所有在该区间内的学生姓名，要求成绩从高到低排序。
if(OBJECT_ID('myprocedure') is not null) drop procedure myprocedure
go
create procedure myprocedure @cno varchar(5),@grade1 decimal(5,1),@grade2 decimal(5,1)
as
  declare @name varchar(1000)
  set @name='select sname from students a join stucourses b on a.sno=b.sno
  where cno='''+@cno+''' and grade>'+cast(@grade1 as varchar)+' and grade<'+cast(@grade2 as varchar)
  exec(@name)
go
declare @cno varchar(5)
set @cno=(select top 1 cno from courses order by NEWID())
exec myprocedure @cno,60,100
go
--(37)	建立一个存储过程，输入一个学生的学号，列出该学生最近这个学期的全部课程的成绩，并通过调用该存储过程，编写程序，输出所有学生最近这个学期全部课程的成绩。
if(OBJECT_ID('myprocedure') is not null) drop procedure myprocedure
go
create procedure myprocedure @sno varchar(8)
as
  declare @cno varchar(5),@grade decimal(5,1),@stuterm char(11)
  set @stuterm=(select top 1 stuterm from stucourses
      where sno=@sno order by stuterm desc)
  print @sno+space(5)+@stuterm
  declare mycursor1 cursor scroll for select cno,grade from stucourses
  where stuterm=@stuterm and sno=@sno
    open mycursor1
    fetch first from mycursor1 into @cno,@grade
    while @@FETCH_STATUS=0
    begin  
     print @cno+space(5)+cast(@grade as varchar)
     fetch next from mycursor1 into @cno,@grade
    end
    deallocate mycursor1
go

declare @x varchar(8)
declare mycursor cursor scroll for select sno from students
open mycursor
fetch next from mycursor into @x
while @@FETCH_STATUS=0
  begin
  exec myprocedure @x
  fetch next from mycursor into @x
  end
deallocate mycursor
go

--(38)	建立一个是用户定义表值函数，输入一个课程名称，输出该课程考试成绩最高的这些学生的姓名。
if(OBJECT_ID('myfunction') is not null) drop function myfunction
go
create function myfunction(@cname varchar(20))
returns @x table(sname varchar(20))
as
begin
declare @cno varchar(5)
insert into @x(sname) select sname from students where sno in (select sno from stucourses a join courses b on a.cno=b.cno 
where grade=(select MAX(grade) from stucourses where cno=@cno group by cno))
return
end
go

declare @cname varchar(8)
set @cname=(select top 1 cno from courses order by NEWID())
select * from dbo.myfunction(@cname)
go
--(39)	编写一个用户定义函数，要求：输入一个课程编码，根据成绩表，计算并返回该课程全部学生考试成绩的平均值与及格率，并通过调用该函数，编写一个存储过程计算列出课程表中全部课程考试成绩的平均值与及格率。
if(OBJECT_ID('myfunction') is not null) drop function myfunction
go
create function myfunction(@cno varchar(5))
returns varchar(100)
as
begin
  declare @avg decimal(5,2),@rate decimal(4,1),@r varchar(100)
  select @avg=avg(grade) from stucourses where cno=@cno
  select @rate=1.0*(select count(*) from stucourses where grade>=60 and cno=@cno)/count(*) from stucourses where cno=@cno
  set @r=str(@avg,10,2)+space(2)+str(@rate,10,2)
  return(@r)
end
go

select cno,mygrade.dbo.myfunction(cno) from courses

if(OBJECT_ID('myprocedure') is not null) drop procedure myprocedure
go
create procedure myprocedure
as
  declare @charge varchar(1000)
  set @charge='select cno,mygrade.dbo.myfunction(cno) from courses'
  exec(@charge)
go
exec myprocedure
go
--(40)	编写一个用户定义函数，输入一个学号和学年号，计算返回该学生该学年的综合智育成绩，计算公式如下16题所示。要求借助该用户定义函数，使用UPDATE语句，计算每个学生每个学年的综合智育成绩。
if(OBJECT_ID('myfunction') is not null) drop function myfunction
go
create function myfunction(@sno varchar(20),@date varchar(11))
returns decimal
as
begin
declare @x varchar(100),@y varchar(100),@t decimal(12,2)
select @x=cast(sum(grade)/(select COUNT(*) from courses where ctype='A') as char(100))
from courses a join stucourses b on a.cno=b.cno 
where ctype='A' and sno=@sno and stuterm=@date
 select @y=cast(case
 when grade between 90.01 and 100.00 then 4
 when grade between 80.01 and 90.00  then 3
 when grade between 70.01 and 80.00  then 2
 when grade between 60.00 and 70.00  then 1
 else 0 end as char(100))
 from stucourses a join courses b on a.cno=b.cno and ctype='B'
 where sno=@sno and stuterm=@date
 if(@x is null) set @x=0
 if(@y is null) set @y=0
 set @t=cast(@x as decimal(12,2))+cast(@y as decimal(12,2))
return(@t)
end
go
update students set two008=(select sum(mygrade.dbo.myfunction(sno,stuterm)) from stucourses where sno=students.sno)
go
--(41)	编写一个存储过程，输入一个学年号和学生学号，返回该学生在该学年中综合智育成绩的排名名次。
if(OBJECT_ID('myprocedure') is not null) drop procedure myprocedure
go
create procedure myprocedure @date varchar(11),@sno varchar(8)
as
  select COUNT(*)+1 from students a join stucourses b on a.sno=b.sno where stuterm=@date
  group by a.sno,two008
  having two008>(select two008 from students where sno=@sno)
go
declare @sno varchar(8),@stuterm varchar(11)
set @sno=(select top 1 sno from stucourses order by NEWID())
set @stuterm=(select top 1 stuterm from stucourses order by NEWID())
exec myprocedure @stuterm,@sno
go
--(42)	编写一个用户定义表值函数，输入一个学号与学期号，输出返回该学生该学期的全部课程及其成绩。
if(OBJECT_ID('myfunction') is not null) drop function myfunction
go
create function myfunction(@sno varchar(8),@date char(11))
returns table
as
  return(select cno,grade from stucourses 
  where sno=@sno and stuterm=@date)
go
declare @sno varchar(8),@stuterm varchar(11)
set @sno=(select top 1 sno from stucourses order by NEWID())
set @stuterm=(select top 1 @stuterm from stucourses order by NEWID())
select * from dbo.myfunction(@sno,@stuterm)
go
--(43)	创建一个存储过程，输入一门课程的编号，利用递归CTE，输出该课程的所有前修课程（包括前修课程的前修课程）。
if(OBJECT_ID('myprocedure') is not null) drop procedure myprocedure
go
create procedure myprocedure @cno varchar(5)
as
  ;with tmp as(select cno,pcno from courses where cno=@cno
  union all
  select a.cno,a.pcno from courses a join tmp b on a.cno=b.pcno)
  select * from tmp
go
declare @cno varchar(8)
set @cno=(select top 1 cno from courses order by NEWID())
exec myprocedure @cno
go
/*
(44)	建立一个存储过程，输入一门课程的编号以及要求查询成绩的区间（x~y)，使用游标逐条输出该课程所有在该区间内的学生姓名，要求成绩从高到低排序，输出格式如下：
      课程编号：xxx      课程名称：xxx 
----------------------------------------------------------------
 学号      姓名      成绩 
  x1      xx1      xxx1
  x2      xx2      xxx2
*/
if(OBJECT_ID('myprocedure') is not null) drop procedure myprocedure
go
create procedure myprocedure @cno varchar(5),@grade1 decimal(5,2),@grade2 decimal(5,2)
as
declare @cname varchar(20),@sno varchar(8),@sname varchar(20),@grade decimal(5,2)
select @cname=cname from courses where cno=@cno
print space(6)+'课程编号：'+@cno+space(6)+'课程名称：'+@cname
print replicate('-',60)
print '学号'+space(10)+'姓名'+space(8)+'成绩'
declare mycursor cursor scroll for select a.sno,sname,grade from students a
join stucourses b on a.sno=b.sno
where cno=@cno and grade between @grade1 and @grade2
order by grade desc
open mycursor
fetch first from mycursor into @sno,@sname,@grade
while @@FETCH_STATUS=0
begin
 print @sno+space(6)+@sname+space(6)+cast(@grade as varchar)
 fetch next from mycursor into @sno,@sname,@grade
end
deallocate mycursor
go
declare @cno varchar(8)
set @cno=(select top 1 cno from courses order by NEWID())
execute myprocedure @cno,60,100
go
/*
(45)	编写一个存储过程，要求：输入一个学生的学号，按以下格式输出该学生全部课程的成绩单。要求使用cursor，输出格式如下：
学号：×××××××××                                 姓名：×××
序号	课程名称	课程性质	开课学期	成绩	排名
1	高等数学	必修课	2010-1	89	12
2	英语	必修课	2010-1	75	23
	……				
20	数据库技术	必修课	2011-2	85	8
21	物流管理	选修课	2011-2	92	1
……					
*/
if(OBJECT_ID('myprocedure') is not null) drop procedure myprocedure
go
create procedure myprocedure @sno varchar(8)
as
  if(OBJECT_ID('#table1') is not null)drop table #table1
  declare @sname varchar(20),@rank1 int,@cname varchar(20),@ctype varchar(5),@stuterm varchar(11),@grade decimal(5,2),@rank int
  select @sname=sname from students where sno=@sno
  create table #table1(rank1 int identity(1,1),cno varchar(5),cname varchar(20),ctype varchar(5),stuterm varchar(11),grade decimal(5,2),rate int)
  insert into #table1(cno,cname,ctype,stuterm,grade)select a.cno,cname,ctype,stuterm,grade 
  from courses a join stucourses b on a.cno=b.cno where sno=@sno
  ;with tmp1 as(select sno,cno,RANK()over(partition by cno order by grade) as rank2 from stucourses)
  update #table1 set rate=(select rank2 from tmp1 where cno=#table1.cno and sno=@sno)
  print '学号：'+@sno+space(20)+'姓名：'+@sname
  print '序号'+space(2)+'课程名称'+space(5)+'课程性质'+space(5)+'开课学期'+space(7)+'成绩'+space(5)+'排名'
  declare mycursor cursor scroll for select rank1,cname,ctype,stuterm,grade,rate from #table1
  open mycursor
  fetch first from mycursor into @rank1,@cname,@ctype,@stuterm,@grade,@rank
  while @@FETCH_STATUS=0
  begin
    if(@ctype='A') set @ctype='必修课'
    if(@ctype='B') set @ctype='选修课'
    print cast(@rank1 as varchar)+space(5)+@cname+space(9)+@ctype+space(4)+@stuterm+space(6)+cast(@grade as varchar)+space(5)+convert(varchar,@rank,3)
    fetch next from mycursor into @rank1,@cname,@ctype,@stuterm,@grade,@rank
  end
 deallocate mycursor
go
declare @sno varchar(8)
set @sno=(select top 1 sno from students order by NEWID())
execute myprocedure @sno
go
/*
(46)	建立一个存储过程，输入一个学期号，利用游标按班级和学号的次序输出该学期全部学生的考试成绩，格式如下：
学期：*******
学号：×××××××××                姓名：×××
序号	课程名称	课程性质	成绩
1	高等数学	必修课	89
2	英语	必修课	75
	……		
20	数据库技术	必修课	85
21	物流管理	选修课	92
……			
及格门数：***，不及格门数：**，本学期获得总学分：**
*/
if(OBJECT_ID('myprocedure') is not null) drop procedure myprocedure
go
create procedure myprocedure @stuterm varchar(11)
as
declare @sno varchar(11),@sname varchar(20)
declare mycursor cursor scroll for select a.sno,sname from students a
join stucourses b on a.sno=b.sno where stuterm=@stuterm order by class,a.sno
open mycursor
fetch first from mycursor into @sno,@sname
  while @@FETCH_STATUS=0
  begin
    declare @rank int,@cname varchar(20),@ctype varchar(10),@grade decimal(5,2)
    declare @online int,@outline int,@score decimal(4,1)
    if(OBJECT_ID('tempdb..#table') is not null) drop table #table
    create table #table (rank int identity(1,1),cno varchar(5),cname varchar(20),ctype varchar(3),grade decimal(5,2))
    insert into #table(cno,cname,ctype,grade) select a.cno,cname,ctype,grade from courses a
    join stucourses b on a.cno=b.cno
    where sno=@sno and stuterm=@stuterm
    print '学期：'+@stuterm+char(13)+'学号：'+@sno+space(15)+'姓名：'+@sname
    print '序号'+space(3)+'课程名称'+space(5)+'课程性质'+space(5)+'成绩'
    declare mycursor1 cursor scroll for select rank,cname,ctype,grade from #table
    open mycursor1
    fetch next from mycursor1 into @rank,@cname,@ctype,@grade
    while @@FETCH_STATUS=0
    begin
     if(@ctype='A') set @ctype='必修课'
     if(@ctype='B') set @ctype='选修课'
     print cast(@rank as varchar)+space(8)+@cname+space(6)+@ctype+space(5)+cast(@grade as varchar)
     fetch next from mycursor1 into @rank,@cname,@ctype,@grade
    end
    deallocate mycursor1
    set @online=(select COUNT(*) from #table where grade>=60)
    set @outline=(select COUNT(*) from #table where grade<60)
    set @score=(select SUM(score) from courses where cno in(select cno 
    from #table where grade>=60))
    print '及格门数:'+cast(@online as varchar)+space(2)+'不及格门数:'+cast(@outline as varchar)+space(5)
    +'本学期获得总学分：'+cast(@score as varchar)
    fetch next from mycursor into @sno,@sname
  end
deallocate mycursor
go
declare @stuterm varchar(11)
set @stuterm=(select top 1 stuterm from stucourses order by NEWID())
execute myprocedure @stuterm
go
--(47)	建立一个存储过程，输入一门课程的名称，利用游标而不直接利用函数，计算并返回该课程考试成绩的平均值与方差。
if(object_id('myprocedure') is not null) drop procedure myprocedure
go
create procedure myprocedure @sname varchar(50),@avg money output,@fc money output
as
declare @n int,@grade decimal(4,1),@sum decimal(4,1)
declare mycursor cursor scroll for select grade from stucourses a
join students b on a.sno=b.sno
where sname=@sname
open mycursor 
fetch first from mycursor into @grade
set @n=0
set @sum=0
while @@FETCH_STATUS=0
begin
  set @sum=@sum+@grade
  set @n=@n+1
  set @fc=power(@grade-@sum/@n,2)/@n
  set @avg=@sum/@n
  fetch next from mycursor into @grade
end
deallocate mycursor
go
declare @cname varchar(11)
set @cname=(select top 1 cname from courses order by NEWID())
declare @avg money,@fc money
execute myprocedure @cname,@avg output,@fc output
print 'AverageGrade:'+cast(@avg as varchar)+char(13)+'Variance:'+cast(@fc as varchar)
go
--(48)	创建一个带参数@start,@number的存储过程，利用游标，将表学生表中第@start行开始的共@number条记录拷贝到表mytable中去。
if(OBJECT_ID('myprocedure') is not null) drop procedure myprocedure
if(OBJECT_ID('mytable') is not null) drop table mytable
if(OBJECT_ID('mystudents') is not null) drop table mystudents
go
select * into mystudents from students
select top 0 sno,sname,gender,birthdate,class into mytable from mystudents
go
create procedure myprocedure @start int,@number int
as
  declare  @sno varchar(8),@sname varchar(20),@gender char(1),@birthdate date,@class varchar(20)
  declare @i int
  declare mycursor cursor scroll for select sno,sname,gender,birthdate,class from mystudents
  open mycursor
  fetch absolute @start from mycursor into @sno,@sname,@gender,@birthdate,@class
  set @i=1
  while @@FETCH_STATUS=0 and @i<=@number
  begin
    insert into mytable(sno,sname,gender,birthdate,class) values(@sno,@sname,@gender,@birthdate,@class)
    fetch next from mycursor into @sno,@sname,@gender,@birthdate,@class
    set @i=@i+1
  end
 deallocate mycursor
go
exec myprocedure 2,5
select * from mytable
go
--(49)	创建一个带参数@start,@number的存储过程，利用游标，将表学生表副本中第@start行开始的共@number条记录删除。
if(OBJECT_ID('myprocedure') is not null) drop procedure myprocedure
if(OBJECT_ID('mystudents') is not null) drop table mystudents
go
select * into mystudents from students
alter table mystudents 
add constraint mystudents_pk_sno primary key clustered(sno)
go
create procedure myprocedure @start int,@number int
as
  declare  @sno varchar(8),@sname varchar(20),@gender char(1),@birthdate date,@class varchar(20)
  declare @i int
  declare mycursor cursor scroll for select sno from mystudents
  open mycursor
  fetch absolute @start from mycursor into @sno
  set @i=1
  while @@FETCH_STATUS=0 and @i<=@number
  begin
    delete mystudents where current of mycursor
    fetch next from mycursor into @sno
    set @i=@i+1
  end
 deallocate mycursor
go
exec myprocedure 2,5
select * from mystudents
go
/*(50)	建立一个触发器，当课程表中插入一条记录时，触发器自动对该记录的正确性进行验证，并根据验证结果作出拒绝插入记录或予以提示警告等处理。记录正确性验证规则如下：
①课程编号长度必须为4；必修课课程的编码以大写字母’A’开头，选修课课程的编码以大写字母’B’开头，否则拒绝插入记录；
②必修课课程总门数不超过30门，否则予以提示警告。*/
if(OBJECT_ID('mytrigger') is not null) drop trigger mytrigger
go
create trigger mytrigger on courses for insert
as
begin
  declare @cno varchar(5),@error varchar(100)
  set @error=''
  select @cno=cno from insterted 
  if not exists(select 1 from courses where (datalength(@cno)=4))
    set @error=@error+char(13)+'Error1:Cno is bad!'
  if not exists (select 1 from courses where (ascii(left(@cno,1))<>ascii('A') and @cno like 'A%') or
  (ascii(left(@cno,1))<>ascii('B') and @cno like 'B%')) 
    set @error=@error+char(13)+'Error1:Cno is bad!'
  if(select count(*) from course where ctype='A')>30
    set @error=@error+char(13)+'Error2:The number of line is too much!'
  if @error<>''
    begin
      print @error
      rollback transaction
    end
end
go

