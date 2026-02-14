SELECT * FROM public.patient_data
ORDER BY patient_id ASC 

-- 1. How many total deaths occured in the hospital
select sum(case when hospital_death = 1 then 1 else 0 end) as total_hospital_death
from patient_data;		  
               --/OR/--
select count(*) from patient_data where hospital_death = 1;

-- 2. what was the percentage of the mortality rate?
select round(avg(case when hospital_death = 1 then 1 else 0 end)*100,2) as mortality_rate
from patient_data;	 

-- 3. What was the death count of each gender? 
select gender, count(hospital_death) as total_hospital_death
from patient_data where hospital_death = 1 and gender is not null
group by gender;

--
alter table patient_data
alter column age type integer
using age::integer;

-- 4. Age-based comparison of average and maximum  values for patient who died vs survived
select round(avg(age),2) as avg_age,
max(age) as max_age, hospital_death from patient_data 
where hospital_death = 1
group by hospital_death
union
select round(avg(age),2) as avg_age,
max(age) as max_age, hospital_death from patient_data 
where hospital_death = 0
group by hospital_death;

-- 5. Age-based comparison of patient outcomes(death vc survival)
select age, 
  count(case when hospital_death = 1 then 1 else 0 end) as died_patient,
  count(case when hospital_death = 0 then 1 else 0 end) as survived_patient 
 from patient_data 
 where age is not null
 group by age 
 order by age asc; 
 
-- 6. Patient age profile by decade
select concat(ceil(age/10)*10, '_' ,ceil(age/10)*10+9) as age_bracket,
       count(*) as patient_count
from patient_data
where age is not null
group by age_bracket;
                      --/OR/--
select concat(floor(age/10)*10, '_' ,floor(age/10)*10+9) as age_bracket,
       count(*) as patient_count
from patient_data
where age is not null
group by age_bracket;

-- 7. Analyzing mortality counts: senior patients (65+) vs middle‑aged patients (50–65)
select sum(case when age>65 and hospital_death = '0' then 1 else 0 end) as healthy_senior_patients,
       sum(case when age between 50 and 65 and hospital_death = '0' then 1 else 0 end) 
	   as healthy_middle‑aged_patients,
	   sum(case when age>65 and hospital_death = '1' then 1 else 0 end) as dead_senior_patients,
	   sum(case when age between 50 and 65 and hospital_death = '1' then 1 else 0 end) as 
	   dead_middle‑aged_patients
from patient_data;

--
alter table patient_data 
alter column hospital_death_prob type numeric
using hospital_death_prob::numeric;

-- 8. Measuring the average likelihood of hospital death across different age groups
select 
    case when age<40 then '1-40'
	     when age >= 40 and age < 60 then '40-59'
		 when age >= 60 and age < 80 then '60-79'
		 else '80 and above'
		 end as age_group ,
round(avg(hospital_death_prob),3) as avg_death_prob
from patient_data
group by age_group
order by age_group asc;

-- 9. ICU admit source with the largest share of admissions and deaths
select distinct icu_admit_source,
	sum(case when hospital_death = 1 then 1 end) as patient_died,
	sum(case when hospital_death = 0 then 1 end) as patient_survived
from patient_data
where icu_admit_source is not null
group by icu_admit_source;

-- 10. Average age of people in each ICU admit source and patient's death status
select distinct icu_admit_source,
	count(hospital_death) as patients_died,
	round(avg(age),2) as avg_age
from patient_data
where hospital_death = '1'
group by icu_admit_source;
 
-- 11. Average age of people in each type of ICU and amount that died
select distinct icu_type,
	count(hospital_death) as patients_died,
	round(avg(age),2) as avg_age
from patient_data
where hospital_death = 1
group by icu_type;

--
alter table patient_data 
alter column bmi type numeric
using bmi::numeric;

-- 12. Average bmi of people who died
select
	round(avg(bmi),2) as avg_bmi
from patient_data
where hospital_death = 1;

-- 13. Patients are suffering from each comorbidity
select 
    sum(aids) as patients_with_aids,
    sum(cirrhosis) as patients_with_cirrhosis,
    sum(diabetes_mellitus) as patients_with_diabetes,
    sum(hepatic_failure) as patients_with_hepatic_failure,
    sum(immunosuppression) as patients_with_immunosuppression,
    sum(leukemia) as patients_with_leukemia,
    sum(lymphoma) as patients_with_lymphoma
from patient_data;

-- 14. Percentage of patients with each comorbidity among patients who died?
select
    round(sum(case when aids = 1 then 1 else 0 end) * 100 / count(*),2) as aids_percentage,
    round(sum(case when cirrhosis = 1 then 1 else 0 end) * 100 / count(*),2) as cirrhosis_percentage,
    round(sum(case when diabetes_mellitus = 1 then 1 else 0 end) * 100 / count(*),2) as diabetes_percentage,
    round(sum(case when hepatic_failure = 1 then 1 else 0 end) * 100 / count(*),2) as hepatic_failure_percentage,
    round(sum(case when immunosuppression = 1 then 1 else 0 end) * 100 / count(*),2) as immunosuppression_percentage,
    round(sum(case when leukemia = 1 then 1 else 0 end) * 100 / count(*),2) as leukemia_percentage,
    round(sum(case when lymphoma = 1 then 1 else 0 end) * 100 / count(*),2) as lymphoma_percentage
from patient_data
where hospital_death = 1;

-- 15. Mortality rate in percentage
select 
    count(case when hospital_death = 1 then 1 end)*100/ count(*) as mortality_rate
from patient_data;	

-- 16. Percentage of patients who underwent elective surgery
select 
    count(case when elective_surgery = 1 then 1 end)*100/ count(*) as elective_surgery_percentage
from patient_data;	

-- 17. Average bmi for male & female patients who underwent elective surgery
select 
   round(avg(case when gender = 'M' then bmi end),2) as avg_bmi_male,
   round(avg(case when gender = 'F' then bmi end),2) as avg_bmi_female
from patient_data
where elective_surgery = 1;   

-- 18.  Top 10 ICUs with the highest hospital death probability
select icu_type, icu_death_prob
from patient_data
order by icu_death_prob 
limit 10;

-- 19. Average length of stay at each ICU for patients who survived and those who didn't
select 
    icu_type,
    round(avg(case when hospital_death = 1 then pre_icu_los_days end), 2) as avg_icu_stay_death,
    round(avg(case when hospital_death = 0 then pre_icu_los_days end), 2) as avg_icu_stay_survived
from patient_data
group by icu_type
order by icu_type;
