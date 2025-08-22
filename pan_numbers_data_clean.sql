create table stg_pan_numbers_dataset
(
	pan_number text



);

SELECT * FROM stg_pan_numbers_dataset;

-- Identify and handle missing data
SELECT * FROM stg_pan_numbers_dataset WHERE pan_number IS NULL;

-- Check for duplicates
SELECT pan_number, count(1)
FROM stg_pan_numbers_dataset
GROUP BY pan_number
HAVING count(1) > 1;

-- Handle leading/trailing spaces
SELECT * FROM stg_pan_numbers_dataset WHERE pan_number <> TRIM(pan_number)

--Correct letter case:
SELECT * FROM stg_pan_numbers_dataset WHERE pan_number <> upper(pan_number)



-- Cleaned Pan Number
SELECT distinct upper(trim(pan_number)) as pan_number 
FROM stg_pan_numbers_dataset 
WHERE pan_number IS NOT NULL
AND trim(pan_number) <> '';

-- Function to check if adjacent characters are the same --WUFAR0132H ==> WUFAR
create or replace function fn_check_adjacent_characters(p_str text)
returns boolean
language plpgsql
as $$
begin
	for i in 1 .. (length(p_str) - 1)
	loop
		if substring(p_str, i, 1) = substring(p_str, i+1, 1)
		then
			return true; --the characters are adjacent
		end if;
	end loop;
	return false; -- none of the character adjacent to each other were the same
end;
$$

SELECT fn_check_adjacent_characters('WWFAR')

-- Function to check if sequential characters are used
create or replace function fn_check_sequential_characters(p_str text)
returns boolean
language plpgsql
as $$
begin
	for i in 1 .. (length(p_str) - 1)
	loop
		if ascii(substring(p_str, i+1, 1)) - ascii(substring(p_str, i, 1)) <> 1
		then
			return false; -- the string does not form the sequence
		end if;
	end loop;
	return true; -- the string is forming a sequence
end;
$$


SELECT ascii('C')

-- Regular expression to validate the pattern or the structure of PAN numbers
SELECT
	* FROM stg_pan_numbers_dataset
	WHERE pan_number ~ '^[A-Z]{5}[0-9]{4}[A-Z]$'

-- Valid and Invalid PAN categorization
create or replace view vw_valid_invalid_pans
AS
WITH cte_cleaned_pan AS 
	(SELECT
		DISTINCT upper(trim(pan_number)) as pan_number
	FROM stg_pan_numbers_dataset
	WHERE pan_number is not null
	and trim(pan_number) <> ''),
	cte_valid_pans AS (
	SELECT *
	FROM cte_cleaned_pan
	WHERE fn_check_adjacent_characters(pan_number) = false
AND fn_check_sequential_characters(substring(pan_number,1,5)) = false
AND fn_check_sequential_characters(substring(pan_number,6,4)) = false
AND pan_number ~ '^[A-Z]{5}[0-9]{4}[A-Z]$')

SELECT cln.pan_number,
CASE 
	WHEN vld.pan_number IS NOT NULL then 'Valid PAN' ELSE 'Invalid PAN' END AS status
FROM cte_cleaned_pan cln
LEFT JOIN cte_valid_pans vld on vld.pan_number = cln.pan_number

SELECT * FROM vw_valid_invalid_pans


--Summary report

with cte as (
SELECT
(select count(*) from stg_pan_numbers_dataset) as total_processed_records,
COUNT(*) filter (where status = 'Valid PAN') as total_valid_pans,
COUNT(*) filter (WHERE status = 'Invalid PAN') as total_invalid_pans
FROM vw_valid_invalid_pans)
SELECT total_processed_records, total_valid_pans, total_invalid_pans,
total_processed_records - (total_valid_pans+total_invalid_pans) as total_missing_pans
from cte;