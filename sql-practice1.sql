
create table class_grade(gid int primary key auto_increment,
						gname char(3) not null
						)engine=innodb charset=utf8;

insert into class_grade(gname) values('一年级'),
									 ('二年级'),
									 ('三年级'),
									 ('四年级'),
									 ('五年级');						


						
create table class(cid int primary key auto_increment,
					caption char(4) not null,
					grade_id int,
					constraint fk_grade_class foreign key(grade_id) references class_grade(gid)
					on update cascade on delete cascade
					)engine=innodb charset=utf8;
					
insert into class(caption,grade_id) values('一年一班',1),
										  ('一年二班',1),
										  ('一年三班',1),
									      ('一年四班',1),
										  ('一年五班',1),
										  ('二年一班',2),
										  ('二年二班',2),
										  ('三年一班',3),
										  ('三年二班',3),
										  ('四年一班',4),
										  ('五年一班',5);
						
					
					
					
create table student(sid int primary key auto_increment,
					sname char(24) not null,
					gender enum('男','女') default '男',
					class_id int,
					constraint fk_class_student foreign key(class_id) references class(cid)
					on update cascade
					on delete cascade
					)engine=innodb charset=utf8;
		
insert into student(sname,gender,class_id) values('乔丹','女',1),
('艾弗森','女',1),('科比','男',2),('c罗','男',3),('张三丰','男',4),('乔丹','男',2);		
					
					
					
create table teacher(tid int primary key auto_increment,
					tname char(24) not null
					)engine=innodb charset=utf8;
	
insert into teacher(tname) values('张三'),('李四'),('王五'),('小刚');	
					
create table course(cid int primary key auto_increment,
					cname char(2),
					teacher_id int,
					constraint fk_c_teacher foreign key(teacher_id) references teacher(tid)
					on update cascade
					on delete cascade
					)engine=innodb charset=utf8;
					
insert into course(cname,teacher_id) values('生物',1),
										   ('体育',1),
										   ('物理',2),
										   ('化学',3),
										   ('语文',2);


					
create table score(sid int primary key auto_increment,
					student_id int not null,
					course_id int not null,
					score int,
					unique (student_id,course_id),
					constraint fk_s_student foreign key(student_id) references student(sid)
					on update cascade
					on delete cascade,
					constraint fk_s_course foreign key(course_id) references course(cid)
					on update cascade
					on delete cascade
					)engine=innodb charset=utf8;
					
insert into score(student_id,course_id,score) values(1,1,65),
(1,3,61),(1,2,59),(1,4,60),(2,2,99),(2,3,55),(2,1,72),(2,4,59),(3,4,89),(4,3,50),(4,2,99);


					
create table teach2cls(tcid int primary key auto_increment,
						tid int not null,
						cid int not null,
						unique (tid,cid),
						constraint fk_t_teacher foreign key(tid) references teacher(tid)
						on update cascade
						on delete cascade,
						constraint fk_t_class foreign key(cid) references class(cid)
						on update cascade
						on delete cascade
						)engine=innodb charset=utf8;
	
insert into teach2cls(tid,cid) values(1,1),(1,2),(2,1),(3,2);	
						

2.
select count(sid) as '学生总人数' from student;						

3.
select sid,sname,cname,score from 					
(select distinct s1.student_id,s1.course_id,s1.score from score as s1,score as s2 
where 
s1.student_id = s2.student_id and s1.score >= 60 and s2.score >= 60 and 
s1.course_id in (select cid from course where cname='生物' or cname='物理')) as t1
inner join student on t1.student_id = student.sid
inner join course on t1.course_id = course.cid;

4.
select gname,group_concat(caption),count(cid) as '班级数' from class_grade 
inner join class on grade_id=gid 
group by gname order by count(cid) desc limit 3 ;
					
5.
select * from student
inner join (select student_id,avg(score) as avg_score from score group by student_id 
having avg(score) in (
(select avg(score) as max_avg from score group by student_id order by avg(score) desc limit 1),
(select avg(score) as min_avg from score group by avg(score) asc limit 1)
)
)as t1 on student.sid=t1.student_id;


select sid,sname,avg_score as '平均成绩' from student
inner join (
select student_id,avg(score)as avg_score from score group by student_id
having avg(score) in (
(select max(avg_score) from (select avg(score)as avg_score from score group by student_id) as t1),
(select min(avg_score) from (select avg(score)as avg_score from score group by student_id) as t1)
)
) as t1 on student.sid=t1.student_id;


6.
select gname,count(sid) as '人数' from student
inner join class on class_id=cid
inner join class_grade on grade_id=gid
group by gname;

7.
select student.sid,sname,count(score.sid) as '选课数',avg(score) as '平均成绩' from student 
inner join score on student_id=student.sid
group by student_id;

8.
select * from student 
inner join score on student_id=student.sid
inner join course on cid=course_id
where student.sid=1 and score in (
(select max(score) from score where student_id=1),
(select min(score) from score where student_id=1)
);


9.
select tname,count(teacher.tid) as '个数',count(teach2cls.cid) as '班级数' from teacher
inner join teach2cls on teach2cls.tid=teacher.tid
where tname like '李%';

10.
select gid,gname from class 
inner join class_grade on grade_id=gid
group by grade_id having count(cid)<5;


11.
select cid,caption,gname,
case 
	when gid between 1 and 2 then '低'
	when gid=3 then '中'
	when gid=4 then '高' 
	else 0 end 
	as '年纪级别'
from class
inner join class_grade on grade_id=gid;


12.
select student_id,sname,count(tid) as '选课数' from teacher 
inner join course on teacher_id=tid
inner join score on course_id=cid
inner join student on student_id=student.sid
where tname='张三' group by student_id having count(tid)>=2;


13.
select tid,tname,count(tid) as '教授课程数',group_concat(cname) from teacher 
inner join course on teacher_id=tid
inner join score on course_id=cid
group by tid having count(tid)>2;


14.
select student.sid,student.sname from score
inner join student on student_id=student.sid
where course_id=1 or course_id=2 group by student_id having count(student.sid)>=2; 

15.
select * from class 
inner join teach2cls on teach2cls.cid=class.cid
where grade_id < 4;

16.
select student.sid,sname from score 
inner join student on student_id=student.sid 
where course_id in (
select cid from teacher
inner join course on teacher_id=tid 
where tname='张三') 
group by student_id having count(
student_id)=(select count(cid) from teacher
inner join course on teacher_id=tid 
where tname='张三');

17.
select teacher.tid,teacher.tname,group_concat(caption) from teacher
inner join teach2cls on teach2cls.tid=teacher.tid
inner join class on teach2cls.cid=class.cid
group by teacher.tid having count(teach2cls.cid)>=2;

18.
select student.sid,student.sname from score as s1,score as s2
inner join student on student.sid=s2.student_id
where s1.course_id=1 and s2.course_id=2 and s1.student_id=s2.student_id and s1.score>s2.score;

19.
select tid,tname from teacher 
where tid=(
select tid from teach2cls group by tid order by count(tid) desc limit 1); 

20.
select student.sid,sname from score
inner join student on student_id=student.sid 
where score<60 group by student_id;

21.
select student.sid,sname from score 
inner join student on student.sid=student_id
group by student_id having count(student_id)<(
select count(cid) from course);


22.
select sid,sname from student
where sid not in(1,(
select student_id from score
where student_id != 1 and course_id not in (
select course_id from score
where student_id=1) group by student_id));

23.
select student.sid,sname from score
inner join student on student.sid=student_id
where student_id != 1 and course_id in (
select course_id from score
where student_id=1) group by student_id;


24.
select student.sid,sname from score
inner join student on student.sid=student_id
where student_id != 2 and course_id in (
select course_id from score 
where student_id=2) group by student_id having count(student_id)=(select count(course_id) from score 
where student_id=2); 


25.
delete from score where course_id=(
select cid from teacher
inner join course on tid=teacher_id
where tname='张三');


26.
insert into score(student_id,course_id,score)
select t1.sid,2,t2.avg_score from (
select sid from student 
where sid not in (
select student_id from score 
 where course_id=2)
) as t1,
(select avg(score) as avg_score from score
 where  course_id=2) as t2;
 
 
27.
select 
s1.student_id,
(select score from score inner join course on cid=course_id where cname='生物' and s1.student_id= score.student_id) as '生物',
(select score from score inner join course on cid=course_id where cname='体育' and s1.student_id=score.student_id) as '体育',
(select score from score inner join course on cid=course_id where cname='物理' and s1.student_id=score.student_id) as '物理',
(select score from score inner join course on cid=course_id where cname='化学' and s1.student_id=score.student_id) as '化学',
count(course_id),
avg(score)
from score as s1
inner join student on student.sid=student_id
inner join course on cid=course_id
group by student_id order by avg(score) asc;

 
 
28.
select cid,max(score) as '最高分',min(score) as '最低分' from course
inner join score on course_id=course.cid
group by course_id;
 
 
29.
select cname,avg(score),
sum(case when score<60 then 0 else 1 end)/sum(1) as '及格率' 
 from course
inner join score on course_id=course.cid
group by course_id order by avg(score) asc,'及格率' desc;

 
30.
select cname,avg(score) as '平均分',tname from score
inner join course on course_id=cid
inner join teacher on teacher_id=teacher.tid
group by course_id order by avg(score) desc;
 
31.
select 
	score.sid,
	score.student_id,
	score.course_id,
	score.score,
	t1.first_score,
	t1.second_score,
	t1.third_score
from score inner join(
					select
						s1.sid,
						(select score from score as s2 where s1.course_id=s2.course_id order by score  desc limit 0,1) as first_score,
						(select score from score as s3 where s1.course_id=s3.course_id order by score  desc limit 1,1) as second_score,
						(select score from score as s4 where s1.course_id=s4.course_id order by score  desc limit 2,1) as third_score
						
					from score as s1
					) as t1 on score.sid = t1.sid
where score.score in(
	t1.first_score,
	t1.second_score,
	t1.third_score);	
	

	
32.
select course_id,count(sid) from score 
group by course_id; 
 
33.
select student.sid,sname,count(course_id) from score 
inner join student on student.sid=student_id
group by student_id having count(course_id) > 2;
 
 
34.
select gender,count(gender) from student
group by gender order by count(gender) desc; 
 
 
35.
select * from student
where sname like '张%';

36.
select s1.sid,s1.sname,s1.gender,s1.class_id from student as s1,student as s2
where s1.sname=s2.sname and s1.sid!=s2.sid;

37.
select course_id,avg(score) from score
group by course_id order by avg(score) asc,course_id  desc;


38.
select student_id,sname,cname,score from score
inner join student on student_id=student.sid
inner join course on course_id=cid
where cname='化学' and score<60;


39.
select student.sid,student.sname,score from score
inner join student on student_id=student.sid
where course_id=3 and score>80;

40.
select count(sid) as '选课学生人数' from (
select * from score
group by student_id) as t;

41.
select sname,score from 
		(select 
			student_id,
			course_id,
			score,
			max_score,min_score 
		from score,
		(select
			max(score) as max_score,
			min(score) as min_score
		from score
		inner join course on course_id=course.cid
		inner join teacher on teacher_id=teacher.tid
		where tname='王五') as s2) as s1
inner join course on s1.course_id=course.cid
inner join teacher on teacher_id=teacher.tid
inner join student on student_id=student.sid
where tname='王五' and s1.score in (max_score,min_score);


42.
select course_id,count(student_id) as '选修人数' from score group by course_id; 


43.
select s1.student_id,s1.course_id,s1.score from score as s1,score as s2
where s1.course_id!=s2.course_id and s1.score=s2.score;


44.
select 
	score.sid,
	score.student_id,
	score.course_id,
	score.score,
	t1.first_score,
	t1.second_score
from score inner join(
					select
						s1.sid,
						(select score from score as s2 where s1.course_id=s2.course_id order by score  desc limit 0,1) as first_score,
						(select score from score as s3 where s1.course_id=s3.course_id order by score  desc limit 1,1) as second_score
					from score as s1
					) as t1 on score.sid = t1.sid
where score.score in(
	t1.first_score,
	t1.second_score);


45.
select student_id,count(student_id) from score
group by student_id having count(student_id)>=2;


46.
select cid,cname from score
right join course on course_id=cid
where course_id is null;

47.
select * from teach2cls
right join teacher on teach2cls.tid=teacher.tid
where teach2cls.tid is null;


48.
select student_id,avg(score) from score
where score>80 group by student_id having count(student_id)>=2;

49.
select student_id,score from score
where course_id=3 and score<60 order by score desc;

50.
delete from score where student_id=2 and course_id=1;


51.
select student_id,sname from score
inner join course on cid=course_id
inner join student on student.sid=student_id
where cname='物理' or cname='生物' group by student_id having count(student_id)>=2;
