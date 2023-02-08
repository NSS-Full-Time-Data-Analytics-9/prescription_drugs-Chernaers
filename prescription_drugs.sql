SELECT *
FROM prescriber;

SELECT *
FROM prescription
ORDER BY npi;

SELECT *
FROM zip_fips;

SELECT opioid_drug_flag
FROM drug
WHERE COUNT(opioid_drug_flag);


SELECT *
FROM overdose_deaths;

SELECT *
FROM population;


-- 1. 
--     a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.

SELECT npi, SUM(total_claim_count) AS total_num_claims 
FROM prescription 
GROUP BY npi
ORDER BY total_num_claims DESC;
1881634483 - 99707


    
--     b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.


SELECT nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, SUM(total_claim_count) AS total_num_claims 
FROM prescriber
INNER JOIN prescription
USING(npi)
GROUP BY npi, nppes_provider_first_name, nppes_provider_last_org_name, specialty_description
ORDER BY total_num_claims DESC;

-- 2. 
--     a. Which specialty had the most total number of claims (totaled over all drugs)?

SELECT specialty_description, SUM(total_claim_count) AS total_num_claims 
FROM prescriber
INNER JOIN prescription 
USING(npi) 
GROUP BY specialty_description
ORDER BY total_num_claims DESC;

There are 92 specialties with claims and there are 15 specialties with no claims. 

SELECT specialty_description, SUM(total_claim_count) AS total_num_claims 
FROM prescriber
FULL JOIN prescription 
USING(npi) 
GROUP BY specialty_description
ORDER BY total_num_claims DESC;

These are the specialities all up. We are using this as a checker. 

--     b. Which specialty had the most total number of claims for opioids?


SELECT specialty_description, 
(SELECT COUNT(opioid_drug_flag) AS total_count_of_opioids)
FROM prescription 
INNER JOIN prescriber 
USING(npi)	 
INNER JOIN drug
USING (drug_name)
GROUP BY specialty_description
ORDER BY total_count_of_opioids DESC;

Nurse Practitioner at 175,734

SELECT *
FROM drug;

--     c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

SELECT specialty_description, SUM(total_claim_count) AS total_num_claims 
FROM prescriber
FULL JOIN prescription 
USING(npi) 
GROUP BY specialty_description
ORDER BY total_num_claims DESC;

There are 15 speicalities that appear in the prescriber table that have no assoicated prescriptions in the presription table. 


-- --     d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* 
-- For each specialty, report the percentage of total claims by that specialty which are for opioids. 
-- Which specialties have a high percentage of opioids?

-- 3. 
--     a. Which drug (generic_name) had the highest total drug cost?
SELECT DISTINCT(generic_name)
FROM drug

SELECT total_drug_cost, generic_name
FROM prescription 
	INNER JOIN drug
	USING(drug_name)
ORDER BY total_drug_cost DESC;
There are duplicate names with this syntax. We would need to add up all the same generic drug names. 

SELECT generic_name, SUM(total_drug_cost) AS total_generic_drug_cost
FROM prescription
	INNER JOIN drug
	USING(drug_name)
GROUP BY generic_name
ORDER BY total_generic_drug_cost DESC;

INSULIN GLARGINE, HUM.REC.ANLOG


--     b. Which drug (generic_name) has the hightest total cost per day? **Bonus: 
Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

SELECT generic_name, ROUND(SUM(total_drug_cost)/ 1825, 2) AS total_generic_drug_cost_per_day
FROM prescription
	INNER JOIN drug
	USING(drug_name)
GROUP BY generic_name
ORDER BY total_generic_drug_cost_per_day DESC;

From 2013 - 2017, 5yrs 365 * 5 = 1825 days 


SELECT total_day_supply, drug_name
FROM prescription;

-- 4. 
-- --     a. For each drug in the drug table, return the drug name and then a column named 'drug_type' 
-- which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs 
-- which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.

SELECT drug_name,
CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	 WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	 ELSE 'neither' END AS drug_type
FROM drug
GROUP BY ;

-- --     b. Building off of the query you wrote for part a, 
-- determine whether more was spent (total_drug_cost) on opioids or on antibiotics. 
-- Hint: Format the total costs as MONEY for easier comparision.

SELECT 
	SUM(CASE WHEN opioid_drug_flag = 'Y' THEN CAST(total_drug_cost as money) END) AS o1,
	SUM(CASE WHEN antibiotic_drug_flag = 'Y' THEN CAST(total_drug_cost as money) END) AS a1
	FROM drug
	INNER JOIN prescription 
	USING(drug_name);




SELECT 
FROM prescription;

SELECT drug_name, SUM(total_drug_cost) AS total_opioid_cost
FROM drug
INNER JOIN prescription 
USING(drug_name)
GROUP BY drug_name;

SELECT COUNT(antibiotic_drug_flag), drug_name
FROM drug
WHERE antibiotic_drug_flag = 'Y'
GROUP BY drug_name;

-- 5. 
--     a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.

SELECT f1.fipscounty, c1.cbsa, c1.cbsaname, f1.state
FROM cbsa AS c1
INNER JOIN fips_county AS f1
USING (fipscounty)
WHERE state = 'TN'
GROUP BY c1.cbsaname, f1.fipscounty, c1.cbsa, f1.state;

42

SELECT COUNT(DISTINCT cbsa.cbsa),
		cbsa.cbsaname,
		fips_county.state
FROM cbsa, fips_county
WHERE cbsa.fipscounty = fips_county.fipscounty
	AND fips_county.state = 'TN'
GROUP BY cbsa.cbsaname, fips_county.state;
 
10

--     b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.


SELECT cbsaname, SUM(population) AS combined_pop  
FROM cbsa 
INNER JOIN population 
USING(fipscounty)
GROUP BY cbsaname
ORDER BY combined_pop DESC; 

Nashville-Davidson-Murfreesboro-Franklin, TN 

SELECT cbsaname, SUM(population) AS combined_pop  
FROM cbsa 
INNER JOIN population 
USING(fipscounty)
GROUP BY cbsaname
ORDER BY combined_pop ASC; 

Morristown, TN 

--     c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

SELECT population, county 
FROM population 
LEFT JOIN fips_county
USING(fipscounty)
LEFT JOIN cbsa
USING(fipscounty)
WHERE cbsaname IS NULL
ORDER BY population DESC; 

Sevier County, 53 counties are not in CBSA

-- 6. 
--     a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.


SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count >= '3000'
ORDER BY total_claim_count DESC;
										  
9 rows provided 		


--     b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

SELECT drug_name, total_claim_count, 
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	ELSE 'na' END AS drug_type_opioid
FROM prescription
INNER JOIN drug
USING(drug_name)
WHERE total_claim_count >= '3000'
ORDER BY total_claim_count DESC;

--     c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

SELECT drug_name, total_claim_count, 
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	ELSE 'na' END AS drug_type_opioid, nppes_provider_first_name AS first_name, nppes_provider_last_org_name AS last_name
FROM prescription
INNER JOIN drug
USING(drug_name)
INNER JOIN prescriber
USING(npi)
WHERE total_claim_count >= '3000'
ORDER BY total_claim_count DESC;


-- -- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid.
-- **Hint:** The results from all 3 parts will have 637 rows.

-- --     a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Managment') in the city of Nashville (nppes_provider_city = 'NASHVILLE'), 
-- where the drug is an opioid (opiod_drug_flag = 'Y'). 
-- **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.


SELECT npi, drug_name, specialty_description
FROM prescriber
CROSS JOIN drug
WHERE nppes_provider_city = 'NASHVILLE'
AND opioid_drug_flag = 'Y'
AND specialty_description = 'Pain Management'

	

-- --     b. Next, report the number of claims per drug per prescriber. 
-- Be sure to include all combinations, whether or not the prescriber had any claims. 
-- You should report the npi, the drug name, and the number of claims (total_claim_count). (Had help from B.H)
	
SELECT npi,drug.drug_name,SUM(total_claim_count) AS total_claim_count
FROM prescriber
CROSS JOIN drug
INNER JOIN prescription
USING(npi)
WHERE specialty_description = 'Pain Management'
AND nppes_provider_city ILIKE 'Nashville'
AND opioid_drug_flag = 'Y'
GROUP BY npi, drug.drug_name 

    
-- --     c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0.
-- Hint - Google the COALESCE function. NONE 

SELECT npi,drug.drug_name, (total_claim_count)
FROM prescriber
CROSS JOIN drug
LEFT JOIN prescription
USING(npi)
WHERE specialty_description = 'Pain Management'
AND nppes_provider_city ILIKE 'Nashville'
AND opioid_drug_flag = 'Y'
GROUP BY npi, drug.drug_name





RAN OUT OF TIME, UNABLE TO COMPLETE THE BONUS.
------------------------BONUS------------------------
1
--  How many npi numbers appear in the prescriber table but not in the prescription table?

-- 2.
--     a. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Family Practice.

--     b. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Cardiology.

--     c. Which drugs are in the top five prescribed by Family Practice prescribers and Cardiologists? Combine what you did for parts a and b into a single query to answer this question.

-- 3. Your goal in this question is to generate a list of the top prescribers in each of the major metropolitan areas of Tennessee.
--     a. First, write a query that finds the top 5 prescribers in Nashville in terms of the total number of claims (total_claim_count) across all drugs. Report the npi, the total number of claims, and include a column showing the city.
    
--     b. Now, report the same for Memphis.
    
--     c. Combine your results from a and b, along with the results for Knoxville and Chattanooga.

-- 4. Find all counties which had an above-average number of overdose deaths. Report the county name and number of overdose deaths.
SELECT county, overdose_deaths 
FROM fips_county
INNER JOIN overdose_deaths
USING(fipscounty); 

-- 5.
--     a. Write a query that finds the total population of Tennessee.
    
--     b. Build off of the query that you wrote in part a to write a query that returns for each county that county's name, its population, and the percentage of the total population of Tennessee that is contained in that county.