-- SQL Assignment 2


USE pets;

select * from petowners;
select * from pets;
select * from proceduresdetails;
select * from procedureshistory;

-- 1. List the names of all pet owners along with the names of their pets.

SELECT po.name as owners_first_name, po.surname as owners_last_name, p.name as pet_name
from petowners as po
Inner join pets as p
on po.ownerid = p.ownerid;

-- 2. List all pets and their owner names, including pets that don't have recorded owners.
select p.name as Pet_Name, po.Name as Owner_first_name
from pets as p
left join petowners as po
on po.OwnerID = p.OwnerID;

-- 3. Combine the information of pets and their owners, including those pets without owners and
-- owners without pets.
select p.name as Pet_Name, po.Name as Owner_first_name
from pets as p
left join petowners as po
on po.OwnerID = p.OwnerID
union
select p.name as Pet_Name, po.Name as Owner_first_name
from pets as p
right join petowners as po
on po.OwnerID = p.OwnerID;

-- 4. Find the names of pets along with their owners' names and the details of the procedures they
-- have undergone.

select p.name as Pet_Name, po.Name as Owner_first_name, ph.proceduretype, ph.date as procedure_date
from pets as p
left join petowners as po
on po.OwnerID = p.OwnerID
left join procedureshistory as ph
on p.petid = ph.petid;

-- 5. List all pet owners and the number of dogs they own.
select distinct kind from pets;
select count(kind) from pets where kind = "dog";

select po.name as owners_first_name, count(p.petid) as number_of_dogs
from petowners as po
join pets as p
on po.OwnerID = p.OwnerID
where kind = "dog"
group by owners_first_name;

-- 6. Identify pets that have not had any procedures.
SELECT p.name, ph.proceduretype
FROM pets as p
LEFT JOIN procedureshistory as ph 
ON p.petid = ph.petid
WHERE ph.proceduretype IS NULL;

-- 7. Find the name of the oldest pet.
select * from pets
order by age desc ;

select max(age) from pets;

select name  as pet_name from pets where age = (select max(age) from pets);



-- 8. List all pets who had procedures that cost more than the average cost of all procedures.
select distinct proceduretype from procedureshistory;

select proceduretype, avg(price)
from proceduresdetails
group by proceduretype;

select p.name as Pet_Name, ph.proceduretype, pd.price
from pets as p
join procedureshistory as ph
on p.petid = ph.petid
join proceduresdetails as pd
on ph.proceduresubcode = pd.proceduresubcode
where pd.price > ( select avg(pdd.price)
from proceduresdetails as pdd
group by pdd.proceduretype
having pd.proceduretype =pdd.proceduretype);

-- 9. Find the details of procedures performed on 'Cuddles'.
select p.name as Pet_Name, ph.proceduretype, ph.date as procedure_date
from pets as p
join procedureshistory as ph
on p.petid = ph.petid
where p.name = "Cuddles" ;

-- 10. Create a list of pet owners along with the total cost they have spent on procedures and
-- display only those who have spent above the average spending.


-- subquery - multiple row subquery 
select po.name, avg(price)
from petowners as po
join pets as p on po.ownerid = p.ownerid
join procedureshistory as ph on p.petid = ph.petid
join proceduresdetails as pd on ph.proceduresubcode = pd.proceduresubcode
group by po.name;

-- full query -- 4 tables joined
select po.name as owners_first_name, sum(pd.price) as total_spent
from petowners as po
join pets as p on po.ownerid = p.ownerid
join procedureshistory as ph on p.petid = ph.petid
join proceduresdetails as pd on ph.proceduresubcode = pd.proceduresubcode
group by owners_first_name
having sum(pd.price) > All
(select avg(pd.price)
from petowners as po
join pets as p on po.ownerid = p.ownerid
join procedureshistory as ph on p.petid = ph.petid
join proceduresdetails as pd on ph.proceduresubcode = pd.proceduresubcode
group by po.name);

-- 11. List the pets who have undergone a procedure called 'VACCINATIONS'.


select p.name as pet_name, ph.proceduretype
from pets as p
join procedureshistory as ph on p.petid = ph.petid
where ph.proceduretype = "VACCINATIONS";

-- 12. Find the owners of pets who have had a procedure called 'EMERGENCY'.
select distinct proceduretype from procedureshistory;
select proceduretype, description from proceduresdetails where description = "Emergency";
select count(distinct description) from proceduresdetails;

select po.name as owners_first_name, p.name as pet_name, pd.description
from petowners as po
join pets as p on p.ownerid = po.ownerid
join procedureshistory as ph on ph.petid = p.petid
join proceduresdetails as pd on pd.proceduresubcode = ph.proceduresubcode
where LOWER(pd.description) LIKE "%emergency%";


-- 13. Calculate the total cost spent by each pet owner on procedures.

select po.name as owners_first_name, SUM(pd.price) as total_spent
from petowners as po
join pets as p on po.ownerid = p.ownerid
join procedureshistory as ph on ph.petid = p.petid
join proceduresdetails as pd on pd.proceduresubcode = ph.proceduresubcode
group by po.name; 

-- 14. Count the number of pets of each kind.
select Kind, count(petid)
from pets
group by kind; 

-- 15. Group pets by their kind and gender and count the number of pets in each group. 
select kind, gender, count(petid)
from pets
group by kind, gender;

-- 16. Show the average age of pets for each kind, but only for kinds that have more than 5 pets. 1
-- | Pa ge
select kind, count(petid), avg(age)
from pets
group by kind
having count(petid) > 5;

-- 17. Find the types of procedures that have an average cost greater than $50.
select proceduretype, avg(price)
from proceduresdetails
group by proceduretype
having avg(price) > 50;


-- 18. Classify pets as 'Young', 'Adult', or 'Senior' based on their age. Age less then 3 Young, Age
-- between 3and 8 Adult, else Senior.
select *, case when age < 3 then "Young"
when age >= 3 and age < 8 then "Adult"
when age >= 8 then "Senior"
else null
end as Classifiedbyage
from pets;


-- 19. Calculate the total spending of each pet owner on procedures, labeling them as 'Low
-- Spender' for spending under $100, 'Moderate Spender' for spending between $100 and $500,
-- and 'High Spender' for spending over $500.

select po.name as owners_first_name, SUM(pd.price) as spending, 
case 
when SUM(pd.price) < 100 then 'Low Spender'
when SUM(pd.price) >= 100 and SUM(pd.price) < 500 then 'Moderate Spender'
when SUM(pd.price) >= 500 then 'High Spender'
else null
end as Status
from petowners as po
join pets as p on po.ownerid = p.ownerid
join procedureshistory as ph on ph.petid = p.petid
join proceduresdetails as pd on pd.proceduresubcode = ph.proceduresubcode
group by po.name; 

-- 20. Show the gender of pets with a custom label ('Boy' for male, 'Girl' for female).

select name, gender, case 
when gender = "male" then "boy"
when gender = "female" then "girl"
else null
end as gender_label
from pets;

-- 21. For each pet, display the pet's name, the number of procedures they've had,
select * from petowners;
select * from pets;
select * from proceduresdetails;
select * from procedureshistory;

select p.name, count(ph.proceduretype) as total_procedures
from pets as p
join procedureshistory as ph
on ph.petid = p.petid
group by p.name;



-- Best of luck!




