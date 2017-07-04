-- get started with source table
select * from dwh.t_partner
-- select required fields and count how many unique entries exist for databasis
select count(*) from (
select unique a_partner_nr, a_partner_name_1, a_partner_name_2, ac_sex, AO_nationalitaet, a_geb_gruend_jahr from dwh.t_partner
where ac_sex is not null
) -- 3'842'347
 
-- find names with highest occurance
select a_partner_name_2, count(ac_sex) from dwh.t_partner
where ac_sex is not null
group by a_partner_name_2
order by 2 desc;
-- find names with doube entries
create table t_smeo_name_gender_count as
select distinct * from
(
select s1.*, s2.female from
(
select a_partner_name_2 As firstname,  count(ac_sex) as male from dwh.t_partner
where ac_sex=100995
group by a_partner_name_2) s1
left outer join
(
select a_partner_name_2 As firstname,  count(ac_sex) as female from dwh.t_partner
where ac_sex=100996
group by a_partner_name_2) s2
on s1.firstname=s2.firstname
union
select s2.firstname, s1.male, s2.female from
(
select a_partner_name_2 As firstname,  count(ac_sex) as male from dwh.t_partner
where ac_sex=100995
group by a_partner_name_2) s1
right outer join
(
select a_partner_name_2 As firstname,  count(ac_sex) as female from dwh.t_partner
where ac_sex=100996
group by a_partner_name_2) s2
on s1.firstname=s2.firstname
)
order by 2 desc,3 desc
create table t_smeo_name_gender_probability as
select s2.*, s2.male/s2.Total as maleProb, s2.female/s2.total as femaleprob from
(
select s1.*, s1.male+s1.female as Total from
(select firstname, coalesce(male,0) as male, coalesce(female,0) as female
from t_smeo_name_gender_count) s1
)
s2
order by 4 desc
 
select distinct * from t_smeo_name_gender_probability
order by 4 desc
--219014
 
--Dominique
--Kim
--Deniz
--Jamie
--Lou
--Marian
--Isa
--Joan
--Vivian
--Fidan
select * from t_smeo_name_gender_probability
where firstname='Leslie'
 
select a_partner_name_2, ac_sex, decade ,sum(count_name) from (
select a_partner_name_2, ac_sex, a_geb_gruend_jahr ,  floor(a_geb_gruend_jahr/10) as decade ,count(a_partner_name_2) as count_name from dwh.t_partner
where ac_sex is not NULL and a_partner_name_2 = 'Dominique' or a_partner_name_2 = 'Kim' or a_partner_name_2 = 'Deniz' or a_partner_name_2 = 'Jamie' or a_partner_name_2 = 'Lou' or a_partner_name_2 = 'Maraian' or a_partner_name_2 = 'Isa'
group by a_partner_name_2, ac_sex, a_geb_gruend_jahr
)
where decade is not NULL and decade > 0
group by a_partner_name_2, ac_sex, decade
order by 4 desc
select a_partner_name_2, ac_sex, a_geb_gruend_jahr  ,count(a_partner_name_2) as count_name from dwh.t_partner
where ac_sex is not NULL and a_partner_name_2 = 'Peter'
group by a_partner_name_2, ac_sex, a_geb_gruend_jahr
order by 4 desc
select a_partner_name_2, ac_sex, a_geb_gruend_jahr   from dwh.t_partner
where ac_sex is not NULL and  a_geb_gruend_jahr is not null and a_partner_name_2 = 'Dominique' or a_partner_name_2 = 'Kim' or a_partner_name_2 = 'Deniz' or a_partner_name_2 = 'Jamie' or a_partner_name_2 = 'Lou' or a_partner_name_2 = 'Maraian' or a_partner_name_2 = 'Isa'
order by 3 desc
 
create table t_smeo_gender_age_nationality as
select a_partner_name_2 as name_, ac_sex as gender, a_geb_gruend_jahr as birthyear , ao_nationalitaet as nationality ,count(a_partner_name_2) as count_name from dwh.t_partner
where ac_sex is not NULL and ao_nationalitaet is not null and a_partner_name_2 is not null and a_geb_gruend_jahr is not null
group by a_partner_name_2, ac_sex, a_geb_gruend_jahr, ao_nationalitaet
order by 5 desc
 
select a_partner_name_2, ao_nationalitaet
from dwh.t_partner
where a_partner_name_2='Daniel' and ac_sex=100996
 
select * from t_smeo_gender_age_nationality
where nationality != 'CH'
and name_ = 'Andrea'
 
select * from (
select name_, nationality , gender, count(name_) as count_ from
t_smeo_gender_age_nationality
group by name_, nationality , gender
order by 1, 4 desc
)
where count_ > 5 and name_ ='Andrea'
select sum(female) from t_smeo_name_gender_probability
--3128688
 
select sum(male) from t_smeo_name_gender_probability
--3743929
select * from t_smeo_gender_age_nationality
--number of male ,female names in particular year
select name_, birthyear, count(name_) from t_smeo_gender_age_nationality
where gender=100995
group by name_, birthyear
order by 1,2
 
 
select birthyear, count(birthyear) from t_smeo_gender_age_nationality
where gender=100996
group by birthyear
order by 1
----
select name_, birthyear, count(name_) from t_smeo_gender_age_nationality
where gender=100995
group by name_, birthyear
order by 1,2
 
--Age
 
create table t_smeo_gender_by_name_age as
select distinct name_,birthyear,male,female, male+female as total, male/(male+female) as male_probab, female/(male+female) as female_probab from
(
select distinct name_,birthyear,coalesce(male,0) as Male, coalesce(female,0) as Female from
(
(select distinct m.name_,m.birthyear, m.Male, f.Female from
(select name_, birthyear, sum(count_name) as Male from t_smeo_gender_age_nationality
where gender=100995
group by name_, birthyear
order by 3 desc) m
left outer join
(select name_, birthyear, sum(count_name) as Female from t_smeo_gender_age_nationality
where gender=100996
group by name_, birthyear
order by 1,2) f on
m.name_ = f.name_ and m.birthyear=f.birthyear)
union
(select distinct f.name_,f.birthyear, m.Male, f.Female from
(select name_, birthyear, sum(count_name) as Male from t_smeo_gender_age_nationality
where gender=100995
group by name_, birthyear
order by 1,2) m
right outer join
(select name_, birthyear, sum(count_name) as Female from t_smeo_gender_age_nationality
where gender=100996
group by name_, birthyear
order by 1,2) f on
m.name_ = f.name_ and  m.birthyear=f.birthyear)
)
)
order by total desc
 
 
select birthyear, count(birthyear) from t_smeo_gender_by_name_age
where name_='Andrea'
group by birthyear
--Decade
create table t_smeo_gender_by_name_decade as
select distinct t2.name_, t2.decade, sum(t2.male) as male, sum(t2.female) as female, sum(t2.male)+ sum(t2.female) as total, sum(t2.male)/(sum(t2.male)+ sum(t2.female)) as male_probab,  sum(t2.female)/(sum(t2.male)+ sum(t2.female)) as female_probab from
(select t1.name_, floor(t1.birthyear/10) as decade, t1.male, t1.female from t_smeo_gender_by_name_age t1) t2
group by t2.name_, t2.decade
order by total desc
select decade, count(decade) from t_smeo_gender_by_name_decade
where name_='Daniel'
group by decade
 
--Nation
create table t_smeo_gender_by_name_nation as
select name_, nationality, male, female, male+female as total, male/(male+female) as male_probab, female/(male+female) as female_probab from
(
select distinct name_, nationality, coalesce(male,0) as male, coalesce(female,0) as female from (
select distinct s1.name_, s1.nationality, s1.male, s2.female from
(select name_, nationality, sum(count_name) as male
from t_smeo_gender_age_nationality
where gender=100995 and name_ ='Andrea'
group by name_, nationality) s1
left outer join
(select name_, nationality, sum(count_name) as female
from t_smeo_gender_age_nationality
where gender=100996  and name_ ='Andrea'
group by name_, nationality) s2
on s1.name_ = s2.name_ and s1.nationality= s2.nationality
union
select distinct s2.name_, s2.nationality, s1.male, s2.female from
(select name_, nationality, sum(count_name) as male
from t_smeo_gender_age_nationality
where gender=100995
group by name_, nationality) s1
right outer join
(select name_, nationality, sum(count_name) as female
from t_smeo_gender_age_nationality
where gender=100996
group by name_, nationality) s2
on s1.name_ = s2.name_ and s1.nationality= s2.nationality
)
)
order by total desc
drop table t_smeo_gender_by_name_decade
select nationality, count(nationality) from t_smeo_gender_by_name_nation
where name_ ='Andrea'
group by nationality
select * from t_smeo_gender_by_name_nation
where name_ ='Andrea'
-----
create table t_smeo_gender_by_age_nation as
select distinct T.*, T.male + T.female as total, T.male/(T.male + T.female) as male_probab, T.female/(T.male + T.female) as female_probab from (
select distinct s1.name_, s1.birthyear,s1.nationality, s1.male , coalesce(s2.female,0) as female from
(select name_, birthyear, nationality, count_name as male
from t_smeo_gender_age_nationality
where gender = 100995) s1
left outer join
(select name_, birthyear, nationality, count_name as female
from t_smeo_gender_age_nationality
where gender = 100996) s2
on s1.name_= s2.name_ and s1.birthyear = s2.birthyear and s1.nationality = s2.nationality
union
select distinct s2.name_, s2.birthyear, s2.nationality,coalesce(s1.male,0) as male, coalesce(s2.female,0) as female from
(select name_, birthyear, nationality, count_name as male
from t_smeo_gender_age_nationality
where gender = 100995) s1
right outer join
(select name_, birthyear, nationality, count_name as female
from t_smeo_gender_age_nationality
where gender = 100996) s2
on s1.name_= s2.name_ and s1.birthyear = s2.birthyear and s1.nationality = s2.nationality) T
order by total desc
----
create table t_smeo_gender_by_decade_nation as
select name_,  decade, nationality, sum(male) as male, sum(female) as female,sum(male)+ sum(female) as total, sum(male)/(sum(male)+ sum(female)) as male_probab,  sum(female)/(sum(male)+ sum(female)) as female_probab from (
select name_, floor(birthyear/10) as decade, nationality,  male, female from t_smeo_gender_by_age_nation)
group by name_, decade, nationality
order by total desc
select decade, nationality , count(*) from t_smeo_gender_by_decade_nation
where name_ = 'Daniel'
group by decade, nationality
--List of tables
--t_smeo_gender_age_nationality
--name --> t_smeo_name_gender_probability
--decade --> t_smeo_gender_by_name_decade
--age --> t_smeo_gender_by_name_age
--nation --> t_smeo_gender_by_name_nation
--age + nation --> t_smeo_gender_by_age_nation
-- decade + nation --> t_smeo_gender_by_decade_nation
select * from t_smeo_gender_by_age_nation
where name_='Andrea' and nationality = 'IT'
order by 1
select name_, count(name_) from (
select upper(firstname), total as name_ from t_smeo_name_gender_probability )
group by name_
order by 2 desc
 
select * from t_smeo_name_gender_probability
where male > female
and maleprob < 0.90
and male > 300
order by 5
select * from t_smeo_gender_by_name_decade
where name_='Käthi'
 
select * from t_smeo_gender_by_name_nation
where name_ = 'Nicola'
order by 1
 
select * from t_smeo_gender_by_decade_nation
where name_ in ('Dominique','Deniz','Jamie','Noa','Michele','Jannick','Noe','Elia','Rosario','Enea','Janick','Noé')
order by 1, 2
 
select * from t_smeo_gender_by_name_decade
where name_ ='Harvey'
and total > 20
order by 1, 2
create table t_smeo_names_patents as
select t2.publication_number, regexp_replace(upper(t2.inventor1), '[^ABCDEFGHIJKLMNOPQRSTUVWXYZ]', ' ') as inventor1,regexp_replace(upper(t2.inventor2), '[^ABCDEFGHIJKLMNOPQRSTUVWXYZ]', ' ') as inventor2,regexp_replace(upper(t2.inventor3), '[^ABCDEFGHIJKLMNOPQRSTUVWXYZ]', ' ') as inventor3,regexp_replace(upper(t2.inventor4), '[^ABCDEFGHIJKLMNOPQRSTUVWXYZ]', ' ') as inventor4,regexp_replace(upper(t2.inventor5), '[^ABCDEFGHIJKLMNOPQRSTUVWXYZ]', ' ') as inventor5,regexp_replace(upper(t2.inventor6), '[^ABCDEFGHIJKLMNOPQRSTUVWXYZ]', ' ') as inventor6 , floor((t1.appyear-65)/10) as startyear,  floor((t1.appyear-25)/10)  as endyear from
(select publication_number , extract(year from application_date) as appyear from t_smeo_sme_append ) t1
inner join t_smeo_patent_inventors_fields t2
on t1.publication_number = t2.publication_number
 
drop table t_smeo_names_patents
select * from t_smeo_names_patents
where inventor1!='NULL' and  inventor1 is not null
create table temp_inventor1 as (
select t1.*, t2.male, t2.female, t2.name_,t2.decade, length(t2.name_) as len1
from t_smeo_gender_by_decade_nation t2 inner join
(select publication_number, inventor1, startyear,endyear from t_smeo_names_patents
where inventor1!='NULL' and  inventor1 is not null)t1
on upper(t1.inventor1)= upper(t2.name_) or  t1.inventor1 like '%' || upper(t2.name_) || '%' and t2.decade >= t1.startyear and t2.decade <= t1.endyear )
select inventor1 , regexp_substr(inventor1, '[^ ]+$') from t_smeo_names_patents t1
select regexp_substr(
  'ThisSentence.ShouldBe.SplitAfterLastPeriod.Sentence',
  '[^.]+$')
from dual
drop table  temp_inventor1
create table temp_inventor1 as
select t1.publication_number, t1.inventor1,t1.inventor1_2,t1.startyear,t1.endyear, t2.male, t2.female, t2.name_,t2.decade
from (select upper(name_) as name_,decade,male,female from t_smeo_gender_by_decade_nation where nationality='CH' )t2 inner join
tmp1 t1
on (upper(t1.inventor1)= t2.name_ or  upper(t1.inventor1_2)= t2.name_) and t1.startyear <= t2.decade and t1.endyear >= t2.decade
 
create table tmp1 as
select publication_number, substr(inventor1, 1,instr(inventor1,' ') - 1) as inventor1,regexp_substr(inventor1, '[^ ]+$') as inventor1_2 ,startyear,endyear from t_smeo_names_patents
where inventor1!='NULL' and  inventor1 is not null
 
select * from tmp1
 
select * from temp_inventor1
 
 
---- gender by decade
create table tmp45 as
select name_, decade, sum(male) as male, sum(female) as female from (
select upper(name_) as name_,decade,male,female from t_smeo_gender_by_name_decade  )
group by name_ ,decade
 
create table temp_inventor1 as
select t1.publication_number, t1.inventor1,t1.inventor1_2,t1.startyear,t1.endyear, t2.male, t2.female, t2.name_,t2.decade
from tmp45 t2 inner join
tmp1 t1
on (upper(t1.inventor1)= t2.name_ or  upper(t1.inventor1_2)= t2.name_) and t1.startyear <= t2.decade and t1.endyear >= t2.decade
select * from temp_inventor1 order by 1
 
select * from tmp45
where name_ = 'FRANKLIN'
 
 
 
 
select distinct publication_number,inventor1,inventor1_2, sum(male) as male, sum(female) as female, sum(male) + sum(female) as total, sum(male)/(sum(male) + sum(female)) as male_probab, sum(female)/(sum(male) + sum(female)) as female_probab
from (
select distinct publication_number, name_, inventor1, inventor1_2, sum(male) as male, sum(female) as female ,length(name_) as len from (
select * from temp_inventor1
) group by publication_number, name_, inventor1, inventor1_2, startyear, endyear
order by 1 )
group by publication_number,inventor1,inventor1_2
order by 1
 
drop table tmp45
drop table temp_inventor1
---- gender just by names
create table tmp45 as
select name_ , sum(male) as male, sum(female) as female from (
select upper(firstname) as name_ , male, female from t_smeo_name_gender_probability
) group by name_
 
select * from tmp45
 
select publication_number, inventor1,inventor1_2, sum(male) as male , sum(female) as female from (
select t1.publication_number, t1.inventor1,t1.inventor1_2, t2.male, t2.female, t2.name_
from tmp45 t2 inner join
tmp1 t1
on (upper(t1.inventor1)= t2.name_ or  upper(t1.inventor1_2)= t2.name_)
)
group by publication_number,inventor1,inventor1_2
order by 1
 
--List of tables
--t_smeo_gender_age_nationality
--name --> t_smeo_name_gender_probability
--decade --> t_smeo_gender_by_name_decade
--age --> t_smeo_gender_by_name_age
--nation --> t_smeo_gender_by_name_nation
--age + nation --> t_smeo_gender_by_age_nation
-- decade + nation --> t_smeo_gender_by_decade_nation
--name_gender_classification
--random_classify_by_name
--random_classify_by_age
select * from random_classify_by_age
 
 
 
 
 
 
 
 
drop table tmp45
create table t_smeo_name_gender_probability as
select name_,male,female, male+female as total, male/(male+female) as male_prob, female/(male+female) as female_prob
from tmp45
select * from t_smeo_name_gender_probability
where  total >10
--6872617 Total names
--217360 unique names
--99243 female
--110905 male names
-- unisex names
--17079 names with total greater than 10.
--7807 male names
--6450 female
-- unisex names
create table name_gender_classification as
select name_ , 1 as male ,0 as female, 0 as unisex from t_smeo_name_gender_probability
where total > 10 and male_prob > .95
union
select name_ , 0 as male, 1 as female, 0 as unisex from t_smeo_name_gender_probability
where total > 10 and female_prob > .95
union
select name_  ,0 as male, 0 as female, 1 as unisex  from t_smeo_name_gender_probability
where total > 10 and female_prob < .95 and male_prob < .95
drop table random_classify_by_name
select * from random_sample_for_test
create table random_sample_for_test as
SELECT * FROM
( SELECT * FROM ( select * from t_smeo_gender_age_nationality where count_name > 10)
ORDER BY dbms_random.value )
where rownum <= 20000
select * from random_classify_by_name
create table random_classify_by_name as
select name_ , 1 as male, 0 as female, 0 as unisex from (
select name_, sum(male)as male, sum(female) as female,sum(male)+sum(female) as total, sum(male)/(sum(male)+sum(female)) as male_probab,  sum(female)/(sum(male)+sum(female)) as female_probab from (
(select name_, 0 as male,count(*) as female
from random_sample_for_test
where gender = 100996
group by name_)
union
(select name_, count(*) as male, 0 as female
from random_sample_for_test
where gender = 100995
group by name_)
)
group by name_
)
where male_probab =1
union
select name_ , 0 as male, 1 as female, 0 as unisex from (
select name_, sum(male)as male, sum(female) as female,sum(male)+sum(female) as total, sum(male)/(sum(male)+sum(female)) as male_probab,  sum(female)/(sum(male)+sum(female)) as female_probab from (
(select name_, 0 as male,count(*) as female
from random_sample_for_test
where gender = 100996
group by name_)
union
(select name_, count(*) as male, 0 as female
from random_sample_for_test
where gender = 100995
group by name_)
)
group by name_
)
where female_probab =1
union
select name_ , 0 as male, 0 as female, 1 as unisex from (
select name_, sum(male)as male, sum(female) as female,sum(male)+sum(female) as total, sum(male)/(sum(male)+sum(female)) as male_probab,  sum(female)/(sum(male)+sum(female)) as female_probab from (
(select name_, 0 as male,count(*) as female
from random_sample_for_test
where gender = 100996
group by name_)
union
(select name_, count(*) as male, 0 as female
from random_sample_for_test
where gender = 100995
group by name_)
)
group by name_
)
where male_probab!=1 and female_probab!=1
select count(*) from random_classify_by_name
--2634
select count(*) from (
select t2.name_, t1.male as male_correct, t1.female as female_correct, t1.unisex as unisex_correct, t2.male as pred_male, t2.female as pred_female, t2.unisex as pred_unisex from
name_gender_classification t1 right outer join random_classify_by_name t2
on t1.name_ = upper(t2.name_)
)
where male_correct != pred_male or female_correct != pred_female or unisex_correct!=pred_unisex
 
select count(*) from (
select t2.name_, t1.male as male_correct, t1.female as female_correct, t1.unisex as unisex_correct, t2.male as pred_male, t2.female as pred_female, t2.unisex as pred_unisex from
name_gender_classification t1 right outer join random_classify_by_name t2
on t1.name_ = upper(t2.name_)
)
where unisex_correct =1 and  pred_unisex =1
--
--131 incorrect from 2634
drop table random_classify_by_age
create table random_classify_by_age as
select name_, decade, 1 as male, 0 as female, 0 as unisex from (
select name_, decade, sum(male) as male, sum(female) as female ,sum(male)+sum(female) as total, sum(male)/(sum(male)+sum(female)) as male_probab,  sum(female)/(sum(male)+sum(female)) as female_probab  from (
select name_, decade, sum(count_name) as male , 0 as female from (
select name_ , gender, floor(birthyear/10) as decade, nationality, count_name from random_sample_for_test)
where gender = 100995
group by name_,decade
union
select name_, decade,0 as male , sum(count_name) as female from (
select name_ , gender, floor(birthyear/10) as decade, nationality, count_name from random_sample_for_test)
where gender = 100996
group by name_,decade
)
group by name_,decade
order by 1
)
where male_probab=1
union
select name_, decade, 0 as male, 1 as female, 0 as unisex from (
select name_, decade, sum(male) as male, sum(female) as female ,sum(male)+sum(female) as total, sum(male)/(sum(male)+sum(female)) as male_probab,  sum(female)/(sum(male)+sum(female)) as female_probab  from (
select name_, decade, sum(count_name) as male , 0 as female from (
select name_ , gender, floor(birthyear/10) as decade, nationality, count_name from random_sample_for_test)
where gender = 100995
group by name_,decade
union
select name_, decade,0 as male , sum(count_name) as female from (
select name_ , gender, floor(birthyear/10) as decade, nationality, count_name from random_sample_for_test)
where gender = 100996
group by name_,decade
)
group by name_,decade
order by 1
)
where female_probab=1
union
select name_, decade, 0 as male, 0 as female, 1 as unisex from (
select name_, decade, sum(male) as male, sum(female) as female ,sum(male)+sum(female) as total, sum(male)/(sum(male)+sum(female)) as male_probab,  sum(female)/(sum(male)+sum(female)) as female_probab  from (
select name_, decade, sum(count_name) as male , 0 as female from (
select name_ , gender, floor(birthyear/10) as decade, nationality, count_name from random_sample_for_test)
where gender = 100995
group by name_,decade
union
select name_, decade,0 as male , sum(count_name) as female from (
select name_ , gender, floor(birthyear/10) as decade, nationality, count_name from random_sample_for_test)
where gender = 100996
group by name_,decade
)
group by name_,decade
order by 1
)
where male_probab!=1 and female_probab!=1
 
select * from random_classify_by_age
 
--List of tables
--t_smeo_gender_age_nationality
--name --> t_smeo_name_gender_probability
--decade --> t_smeo_gender_by_name_decade
--age --> t_smeo_gender_by_name_age
--nation --> t_smeo_gender_by_name_nation
--age + nation --> t_smeo_gender_by_age_nation
-- decade + nation --> t_smeo_gender_by_decade_nation
--name_gender_classification
--name_age_gender_classification
--random_classify_by_name
--random_classify_by_age
 
create table tmp45 as
select name_ , decade, sum(male) as male, sum(female) as female from (
select upper(name_) as name_ , decade,male, female from t_smeo_gender_by_name_decade
) group by name_ ,decade
 
drop table tmp45
create table t_smeo_gender_by_name_decade as
select name_,decade,male,female, male+female as total, male/(male+female) as male_prob, female/(male+female) as female_prob
from tmp45
 
select * from  t_smeo_gender_by_name_decade
where female_prob > .95
--318761 unique name,decade combinations
--163374 males
--147350
create table name_age_gender_classification as
select name_, decade, 1 as male, 0 as female, 0 as unisex
from t_smeo_gender_by_name_decade
where male_prob > 0.95
union
select name_, decade, 0 as male, 1 as female, 0 as unisex
from t_smeo_gender_by_name_decade
where female_prob > 0.95
union
select name_, decade, 0 as male, 0 as female, 1 as unisex
from t_smeo_gender_by_name_decade
where male_prob < 0.95 and female_prob < 0.95
select * from name_age_gender_classification
where name_='DENIZ'
order by 1
 
select count(distinct name_) from random_classify_by_age
--8512
--2634 distinct names
select count(*) from (
select t2.name_, t2.decade, t1.male as male_correct, t1.female as female_correct, t1.unisex as unisex_correct, t2.male as pred_male, t2.female as pred_female, t2.unisex as pred_unisex from
name_age_gender_classification t1 right outer join random_classify_by_age t2
on t1.name_ = upper(t2.name_) and t1.decade=t2.decade
)
where male_correct != pred_male or female_correct != pred_female or unisex_correct!=pred_unisex
 
select count(distinct name_) from (
select t2.name_, t2.decade, t1.male as male_correct, t1.female as female_correct, t1.unisex as unisex_correct, t2.male as pred_male, t2.female as pred_female, t2.unisex as pred_unisex from
name_age_gender_classification t1 right outer join random_classify_by_age t2
on t1.name_ = upper(t2.name_) and t1.decade=t2.decade
)
where male_correct =1 and  pred_male =1
--name age combination
-- 262 mismatched pairs
--204 names incorrect
--8512
--Name combination
----131 incorrect from 2634
---matched
select count(distinct t2.name_) from
random_classify_by_age t1 inner join name_age_gender_classification t2
on upper(t1.name_)= t2.name_ and t1.decade = t2.decade and t1.male=t2.male and  t1.female = t2.female and t1.unisex=t2.unisex
 
--8243 matched
--2540 names matched out of 2634
 
select distinct * from
(select t1.name_ from
random_classify_by_age t1 inner join name_age_gender_classification t2
on upper(t1.name_)= t2.name_ and t1.decade = t2.decade and t1.male=t2.male and  t1.female = t2.female and t1.unisex=t2.unisex
order by 1) t1
inner join
(
select name_ from (
select t2.name_, t1.male as male_correct, t1.female as female_correct, t1.unisex as unisex_correct, t2.male as pred_male, t2.female as pred_female, t2.unisex as pred_unisex from
name_gender_classification t1 right outer join random_classify_by_name t2
on t1.name_ = upper(t2.name_)
)
where male_correct != pred_male or female_correct != pred_female or unisex_correct!=pred_unisex
) t2
on t1.name_ = t2.name_
 
--- 63 names matched with their age combination
 
--List of tables
--t_smeo_gender_age_nationality
--name --> t_smeo_name_gender_probability
--decade --> t_smeo_gender_by_name_decade
--age --> t_smeo_gender_by_name_age
--nation --> t_smeo_gender_by_name_nation
--age + nation --> t_smeo_gender_by_age_nation
-- decade + nation --> t_smeo_gender_by_decade_nation
--name_gender_classification
--name_age_gender_classification
---name_age_nation_gender
 
--random_classify_by_name
--random_classify_by_age
--random_classify_by_nation
 
select count(*) from random_classify_by_nation
where male=1
select count(*) from name_age_nation_gender
where female=1
select  * from t_smeo_gender_by_decade_nation
 
create table tmp45 as
select name_ , decade,nationality, sum(male) as male, sum(female) as female from (
select upper(name_) as name_ , decade,nationality, male, female from t_smeo_gender_by_decade_nation
) group by name_ ,decade, nationality
select * from tmp45
drop table tmp45
create table t_smeo_gender_by_decade_nation as
select name_,decade,nationality, male,female, male+female as total, male/(male+female) as male_prob, female/(male+female) as female_prob
from tmp45
select  * from t_smeo_gender_by_decade_nation
--431859 entries
--205163 names
create table name_age_nation_gender as
select  name_, decade, nationality , 1 as male, 0 as female, 0 as unisex from t_smeo_gender_by_decade_nation
where male_prob > 0.95
union
select  name_, decade, nationality , 0 as male, 1 as female, 0 as unisex from t_smeo_gender_by_decade_nation
where female_prob > 0.95
union
select  name_, decade, nationality , 0 as male, 0 as female, 1 as unisex from t_smeo_gender_by_decade_nation
where male_prob < 0.95 and female_prob < 0.95
 
select count(*) from (
select distinct name_,floor(birthyear/10) as decade,nationality from random_sample_for_test
)
--2000 entires, 2634 distinct names,
--8512 name,decade combi
--9800 name , age, nation entries
 
create table random_classify_by_nation as
select name_, decade,nationality, 1 as male, 0 as female, 0 as unisex from (
select name_, decade,nationality, sum(male) as male, sum(female) as female ,sum(male)+sum(female) as total, sum(male)/(sum(male)+sum(female)) as male_probab,  sum(female)/(sum(male)+sum(female)) as female_probab  from (
select name_, decade,nationality, sum(count_name) as male , 0 as female from (
select name_ , gender, floor(birthyear/10) as decade, nationality, count_name from random_sample_for_test)
where gender = 100995
group by name_,decade,nationality
union
select name_, decade,nationality,0 as male , sum(count_name) as female from (
select name_ , gender, floor(birthyear/10) as decade, nationality, count_name from random_sample_for_test)
where gender = 100996
group by name_,decade,nationality
)
group by name_,decade,nationality
order by 1
)
where male_probab=1
union
select name_, decade,nationality, 0 as male, 1 as female, 0 as unisex from (
select name_, decade,nationality, sum(male) as male, sum(female) as female ,sum(male)+sum(female) as total, sum(male)/(sum(male)+sum(female)) as male_probab,  sum(female)/(sum(male)+sum(female)) as female_probab  from (
select name_, decade,nationality, sum(count_name) as male , 0 as female from (
select name_ , gender, floor(birthyear/10) as decade, nationality, count_name from random_sample_for_test)
where gender = 100995
group by name_,decade,nationality
union
select name_, decade,nationality,0 as male , sum(count_name) as female from (
select name_ , gender, floor(birthyear/10) as decade, nationality, count_name from random_sample_for_test)
where gender = 100996
group by name_,decade,nationality
)
group by name_,decade,nationality
order by 1
)
where female_probab=1
union
select name_, decade,nationality, 0 as male, 0 as female, 1 as unisex from (
select name_, decade, nationality,sum(male) as male, sum(female) as female ,sum(male)+sum(female) as total, sum(male)/(sum(male)+sum(female)) as male_probab,  sum(female)/(sum(male)+sum(female)) as female_probab  from (
select name_, decade, nationality,sum(count_name) as male , 0 as female from (
select name_ , gender, floor(birthyear/10) as decade, nationality, count_name from random_sample_for_test)
where gender = 100995
group by name_,decade,nationality
union
select name_, decade,nationality,0 as male , sum(count_name) as female from (
select name_ , gender, floor(birthyear/10) as decade, nationality, count_name from random_sample_for_test)
where gender = 100996
group by name_,decade,nationality
)
group by name_,decade,nationality
order by 1
)
where male_probab!=1 and female_probab!=1
 
select * from random_classify_by_nation
where female=1 and male=1
--9800 entries
--2634
select count(*) from
random_classify_by_nation t1 inner join name_age_nation_gender t2
on upper(t1.name_)= t2.name_ and t1.decade = t2.decade and t1.nationality=t2.nationality and t1.male=t2.male and  t1.female = t2.female and t1.unisex=t2.unisex
--9505 entries matched
--2549 names matched
--295 mismatched entries
 
select * from
random_classify_by_nation t1 inner join name_age_nation_gender t2
on upper(t1.name_)= t2.name_ and t1.decade = t2.decade and t1.nationality=t2.nationality
order by 1
select count(distinct name_) from (
select t2.name_,t2.decade,t2.nationality ,t1.male as male_correct, t1.female as female_correct, t1.unisex as unisex_correct, t2.male as pred_male, t2.female as pred_female, t2.unisex as pred_unisex from
name_age_nation_gender t1 right outer join random_classify_by_nation t2
on t1.name_ = upper(t2.name_) and t1.decade = t2.decade and t1.nationality=t2.nationality
)
where female_correct = 1 and pred_female =1
 
-------------------------------------------
 
--List of tables
--t_smeo_gender_age_nationality
--name --> t_smeo_name_gender_probability
--decade --> t_smeo_gender_by_name_decade
--age --> t_smeo_gender_by_name_age
--nation --> t_smeo_gender_by_name_nation
--age + nation --> t_smeo_gender_by_age_nation
-- decade + nation --> t_smeo_gender_by_decade_nation
--name_gender_classification
--name_age_gender_classification
---name_age_nation_gender
 
create table tmp1 as
select publication_number, substr(inventor1, 1,instr(inventor1,' ') - 1) as inventor1,regexp_substr(inventor1, '[^ ]+$') as inventor1_2 ,startyear,endyear from t_smeo_names_patents
where inventor1!='NULL' and  inventor1 is not null
select count(*) from tmp1 --1546
select * from (
select publication_number, inventor1, inventor1_2, startyear, endyear, sum(male) as male , sum(female) as female from (
select distinct t1.*, t2.male,t2.female from
tmp1 t1 left outer join name_gender_classification t2
on t1.inventor1 = t2.name_ or t1.inventor1_2 = t2.name_
order by 1,6 desc, 7 desc
)
group by publication_number,inventor1, inventor1_2, startyear, endyear
order by 1
)
where male is null
-- 75 names not found out of 1546.
 
---Gender from first names of inventors
select publication_number, inventor1, inventor1_2, startyear, endyear, sum(male) as male , sum(female) as female from (
select distinct t1.*, t2.male,t2.female from
tmp1 t1 left outer join name_gender_classification t2
on t1.inventor1 = t2.name_ or t1.inventor1_2 = t2.name_
order by 1,6 desc, 7 desc
)
group by publication_number,inventor1, inventor1_2, startyear, endyear
order by 1
 
--Gender from name and age
select publication_number, inventor1, inventor1_2, startyear, endyear, sum(male) as male , sum(female) as female from (
select distinct t1.*, t2.male,t2.female from
tmp1 t1 left outer join name_age_gender_classification t2
on (t1.inventor1 = t2.name_ or t1.inventor1_2 = t2.name_) and t1.startyear <= t2.decade and t1.endyear >= t2.decade
order by 1,6 desc, 7 desc
)
group by publication_number,inventor1, inventor1_2, startyear, endyear
order by 1
 
----
--List of tables
--t_smeo_gender_age_nationality
--name --> t_smeo_name_gender_probability
--decade --> t_smeo_gender_by_name_decade
--nation --> t_smeo_gender_by_name_nation
-- decade + nation --> t_smeo_gender_by_decade_nation
--name_gender_classification
--name_age_gender_classification
---name_age_nation_gender
---gender_binary_name  
---gender_binary_age
---gender_binary_nation
 
 
select count(*) from  t_smeo_name_gender_probability
where male_prob = female_prob
create table gender_binary_name as
select distinct name_, 1 as male, 0 as female from t_smeo_name_gender_probability
where male_prob > female_prob
union
select distinct name_, 0 as male, 1 as female from t_smeo_name_gender_probability
where female_prob > male_prob
order by 1
create table gender_binary_age as
select distinct name_, decade, 1 as male, 0 as female from t_smeo_gender_by_name_decade
where male_prob > female_prob
union
select distinct name_, decade, 0 as male, 1 as female from t_smeo_gender_by_name_decade
where female_prob > male_prob
order by 1
 
create table gender_binary_nation as
select distinct name_, decade,nationality, 1 as male, 0 as female from t_smeo_gender_by_decade_nation
where male_prob > female_prob
union
select distinct name_, decade,nationality,  0 as male, 1 as female from t_smeo_gender_by_decade_nation
where female_prob > male_prob
order by 1
select count(distinct name_) from gender_binary_nation
where male=1
--216134
--113553 male names
--102581 female names
 
create table random_binary_nation as
select name_,decade,nationality, 1 as male, 0 as female from (
select name_, decade,nationality,sum(male) as male, sum(female) as female from (
select name_, decade, nationality,sum(count_name) as male, 0 as female from (
select upper(name_) as name_, gender, floor(birthyear/10) as decade, nationality, count_name from random_sample_for_test)
where gender = 100995
group by name_,decade,nationality
union
select name_, decade,nationality,0 as male, sum(count_name) as female from (
select upper(name_) as name_, gender, floor(birthyear/10) as decade, nationality, count_name from random_sample_for_test)
where gender = 100996
group by name_,decade,nationality
)
group by name_,decade,nationality)
where male > female
union
select name_,decade,nationality, 0 as male, 1 as female from (
select name_, decade,nationality,sum(male) as male, sum(female) as female from (
select name_, decade, nationality,sum(count_name) as male, 0 as female from (
select upper(name_) as name_, gender, floor(birthyear/10) as decade, nationality, count_name from random_sample_for_test)
where gender = 100995
group by name_,decade,nationality
union
select name_, decade,nationality,0 as male, sum(count_name) as female from (
select upper(name_) as name_, gender, floor(birthyear/10) as decade, nationality, count_name from random_sample_for_test)
where gender = 100996
group by name_,decade,nationality
)
group by name_,decade,nationality)
where male < female
---gender_binary_name  
---gender_binary_age
---gender_binary_nation
--random_binary_name
--random_binary_decade
--random_binary_nation
select * from random_binary_nation
where male=1
 
 
select count(distinct name_) from (
select t1.name_,t1.decade,t1.nationality ,t1.male as male, t1.female as female, t2.male as pred_male, t2.female as pred_female
from gender_binary_nation t1 inner join random_binary_nation t2
on t1.name_ = t2.name_ and t1.decade = t2.decade and t1.nationality= t2.nationality and t1.male=t2.male and t1.female = t2.female
)
where female= 1 and pred_female=0
 
 
select * from (
select distinct name_ from (
select t1.name_,t1.decade, t1.male as male, t1.female as female, t2.male as pred_male, t2.female as pred_female
from gender_binary_age t1 inner join random_binary_decade t2
on t1.name_ = t2.name_ and t1.decade = t2.decade
)
where male= 1 ) t1
inner join
(select distinct name_ from (
select t1.name_,t1.decade, t1.male as male, t1.female as female, t2.male as pred_male, t2.female as pred_female
from gender_binary_age t1 inner join random_binary_decade t2
on t1.name_ = t2.name_ and t1.decade = t2.decade
)
where female= 1) t2
on t1.name_ = t2.name_
ANDREA
GABRIELE
DOMINIQUE
JANNICK
JAMIE
select count(distinct name_) from (
select t1.name_,t1.decade, t1.male as male, t1.female as female, t2.male as pred_male, t2.female as pred_female
from gender_binary_age t1 inner join random_binary_decade t2
on t1.name_ = t2.name_ and t1.decade = t2.decade and t1.male=t2.male and t1.female= t2.female
)
 
----------------------------------------------
select s2.*, s1.name_, s1.male,s1.female from
(
select s1.publication_number, s1.inventor1 , s1.inventor1_2, s2.name_, s2.male, s2.female from
(select * from (
select distinct t1.publication_number, t1.inventor1 , t1.inventor1_2,  t2.name_, t2.male, t2.female from tmp1 t1
left outer join gender_binary_name   t2
on t1.inventor1 = t2.name_
order by 1
) where name_ is null) s1
inner join gender_binary_name   s2
on s1.inventor1_2 = s2.name_
union
select distinct t1.publication_number, t1.inventor1 , t1.inventor1_2, t2.name_, t2.male, t2.female from tmp1 t1
inner join gender_binary_name   t2
on t1.inventor1 = t2.name_
)
s1
right outer join tmp1 s2
on s1.publication_number = s2.publication_number
 
--1031
drop table tmp2
 
select count(*) from tmp2
create table tmp2 as
select publication_number, substr(inventor2, 1,instr(inventor2,' ') - 1) as inventor1,regexp_substr(inventor2, '[^ ]+$') as inventor2_2 ,startyear,endyear from t_smeo_names_patents
where inventor2!='NULL' and  inventor2 is not null
union
select publication_number, substr(inventor3, 1,instr(inventor3,' ') - 1) as inventor1,regexp_substr(inventor3, '[^ ]+$') as inventor2_2 ,startyear,endyear from t_smeo_names_patents
where inventor3!='NULL' and  inventor3 is not null
union
select publication_number, substr(inventor4, 1,instr(inventor4,' ') - 1) as inventor1,regexp_substr(inventor4, '[^ ]+$') as inventor2_2 ,startyear,endyear from t_smeo_names_patents
where inventor4!='NULL' and  inventor4 is not null
union
select publication_number, substr(inventor5, 1,instr(inventor5,' ') - 1) as inventor1,regexp_substr(inventor5, '[^ ]+$') as inventor2_2 ,startyear,endyear from t_smeo_names_patents
where inventor5!='NULL' and  inventor5 is not null
union
select publication_number, substr(inventor6, 1,instr(inventor6,' ') - 1) as inventor1,regexp_substr(inventor6, '[^ ]+$') as inventor2_2 ,startyear,endyear from t_smeo_names_patents
where inventor6!='NULL' and  inventor6 is not null
 
select  * from t_smeo_names_patents
 
select count(*) from
(
select s1.publication_number, s1.inventor1 , s1.inventor2_2, s2.name_, s2.male, s2.female from
(select * from (
select distinct t1.publication_number, t1.inventor1 , t1.inventor2_2,  t2.name_, t2.male, t2.female from tmp2 t1
left outer join gender_binary_name   t2
on t1.inventor1 = t2.name_
order by 1
) where name_ is null) s1
inner join gender_binary_name   s2
on s1.inventor2_2 = s2.name_
union
select distinct t1.publication_number, t1.inventor1 , t1.inventor2_2, t2.name_, t2.male, t2.female from tmp2 t1
inner join gender_binary_name   t2
on t1.inventor1 = t2.name_
)
where female=1
 
--List of tables
--t_smeo_gender_age_nationality
--name --> t_smeo_name_gender_probability
--decade --> t_smeo_gender_by_name_decade
--nation --> t_smeo_gender_by_name_nation
-- decade + nation --> t_smeo_gender_by_decade_nation
--name_gender_classification
--name_age_gender_classification
---name_age_nation_gender
select count(*) from gender_binary_nation
where male=0
 
--random_classify_by_name
--random_classify_by_age
--random_classify_by_nation
select * from name_gender_classification
---gender_binary_name  
---gender_binary_age
---gender_binary_nation
--random_binary_name
--random_binary_decade
--random_binary_nation
 
select * from random_binary_name
 
--random_sample_for_test
select count(*) from (
select t1.name_, t1.gender, t2.male, t2.female from random_sample_for_test t1
inner join name_gender_classification   t2
on t1.name_ = t2.name_ or  upper(t1.name_) = upper(t2.name_)
order by 2
)
where male =0 and female =0
--542 unisex classifications
--10261 males, 9955 correct classified, 13 female classified, 293 uni
--9738 females, 9487 correct classified, 2 male classified, 249 uni
select count(*) from (
select t1.name_, t1.gender, t2.male, t2.female from random_sample_for_test t1
inner join gender_binary_name 	t2
on t1.name_ = t2.name_ or  upper(t1.name_) = upper(t2.name_)
order by 2
)
where gender = 100995 and male =0
--20000 matches
--9739 females, 9697 correct classisifed, 42 mis classified
--10261 males, 10185 males correct, 76 incorrect
select * from  random_sample_for_test
select count(*) from (
select t1.name_, t1.gender, t1.birthyear, t2.decade,t2.male, t2.female from random_sample_for_test t1
inner join name_age_gender_classification 	t2
on   upper(t1.name_) = upper(t2.name_) and floor(t1.birthyear/10) = t2.decade
order by 2
)
where gender = 100996 and male =0 and female =0
--19993 matches
--10261 males, 9991 corrrect, 12 female, 258 uni
--9732 females, 9405 correct, 3 male, 324 uni
 
select count(*) from (
select t1.name_, t1.gender, t1.birthyear, t2.decade,t2.male, t2.female from random_sample_for_test t1
inner join gender_binary_age 	t2
on   upper(t1.name_) = upper(t2.name_) and floor(t1.birthyear/10) = t2.decade
order by 2
)
where gender = 100996 and female =0
 
--20000 matches
--9739 females, 9705 corrcet, 34 incorrect
--10261 males, 10189 correct , 72 incorrect
 
select count(*) from (
select t1.name_, t1.gender, t1.birthyear, t2.decade,t2.male, t2.female from random_sample_for_test t1
inner join name_age_nation_gender 	t2
on   upper(t1.name_) = upper(t2.name_) and floor(t1.birthyear/10) = t2.decade and t1.nationality = t2.nationality
order by 2
)
where gender = 100996 and female =0 and male =1
 
---19993 matches
--9732 females, 324 uni, 9405 females, 3 males
--10261 males, 10030 males , 12 females, 219 uni
select count(*) from (
select t1.name_, t1.gender, t1.birthyear, t2.decade,t2.male, t2.female from random_sample_for_test t1
inner join gender_binary_nation 	t2
on   upper(t1.name_) = upper(t2.name_) and floor(t1.birthyear/10) = t2.decade and t1.nationality = t2.nationality
order by 2
)
where gender = 100995 and male =1 and male =1
--9739 females, 31 incorrcet, 9708
--10261, 57 incorrcet, 10204
 
