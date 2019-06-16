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


--(1)	����ѧ���ɼ����е�������ʾȫ��ѧ���ĳɼ���Ҫ�󰴰༶��ѧ�ŵĴ�����ʾ����������а���ѧ�������Ϳγ����ƣ���ʹ�����ı��⡣
select b.sname 'ѧ������', c.cname '�γ�����', a.grade '�ɼ�' from stucourses a 
join students b on a.sno = b.sno
join courses c on a.cno = c.cno order by b.class,a.sno asc
go
--(2)	����ѧ��������Ϣ����ɼ����е����ݣ���ʾ����Ϊx�����ѧ����һѧ�ڵ�ȫ���γ̳ɼ���
-- todo
declare @sname varchar(8)
set @sname=(select top 1 sname from students order by NEWID())
select a.cno, a.grade from stucourses a
join students b on a.sno=b.sno
where b.sname=@sname and a.stuterm like '%1' 
go
--(3)	���ݿγ̱���ɼ����е����ݣ���ʾ����γ�����Ϊx.�ĸÿγ̵�ƽ���ɼ���������������
declare @cname varchar(8)
set @cname=(select top 1 cname from courses order by NEWID())
select b.cname, avg(a.grade) as avg from stucourses a 
join courses b on a.cno = b.cno 
where b.cname = @cname group by b.cname
select 100*(select COUNT(*) from courses a
join stucourses b on a.cno=b.cno
where cname=@cname and grade>=60)/(select COUNT(*) from students) as rate
go
--(4)	���ݿγ̱���ɼ����е����ݣ���ʾѧ��Ϊx�����ѧ��������ѧ�����õ���ѧ������
declare @sno varchar(5)
set @sno=(select top 1 sno from students order by NEWID())
select SUM(score) as sum from courses a join stucourses b on a.cno=b.cno 
where sno=@sno and grade>=60 and stuterm=(select top 1 stuterm from stucourses
where sno=@sno order by stuterm desc)
go
--(5)	���ݸ������ݣ��г�������ѧ����Щѧ��ѡ�޵Ŀγ�������࣬Ҫ���г�������
--CTE
;with tmp as (select a.sno, b.sname, count(*) as count, RANK()over(order by count(*) desc) as rank
 from stucourses a 
 join students b on a.sno = b.sno
 join courses c on a.cno = c.cno
 where a.stuterm = (select top 1 stuterm from stucourses order by stuterm desc)
 group by a.sno, b.sname)
 select * from tmp where rank=1
go
--(6)	���ݸ������ݣ��г�������ѧ����Щѧ������ѡ�����Ż��������ϵ�ѡ�޿γ̣�Ҫ���г�������
;with tmp as(select  a.sno,sname,count(*) as count from students a 
join stucourses b on a.sno=b.sno
join courses c on c.cno=b.cno
where stuterm=(select top 1 stuterm from stucourses order by stuterm desc)
and ctype='B'
group by a.sno,sname)
select * from tmp where count>=2
go
--(7)	���ݿγ̱���ɼ������ݣ��г���Щѡ�޿γ�ѧ��ѡ�޵�ѧ��������ࡣ
;with tmp as(select a.cno,count(*) as count,RANK()over(order by count(*) desc) as rank from courses a join stucourses b on a.cno=b.cno
where ctype='B' group by a.cno)
select * from tmp where rank=1
go
--(8)	�ֱ��г��γ�����ΪX�����ſγ̿��Գɼ�����ǰ5λ���5λ��ѧ��������
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
--(9)	�г����޿γ̳ɼ����������ۼ�ѧ�ֳ���15�ֵ���Щѧ����������
select sname from students where sno in 
(select a.sno from stucourses a 
join courses b on a.cno = b.cno where b.ctype='B' and a.grade < 60 
group by a.sno having SUM(b.score) >15)
go
--(10)	�г��γ�����Ϊx�����ſο��Գɼ�ƽ������ߵİ༶��
declare @cname varchar(8)
set @cname=(select top 1 cname from courses order by NEWID())
;with tmp as(select b.class as class,avg(grade) as avg from stucourses a join courses d on a.cno=d.cno
join students b on a.sno=b.sno
where cname=@cname
group by b.class)
select class,avg from tmp where avg=(select MAX(avg) from tmp)
go
--(11)	�ְ༶���Ա����������ѧ��ȫ�����޿ογ̵�ƽ�����Գɼ���
select cname,b.class,b.gender,avg(grade) as avg from stucourses a join courses d on a.cno=d.cno
join students b on a.sno=b.sno
where ctype='A'
group by cname,b.class,b.gender
go
--(12)	���ݳɼ����е����ݣ�����ѧ��������Ϣ����ÿ��ѧ��ÿ��ѧ�ڵ�ƽ�����Գɼ���
select sno,stuterm,avg(grade) as avg from stucourses group by sno,stuterm
go
--(13)	�г���2011-1ѧ���и����༶ƽ�����Գɼ�����ǰ5λѧ����������Ҫ�󰴸��ఴ�ɼ�����
;with tmp as(select class,a.sno as sno,sname,AVG(grade)as avg1,
RANK()over(PARTITION by class order by AVG(grade)) as rank from students a join stucourses b on a.sno=b.sno 
where stuterm='2011-2012-1' group by class,a.sno,sname)
select * from tmp where rank<=5
go
--(14)	���ɼ�����ѡ�޿εĳɼ����弶�ƣ��š������С����񡢲�������ʽ������� 
select *,'pricearange'=case
 when grade between 90.01 and 100.00 then '��'
 when grade between 80.01 and 90.00  then '��'
 when grade between 70.01 and 80.00  then '��'
 when grade between 60.00 and 70.00  then '����'
 else '������' end
from stucourses a join courses b on a.cno=b.cno and ctype='B'
go
--(15)	���ɼ����б��޿γɼ���ʵ�ʷ��������ͬʱѡ�޿εĳɼ����弶����ʽ�����
select a.cno,'pricearange'=case
 when grade between 90.01 and 100.00 then '��'
 when grade between 80.01 and 90.00  then '��'
 when grade between 70.01 and 80.00  then '��'
 when grade between 60.00 and 70.00  then '����'
 else '������' end
from stucourses a join courses b on a.cno=b.cno and ctype='B'
union all
select a.cno,cast(grade as CHAR) from stucourses a 
join courses b on a.cno=b.cno and ctype='A'
go
--(16)	��ѧ���������4���зֱ�洢2008~2011�ĸ�ѧ���ѧ���ۺ������ɼ�������ϵͳ���ж���4���Ƿ��Ѿ����ڣ�����Ѿ����ڣ��򲻱���ӣ�����֪ÿ��ѧ��ÿ��ѧ����ۺ������ɼ����㹫ʽ���£�
--�ۺ������ɼ�=��ѧ��ȫ�����޿γɼ���ƽ����+ÿ��ѡ�޿γɼ��ĵ���ֵ������ѡ�޿γɼ�����ֵ�涨Ϊ�� >=90�֣���4�֣�80��89�֣���3�֣�70��79�֣���2�֣�60��69�֣���1�֣�<60�֣���0�֡�
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
--(17)	��ѧ���������4���зֱ�洢2008~2011�ĸ�ѧ���ѧ���ۺ������ɼ����������Ϲ�ʽʹ������Ӳ�ѯ��UPDATE������ÿ��ѧ��ÿ��ѧ����ۺ������ɼ���
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
--(18)	���ݸ���������ǰ��ļ�������ͳ���г���2011ѧ���ۺ������ɼ�����ǰ40%���Ҹ�ѧ��ÿ�ſγ̳ɼ��������ѧ���������� 
select top 40 percent sname,two011 from students a join stucourses b on a.sno=b.sno
join courses c on b.cno=c.cno
where grade>=60 and stuterm like '2011%' group by a.sno,sname,two011
order by two011
go
--(19)	��ѯÿ��ѧ����ƽ���ɼ����ڰ༶����ǰ30%��ѧ����������
;with tmp1 as(select a.sno,sname,class,stuterm,avg(grade)as avg,
rank()over(partition by class,stuterm order by avg(grade) desc) as rank
from students a 
join stucourses b on a.sno=b.sno
group by stuterm,class,a.sno,sname),
tmp2 as(select class,stuterm,MAX(avg)as max from tmp1 group by class,stuterm)
select sname from students where sno not in(select sno from tmp1 a join tmp2 b
on a.class=b.class and a.stuterm=b.stuterm where a.avg/b.max>0.3)
go
--(20)	��������Ϊx�����ѧ����2011-1ѧ��ƽ���ɼ��ڰ༶�е��������Ρ�
declare @sname varchar(8)
set @sname=(select top 1 sname from students order by NEWID())
;with tmp as(select sname,class,AVG(grade) as avg from students a join stucourses b on a.sno=b.sno
and stuterm='2011-2012-1' 
group by class,sname)
select COUNT(*) from tmp where avg>(select avg from tmp where sname=@sname)
and class=(select class from tmp where sname=@sname) 
--(21)	��ѯѡ�޹������ݿ⡱�͡����ݽṹ�������ſγ̵�ѧ��������
declare @cname1 varchar(8),@cname2 varchar(8)
set @cname1=(select top 1 cname from courses order by NEWID())
set @cname2=(select top 1 cname from courses order by NEWID())
;with tmp as(select sname from students a join stucourses b on a.sno=b.sno
join courses c on c.cno=b.cno
where cname=@cname1 or cname=@cname2)
select sname from tmp  group by sname having COUNT(*)>1
go
--(22)	��ѯû��ѡ�޹������ݿ⡱���ſγ̵�ѧ��������
declare @cname varchar(8)
set @cname=(select top 1 cname from courses order by NEWID())
select sname from students where sno not in (select a.sno from students a join stucourses b on a.sno=b.sno
join courses c on c.cno=b.cno
where cname=@cname)
go
--(23)	��ѯѡ�޹������ݿ⡱��û��ѡ�������пε�ѧ��������
declare @cname1 varchar(8),@cname2 varchar(8)
set @cname1=(select top 1 cname from courses order by NEWID())
select @cname2=cname from courses where cno=(select pcno from courses where cname=@cname1)
select sname from students where sno in (select a.sno from students a join stucourses b on a.sno=b.sno
join courses c on c.cno=b.cno and cname=@cname1
where a.sno not in(select a.sno from students a join stucourses b on a.sno=b.sno
join courses c on c.cno=b.cno and cname=@cname2))
go
--(24)	��ѯ���пγ̳ɼ�ȫ�������ѧ��������
select distinct sname from students a join stucourses b on a.sno=b.sno
where grade>=60
go
--(25)	��ѯÿ��ѧ�ڱ��޿γɼ�ȫ�������ѧ��������
select distinct sname from students a join stucourses b on a.sno=b.sno
join courses c on c.cno=b.cno
where grade>=60 and ctype='A'
go
--(26)	��ѯѡ�޹���ʦ������ġ����ڵ�ȫ���γ̵�ѧ��������
declare @tname varchar(8)
set @tname=(select top 1 tname from teachers order by NEWID())
;with tmp as(select sname,cno from students a join stucourses b on a.sno=b.sno 
where cno in (select cno from teacnos a join teachers b on a.tno=b.tno where tname=@tname))
select sname from tmp group by sname having COUNT(*)=(select COUNT(*) from teacnos a join teachers b on a.tno=b.tno where tname=@tname)
go
--(27)	��ѯ��Щѧ��ѡ�޵Ŀγ�����ǰ�޿γ̻�û��ѡ�޹���
select sno,sname from students where sno in
(select sno from stucourses a join courses b on a.cno=b.cno
join courses c on b.cno=c.cno where b.pcno=c.cno group by sno)
go
--(28)	��ѯ��Щѧ������ѡ����ѧ��Ϊ��S105401F�����ѧ��ѡ�޵�ȫ���γ̡�
declare @sno varchar(8)
set @sno=(select top 1 sno from students order by NEWID())
select sno from students as p where not exists
(select 1 from stucourses a where a.sno=@sno and not exists(
 select 1 from stucourses b where p.sno=b.sno and a.cno=b.cno))
 and sno<>@sno
 go
--(29)	��ѯ��Щѧ����ѧ��Ϊ��S105401F����ѧ��ѡ������ȫ��ͬ�Ŀγ̡�
declare @sno varchar(8)
set @sno=(select top 1 sno from students order by NEWID())
select sno from stucourses where sno not in(select sno from stucourses 
where cno not in(select cno from stucourses where sno=@sno))
and sno<>@sno
group by sno
having COUNT(*)=(select COUNT(*) from stucourses where sno=@sno)
go
--(30)	��ѯ��Щѧ��û��ѡ�޹���ʦ������ġ����ڵ��κ�һ�ſγ̡�
declare @tname varchar(8)
set @tname=(select top 1 tname from teachers order by NEWID())
select sno from stucourses where cno not in(select cno from teacnos a join teachers b on a.tno=b.tno where tname=@tname)
go
--(31)	��ѯ��Щѧ������ѡ���˽�ʦ������ġ����ڵ����Ų�ͬ�Ŀγ̡�
declare @tname varchar(8)
set @tname=(select top 1 tname from teachers order by NEWID())
select sno from stucourses where cno in(select cno from teacnos a join teachers b on a.tno=b.tno where tname=@tname)
group by sno
having COUNT(*)>=2
go
--(32)	��ѯ2011ѧ����Щ��ʦ�ڿ�������ࡣ
;with tmp as(select tno,COUNT(*)as count,rank()over(order by count(*))as rank from teacnos
group by tno)
select tno,count from tmp where RANK=1
go
--(33)	��ѯ2011ѧ����Щ��ʦѡ�޿�ѧ��ѡ��������ࡣ
;with tmp as(select a.cno,COUNT(*) as count from stucourses a join courses b on a.cno=b.cno
where ctype='B' group by a.cno)
select distinct tno from teacnos where cno=(
select cno from tmp where count=(select MAX(count) from tmp))
go
--(34)	��ѯ��Щѧ���Ѿ���õı��޿�ѧ�ֲ�����150��ѡ�޿�ѧ�ֲ�����100��
;with tmp as(select sno,SUM(score)as sum from courses a join stucourses b on a.cno=b.cno
and grade>=60 where ctype='A' group by sno having SUM(score)>1.5
union all
select sno,SUM(score)as sum from courses a join stucourses b on a.cno=b.cno
and grade>=60 where ctype='B' group by sno having SUM(score)>5)
select sno from tmp group by sno having COUNT(*)=2
go
--(35)	����һ���洢���̣�����һ��ѧ�������������ظ�ѧ��ȫ�����޿ογ̵�ƽ���ɼ���
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
--(36)	����һ���洢���̣�����һ�ſγ̵ı���Լ�Ҫ���ѯ�ɼ������䣨x~y)������ÿγ������ڸ������ڵ�ѧ��������Ҫ��ɼ��Ӹߵ�������
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
--(37)	����һ���洢���̣�����һ��ѧ����ѧ�ţ��г���ѧ��������ѧ�ڵ�ȫ���γ̵ĳɼ�����ͨ�����øô洢���̣���д�����������ѧ��������ѧ��ȫ���γ̵ĳɼ���
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

--(38)	����һ�����û������ֵ����������һ���γ����ƣ�����ÿγ̿��Գɼ���ߵ���Щѧ����������
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
--(39)	��дһ���û����庯����Ҫ������һ���γ̱��룬���ݳɼ������㲢���ظÿγ�ȫ��ѧ�����Գɼ���ƽ��ֵ�뼰���ʣ���ͨ�����øú�������дһ���洢���̼����г��γ̱���ȫ���γ̿��Գɼ���ƽ��ֵ�뼰���ʡ�
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
--(40)	��дһ���û����庯��������һ��ѧ�ź�ѧ��ţ����㷵�ظ�ѧ����ѧ����ۺ������ɼ������㹫ʽ����16����ʾ��Ҫ��������û����庯����ʹ��UPDATE��䣬����ÿ��ѧ��ÿ��ѧ����ۺ������ɼ���
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
--(41)	��дһ���洢���̣�����һ��ѧ��ź�ѧ��ѧ�ţ����ظ�ѧ���ڸ�ѧ�����ۺ������ɼ����������Ρ�
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
--(42)	��дһ���û������ֵ����������һ��ѧ����ѧ�ںţ�������ظ�ѧ����ѧ�ڵ�ȫ���γ̼���ɼ���
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
--(43)	����һ���洢���̣�����һ�ſγ̵ı�ţ����õݹ�CTE������ÿγ̵�����ǰ�޿γ̣�����ǰ�޿γ̵�ǰ�޿γ̣���
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
(44)	����һ���洢���̣�����һ�ſγ̵ı���Լ�Ҫ���ѯ�ɼ������䣨x~y)��ʹ���α���������ÿγ������ڸ������ڵ�ѧ��������Ҫ��ɼ��Ӹߵ������������ʽ���£�
      �γ̱�ţ�xxx      �γ����ƣ�xxx 
----------------------------------------------------------------
 ѧ��      ����      �ɼ� 
  x1      xx1      xxx1
  x2      xx2      xxx2
*/
if(OBJECT_ID('myprocedure') is not null) drop procedure myprocedure
go
create procedure myprocedure @cno varchar(5),@grade1 decimal(5,2),@grade2 decimal(5,2)
as
declare @cname varchar(20),@sno varchar(8),@sname varchar(20),@grade decimal(5,2)
select @cname=cname from courses where cno=@cno
print space(6)+'�γ̱�ţ�'+@cno+space(6)+'�γ����ƣ�'+@cname
print replicate('-',60)
print 'ѧ��'+space(10)+'����'+space(8)+'�ɼ�'
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
(45)	��дһ���洢���̣�Ҫ������һ��ѧ����ѧ�ţ������¸�ʽ�����ѧ��ȫ���γ̵ĳɼ�����Ҫ��ʹ��cursor�������ʽ���£�
ѧ�ţ�������������������                                 ������������
���	�γ�����	�γ�����	����ѧ��	�ɼ�	����
1	�ߵ���ѧ	���޿�	2010-1	89	12
2	Ӣ��	���޿�	2010-1	75	23
	����				
20	���ݿ⼼��	���޿�	2011-2	85	8
21	��������	ѡ�޿�	2011-2	92	1
����					
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
  print 'ѧ�ţ�'+@sno+space(20)+'������'+@sname
  print '���'+space(2)+'�γ�����'+space(5)+'�γ�����'+space(5)+'����ѧ��'+space(7)+'�ɼ�'+space(5)+'����'
  declare mycursor cursor scroll for select rank1,cname,ctype,stuterm,grade,rate from #table1
  open mycursor
  fetch first from mycursor into @rank1,@cname,@ctype,@stuterm,@grade,@rank
  while @@FETCH_STATUS=0
  begin
    if(@ctype='A') set @ctype='���޿�'
    if(@ctype='B') set @ctype='ѡ�޿�'
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
(46)	����һ���洢���̣�����һ��ѧ�ںţ������α갴�༶��ѧ�ŵĴ��������ѧ��ȫ��ѧ���Ŀ��Գɼ�����ʽ���£�
ѧ�ڣ�*******
ѧ�ţ�������������������                ������������
���	�γ�����	�γ�����	�ɼ�
1	�ߵ���ѧ	���޿�	89
2	Ӣ��	���޿�	75
	����		
20	���ݿ⼼��	���޿�	85
21	��������	ѡ�޿�	92
����			
����������***��������������**����ѧ�ڻ����ѧ�֣�**
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
    print 'ѧ�ڣ�'+@stuterm+char(13)+'ѧ�ţ�'+@sno+space(15)+'������'+@sname
    print '���'+space(3)+'�γ�����'+space(5)+'�γ�����'+space(5)+'�ɼ�'
    declare mycursor1 cursor scroll for select rank,cname,ctype,grade from #table
    open mycursor1
    fetch next from mycursor1 into @rank,@cname,@ctype,@grade
    while @@FETCH_STATUS=0
    begin
     if(@ctype='A') set @ctype='���޿�'
     if(@ctype='B') set @ctype='ѡ�޿�'
     print cast(@rank as varchar)+space(8)+@cname+space(6)+@ctype+space(5)+cast(@grade as varchar)
     fetch next from mycursor1 into @rank,@cname,@ctype,@grade
    end
    deallocate mycursor1
    set @online=(select COUNT(*) from #table where grade>=60)
    set @outline=(select COUNT(*) from #table where grade<60)
    set @score=(select SUM(score) from courses where cno in(select cno 
    from #table where grade>=60))
    print '��������:'+cast(@online as varchar)+space(2)+'����������:'+cast(@outline as varchar)+space(5)
    +'��ѧ�ڻ����ѧ�֣�'+cast(@score as varchar)
    fetch next from mycursor into @sno,@sname
  end
deallocate mycursor
go
declare @stuterm varchar(11)
set @stuterm=(select top 1 stuterm from stucourses order by NEWID())
execute myprocedure @stuterm
go
--(47)	����һ���洢���̣�����һ�ſγ̵����ƣ������α����ֱ�����ú��������㲢���ظÿγ̿��Գɼ���ƽ��ֵ�뷽�
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
--(48)	����һ��������@start,@number�Ĵ洢���̣������α꣬����ѧ�����е�@start�п�ʼ�Ĺ�@number����¼��������mytable��ȥ��
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
--(49)	����һ��������@start,@number�Ĵ洢���̣������α꣬����ѧ�������е�@start�п�ʼ�Ĺ�@number����¼ɾ����
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
/*(50)	����һ�������������γ̱��в���һ����¼ʱ���������Զ��Ըü�¼����ȷ�Խ�����֤����������֤��������ܾ������¼��������ʾ����ȴ�����¼��ȷ����֤�������£�
�ٿγ̱�ų��ȱ���Ϊ4�����޿ογ̵ı����Դ�д��ĸ��A����ͷ��ѡ�޿ογ̵ı����Դ�д��ĸ��B����ͷ������ܾ������¼��
�ڱ��޿ογ�������������30�ţ�����������ʾ���档*/
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

