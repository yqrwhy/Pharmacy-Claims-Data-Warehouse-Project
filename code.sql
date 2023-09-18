# QINGRU YANG
use Final;

# Change to m/d/Y
UPDATE fact_drug SET `fill_date` = STR_TO_DATE(fill_date, '%m/%d/%Y');
UPDATE dim_member SET `member_birth_date` = STR_TO_DATE(member_birth_date, '%m/%d/%Y');

# Change first format it as VARCHAR (use VARCHAR(100))
alter table fact_drug change drug_form_code drug_form_code VARCHAR(100)  NULL DEFAULT NULL;
alter table dim_drug_form change drug_form_code drug_form_code VARCHAR(100)  NULL DEFAULT NULL;

# Part 2) Primary and Foreign Key Setup in MySQL
# Primary Key

alter table dim_drug
add primary key (drug_ndc);

alter table dim_drug_brand_generic
add primary key (drug_brand_generic_code);

alter table dim_drug_form
add primary key (drug_form_code);

alter table dim_member
add primary key (member_id);

alter table fact_drug
add id int not null auto_increment primary key;

# Foreign Key

alter table fact_drug
add foreign key fact_drug_member_id_fk(member_id)
references dim_member(member_id)
on delete set null
on update set null;

alter table fact_drug
add foreign key fact_drug_drug_ndc_fk(drug_ndc)
references dim_drug(drug_ndc)
on delete set null
on update set null;

alter table fact_drug
add foreign key fact_drug_brand_generic_fk(drug_brand_generic_code)
references dim_drug_brand_generic(drug_brand_generic_code)
on delete set null
on update set null;

alter table fact_drug
add foreign key fact_drug_drug_form_code_fk(drug_form_code)
references dim_drug_form(drug_form_code)
on delete set null
on update set null;

# Part 4 Analytics and Reporting

# Q1
SELECT drug_name, COUNT(member_id) AS number_prescriptions
FROM dim_drug INNER JOIN fact_drug
ON dim_drug.drug_ndc = fact_drug.drug_ndc
GROUP BY drug_name;

# Q2
select case 
when dim_member.member_age > 50 then '50+'
when dim_member.member_age < 50 then '<50'
end as age_group,
count(distinct dim_member.member_id) as member_numbers,
sum(fact_drug.copay) as sum_copay,
sum(fact_drug.insurancepaid) as sum_insurancepaid,
count(fact_drug.member_id) as number_prescriptions
from dim_member inner join fact_drug
on dim_member.member_id=fact_drug.member_id
group by age_group;

# Q3
create table fill_fact as
select dim_member.member_id,dim_member.member_first_name,dim_member.member_last_name,dim_drug.drug_name,fact_drug.fill_date,fact_drug.insurancepaid
from dim_member
inner join fact_drug
on dim_member.member_id=fact_drug.member_id
inner join dim_drug
on dim_drug.drug_ndc=fact_drug.drug_ndc;

select * from fill_fact;

create table insrance_info as
select drug_name,fill_date,insurancepaid,member_id,member_first_name,member_last_name,
row_number()over(partition by member_id order by member_id,fill_date DESC) as fill_times
from fill_fact;

select * from insrance_info
where fill_times=1;


