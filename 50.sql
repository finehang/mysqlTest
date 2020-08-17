SELECT ,,,
CREATE TABLE `Student`(
`s_id` VARCHAR(20),
`s_name` VARCHAR(20) NOT NULL DEFAULT '',
`s_birth` VARCHAR(20) NOT NULL DEFAULT '',
`s_sex` VARCHAR(10) NOT NULL DEFAULT '',
PRIMARY KEY(`s_id`)
);
CREATE TABLE `Course`(
`c_id` VARCHAR(20),
`c_name` VARCHAR(20) NOT NULL DEFAULT '',
`t_id` VARCHAR(20) NOT NULL,
PRIMARY KEY(`c_id`)
);
CREATE TABLE `Teacher`(
`t_id` VARCHAR(20),
`t_name` VARCHAR(20) NOT NULL DEFAULT '',
PRIMARY KEY(`t_id`)
);
CREATE TABLE `Score`(
`s_id` VARCHAR(20),
`c_id` VARCHAR(20),
`s_score` INT(3),
PRIMARY KEY(`s_id`,`c_id`)
);
( # 插入Student
insert into Student values('01' , '赵雷' , '1990-01-01' , '男');
insert into Student values('02' , '钱电' , '1990-12-21' , '男');
insert into Student values('03' , '孙风' , '1990-05-20' , '男');
insert into Student values('04' , '李云' , '1990-08-06' , '男');
insert into Student values('05' , '周梅' , '1991-12-01' , '女');
insert into Student values('06' , '吴兰' , '1992-03-01' , '女');
insert into Student values('07' , '郑竹' , '1989-07-01' , '女');
insert into Student values('08' , '王菊' , '1990-01-20' , '女');
)
( # 插入Course
insert into Course values('01' , '语文' , '02');
insert into Course values('02' , '数学' , '01');
insert into Course values('03' , '英语' , '03');
)
( # 插入Teacher
insert into Teacher values('01' , '张三');
insert into Teacher values('02' , '李四');
insert into Teacher values('03' , '王五');
insert into Teacher values('04' , '王刚');
)
( # 插入Score
insert into Score values('01' , '01' , 80);
insert into Score values('01' , '02' , 90);
insert into Score values('01' , '03' , 99);
insert into Score values('02' , '01' , 70);
insert into Score values('02' , '02' , 60);
insert into Score values('02' , '03' , 80);
insert into Score values('03' , '01' , 80);
insert into Score values('03' , '02' , 80);
insert into Score values('03' , '03' , 80);
insert into Score values('04' , '01' , 50);
insert into Score values('04' , '02' , 30);
insert into Score values('04' , '03' , 20);
insert into Score values('05' , '01' , 76);
insert into Score values('05' , '02' , 87);
insert into Score values('06' , '01' , 31);
insert into Score values('06' , '03' , 34);
insert into Score values('07' , '02' , 89);
insert into Score values('07' , '03' , 98);
)


-- 选出课程1分数大于课程2分数的学生的信息
SELECT
  st.*,
  a.s_score as "course1",
  b.s_score as "course2"
FROM
  student st
  INNER JOIN (
    SELECT
      s_id,
      s_score,
      c_id
    FROM
      score
    WHERE
      c_id = 1
  ) as a ON st.s_id = a.s_id
  INNER JOIN (
    SELECT
      s_id,
      s_score,
      c_id
    FROM
      score
    WHERE
      c_id = 2
  ) as b ON a.s_id = b.s_id
WHERE
  a.s_score > b.s_score;

-- 均分大于60的学生的ID和均分
-- select选择的字段应该在group by中使用,或者是统计函数,因为既然分了组,单个字段就没意义了,如下面的c_id
-- GROUP BY使用having进行条件限制
SELECT s_id,AVG(s_score),c_id
FROM score
GROUP BY s_id
HAVING AVG(s_score)>60;

-- 选出所有学生的学号,姓名,选课数和总成绩
SELECT st.s_id, st.s_name, sum(IFNULL(sc.s_score,0)) as "sumOfscore", count(sc.c_id) as "numOfcourse" # select出现的必须是group by的
# IFNULL(sc.s_score,0) 若sc.s_score为null，则返回0，否则返回自己
# 也可使用case when (CASE sc.s_score WHEN is null THEN 0 ELSE sc.s_score END CASE) 即sc.s_score为null时返回0，否则返回自己
FROM
	student st
	LEFT JOIN score sc ON st.s_id = sc.s_id # 有学生没有成绩
-- 	LEFT JOIN course co ON sc.c_id = co.c_id # 前面的两个一起与后面进行join, 其实score中有c_id,不用course也可以
GROUP BY
	st.s_id, st.s_name;

-- 查询姓张的老师的个数
select count(DISTINCT t_id) # 去除重复的
from teacher
where t_name like "张%"; # %匹配一个或多个字符

-- 查询姓氏的个数
select count(DISTINCT LEFT(t_name,1)) # 去除重复的，LEFT(t_name,1) 截取字符串左边第一个字符
from teacher;

-- 查看姓氏
select DISTINCT LEFT(t_name,1) # 去除重复的，LEFT(t_name,1) 截取字符串左边第一个字符
from teacher;

-- 注意左右内连接
-- student中有一个NULL值，内连接会丢失该值
select *
	FROM
		student st
		INNER JOIN score sc ON st.s_id = sc.s_id
		INNER JOIN course co ON sc.c_id = co.c_id
		INNER JOIN teacher te ON co.t_id = te.t_id;

-- 改用左连接保留该NULL值
select *
	FROM
		student st
		left JOIN score sc ON st.s_id = sc.s_id
		left JOIN course co ON sc.c_id = co.c_id
		left JOIN teacher te ON co.t_id = te.t_id;

-- 或将student放在最后使用右连接
select * 
	FROM
		score sc 
		inner JOIN course co ON sc.c_id = co.c_id
		inner JOIN teacher te ON co.t_id = te.t_id 
		RIGHT JOIN student st ON st.s_id = sc.s_id;

-- 查询没学过张三老师课的学生的信息
-- 全表链接法
SELECT
	st.s_id,
	st.s_name 
FROM
	student st 
WHERE
	st.s_id NOT IN ( # 不在此ID中的
	SELECT # 选出张三老师的学生的ID
		sc.s_id 
	FROM
		score sc 
		INNER JOIN course co ON sc.c_id = co.c_id
		INNER JOIN teacher te ON co.t_id = te.t_id 
	WHERE
		te.t_name = "张三" 
	);

-- 查询没学过张三老师课的学生的信息
-- 子查询套接法
SELECT
	st.s_id,
	st.s_name 
FROM
	student st 
WHERE
	st.s_id NOT IN (
		SELECT# 选出score表中c_id为张三老师的课的学生的id
		score.s_id 
	FROM
		score 
	WHERE
		score.c_id = ( SELECT course.t_id FROM course WHERE course.c_id =( # 选出张三老师01的课程的学生的id
				SELECT teacher.t_id FROM teacher WHERE teacher.t_name = "张三" # 选出张三老师的编号01
			) ) 
	);

-- 查询学过张三老师教过的所有课的同学的学号姓名
-- 与上相反，去除not即可
SELECT
	st.s_id,
	st.s_name 
FROM
	student st 
WHERE
	st.s_id IN (
		SELECT# 选出score表中c_id为张三老师的课的学生的id
		score.s_id 
	FROM
		score 
	WHERE
		score.c_id = ( SELECT course.t_id FROM course WHERE course.c_id =( # 选出张三老师01的课程的学生的id
				SELECT teacher.t_id FROM teacher WHERE teacher.t_name = "张三" # 选出张三老师的编号01
			) ) 
	);

-- 或者全表连接过滤
SELECT st.s_id, st.s_name
FROM student st
INNER JOIN score sc ON st.s_id=sc.s_idINNER JOIN course co ON sc.c_id=co.c_id
INNER JOIN teacher te on co.t_id=te.t_id
WHERE te.t_name="张三";

-- 查学过01课程也学过02课程的学生的学号和姓名
-- 取即学过01也学过02的人的交集
SELECT st.s_id, st.s_name
FROM student st
WHERE st.s_id IN (
select a.s_id from 
(SELECT score.s_id from score WHERE score.c_id=1) as a # 学过01课程的
INNER JOIN
(SELECT score.s_id from score WHERE score.c_id=2) as b ON a.s_id=b.s_id); # 学过02课程的， 内连接 取交集


-- 查询课程编号为02的课程的总成绩
SELECT c_id, sum(sc.s_score), avg(sc.s_score)
FROM score sc
-- WHERE c_id = "02"
GROUP BY c_id
HAVING c_id = "02";

-- 查询所有课程成绩小于60分的同学的姓名和id
SELECT *
FROM student st
WHERE st.s_id NOT IN( # 不在此列
SELECT s_id # 查每个人的最低成绩大于等于60的同学
FROM score
GROUP BY s_id
HAVING MIN(s_score)>=60
);

-- 或每人查成绩小于60分的课程数
SELECT *
FROM student
WHERE s_id IN(
select a.s_id
FROM
(select s_id, count(c_id) as cou
FROM score
WHERE s_score<60
GROUP BY s_id) as a
INNER JOIN
-- 查每人修的总课程数
(SELECT s_id, count(c_id) as cou
FROM score 
GROUP BY s_id) as b
ON a.s_id = b.s_id
WHERE a.cou = b.cou); # 小于60分的课程数 = 修的总课程数

-- 查询平均成绩大于或小于60分的同学的姓名和id
SELECT *
FROM student st
WHERE st.s_id IN(
SELECT s_id
FROM score
GROUP BY s_id
HAVING AVG(s_score)>60
);

SELECT *
FROM student st
WHERE st.s_id NOT IN(
SELECT s_id
FROM score
GROUP BY s_id
HAVING AVG(s_score)>60
);

-- 查没有学全所有课的学生信息
SELECT *
FROM student
WHERE s_id NOT IN( # 不在此列
SELECT s_id # 选出选的课程数目等于总课程数的人的id
FROM score 
GROUP BY s_id
HAVING count(s_id) = (
SELECT count(c_id)
FROM course));

# 查选的课程数目小于总课程数的人
SELECT st.s_id, st.s_name
FROM student st
LEFT JOIN score sc 
ON st.s_id = sc.s_id
GROUP BY st.s_id HAVING count(DISTINCT sc.c_id) < 
(SELECT count(DISTINCT c_id)
FROM course);


-- 查至少有一门课与学号为01的学生所学课程相同的同学的信息
SELECT DISTINCT
	st.s_name, st.s_id
FROM
	student st
	INNER JOIN score sc ON st.s_id = sc.s_id 
WHERE
	sc.c_id IN ( SELECT sc.c_id FROM score sc WHERE sc.s_id = "01" ) 
	AND sc.s_id != "01";

-- 查与01号同学学的课程完全相同的学生的信息
# 查选课门数等于01同学选课门数的人(1,2,3)
# 且排除有与01号选的课不同人的名单,选了(1,2,3)之外的课

SELECT *
FROM student
WHERE s_id IN( # 查选课门数等于01同学选课门数的人(1,2,3)
select s_id
FROM score
WHERE s_id != "01"
GROUP BY s_id HAVING count(DISTINCT c_id) = (SELECT count(c_id) FROM score sc WHERE s_id="01")
AND s_id NOT IN( # 且排除有与01号选的课不同人的名单,选了(1,2,3)之外的课
SELECT s_id FROM score WHERE c_id NOT IN
(SELECT c_id FROM score WHERE s_id = "01")));


-- 查询两门及以上成绩不合格的学生信息及其平均成绩
SELECT st.s_id, st.s_name, avg(sc.s_score)
FROM student st LEFT JOIN score sc ON st.s_id=sc.s_id
WHERE IFNULL(s_score,0)<60
GROUP BY s_id
HAVING COUNT(DISTINCT s_score)>=2


-- 查01课程分数小于60的学生信息,并按分数降序排列
SELECT st.s_id, st.s_name, sc.s_score
FROM student st INNER JOIN score sc ON st.s_id = sc.s_id
WHERE c_id="01" AND sc.s_score<60
ORDER BY s_score DESC;


-- 按均分从高到低显示所有学生的各科成绩及其均分
SELECT a.s_id, 
avg_score
FROM score a INNER JOIN
(SELECT s_id, AVG(s_score) AS avg_score
FROM score
GROUP BY s_id) b ON a.s_id=b.s_id
ORDER BY avg_score DESC;

SELECT s_id, 
MAX(case WHEN c_id="01" THEN s_score ELSE NULL END) AS "语文", # 因为使用了group by函数,select后面必须使用group by的,或统计函数,所以此处用了max, 即每个s_id分组中, 选出c_id="01"的分数,因为只有一个,选了最大值也是他自己,作为"语文"
MAX(case WHEN c_id="02" THEN s_score ELSE NULL END) AS "数学",
MAX(case WHEN c_id="03" THEN s_score ELSE NULL END) AS "英语",
AVG(s_score) AS "均分"
FROM score
GROUP BY s_id
ORDER BY AVG(s_score) DESC;
# 此例中,当使用分组统计是常使用case when 结构, 如, 查一个人周一的总消费,可以按id分组,然后使用sum(case data="Mon." THEN money ELSE 0 END)


-- 查各科成绩最高分,最低分,均分,一如下形式显示:课程ID, 课程name, 最高分, 最低分, 平均分, 以及各科的及格率, 中等率, 优良率, 优秀率, 其中及格>=60, 中等70-80, 优良80-90, 优秀>=90

SELECT sc.c_id "ID",
co.c_name "NAME",
max(sc.s_score) "MAX",
min(sc.s_score) "MIN",
avg(sc.s_score) "AVG",
SUM(case WHEN s_score>=60 THEN 1 ELSE 0 END) / COUNT(s_id) "及格率",  # 以各科进行分组, 大于60赋1, 否则赋0,查每个组里的分数大于60的人的个数 / 总人数
SUM(case WHEN s_score<60 THEN 1 ELSE 0 END) / COUNT(s_id) "不及格率",
SUM(case WHEN s_score>=70 AND s_score<80 THEN 1 ELSE 0 END) / COUNT(s_id) "中等率",
SUM(case WHEN s_score>=80 AND s_score<90 THEN 1 ELSE 0 END) / COUNT(s_id) "优良率",
SUM(case WHEN s_score>=90 THEN 1 ELSE 0 END) / COUNT(s_id) "优秀率"
FROM score sc INNER JOIN course co ON sc.c_id=co.c_id
GROUP BY sc.c_id;

-- 按各科成绩进行排序, 并显示排名
# ROW_NUMBER()函数 即显示行号, 即是分数相同,排名也递增
# DENSE_RANK()函数 连续排名, 分数相同,名次相同, 但名次是连续的, 如,1,2,2,2,3,3,4,5,6
# RANK()函数 跳跃排名 分数相同,名次相同, 但名次跟人数有关, 如1,2,2,4,5,5,5,8,9
SELECT s_id, c_id, s_score, RANK() over(PARTITION by c_id ORDER BY s_score DESC) # 以c_id分组, 以s_score顺序进行排名
FROM score;

-- 查学生总成绩并进行排名
SELECT s_id, SUM(s_score), RANK() over(ORDER BY sum(s_score) DESC)
FROM score
GROUP BY s_id;












