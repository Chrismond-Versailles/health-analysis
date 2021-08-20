-- Question 1: Calculate the number of health facilities per commune.
SELECT adm2_en , COUNT(facdesc_1)
FROM commune as c
INNER JOIN spa as s
on c.adm2code = s.adm2code
INNER JOIN factype as f
on f.factype = s.factype
GROUP by adm2_en

 -- Calculate the number of health facilities by commune and by type of health facility.
SELECT DISTINCT(adm2_en) , count(facdesc_1), facdesc
FROM commune as c
INNER JOIN spa as s
on c.adm2code = s.adm2code
INNER JOIN factype as f
on f.factype = s.factype
GROUP by adm2_en ,facdesc

-- Calculate the number of health facilities by municipality and by department
SELECT c.adm2_en  , d.adm1_en  ,facdesc,count(facdesc)
FROM commune as c
INNER JOIN departement as d
on c.adm1code = d.adm1code
INNER JOIN spa as s
on s.adm2code = c.adm2code
INNER JOIN factype as f
on f.factype = s.factype

-- Calculate the number of sites by type (mga) and by department.
SELECT count(d.adm1_en), adm1_en, mga
FROM departement as d
INNER JOIN spa as s
on s.adm1code = d.adm1code
GROUP by mga ,adm1_en

-- Calculate the number of sites with an ambulance by commune and by department (ambulance = 1.0).
SELECT c.adm2_en  , d.adm1_en  ,facdesc,count(facdesc)
FROM commune as c
INNER JOIN departement as d
on c.adm1code = d.adm1code
INNER JOIN spa as s
on s.adm2code = c.adm2code
INNER JOIN factype as f
on f.factype = s.factype
WHERE ambulance = 1.0
GROUP by d.adm1_en,c.adm2_en

-- Calculate the number of hospitals per 10k inhabitants by department.
SELECT count(facdesc_1= 'HOPITAL')* 10000 /sum(c.IHSI_UNFPA_2019) ,d.adm1_en
FROM factype as f
INNER JOIN commune as c
on c.IHSI_UNFPA_2019
INNER JOIN departement as d
on d.adm1code = c.adm1code
GROUP by d.adm1_en

-- Calculate the number of sites per 10k inhabitants per department
SELECT count(facdesc_1)* 10000 /sum(c.IHSI_UNFPA_2019) ,d.adm1_en
FROM factype as f
INNER JOIN commune as c
on c.IHSI_UNFPA_2019
INNER JOIN departement as d
on d.adm1code = c.adm1code
GROUP by d.adm1_en

-- Calculate the number of beb per 1,000 inhabitants per department.
SELECT sum(num_beds)* 10000 /sum(d.IHSI_UNFPA_2019) ,d.adm1_en
FROM factype as f
INNER JOIN spa as s
on s.factype = f.factype
INNER JOIN departement as d
on s.adm1code = d.adm1code
GROUP by d.adm1_en

-- Question 10. How many communes have fewer dispensaries than hospitals?
CREATE VIEW Dispensaire AS
SELECT x.[adm2_en] as Commune,z.[facdesc_1] AS Health_Facility, COUNT(k.[factype]) AS Num_Of_Dis
FROM [Haiti_Health_Data_Analysis].[dbo].[spa] as k INNER JOIN [Haiti_Health_Data_Analysis].[dbo].[Commune] as x on x.[adm2code]=k.[adm2code] INNER JOIN [Haiti_Health_Data_Analysis].[dbo].[factype] as z on z.factype=k.factype
WHERE (z.facdesc_1)='DISPENSAIRE'
GROUP BY x.adm2_en, z.facdesc_1
​
CREATE VIEW Hopital AS
SELECT x.adm2_en as Commune, t.facdesc_1 AS Health_Facility, COUNT(t.factype) AS Num_Of_Hop
FROM [Haiti_Health_Data_Analysis].[dbo].[spa] as k INNER JOIN [Haiti_Health_Data_Analysis].[dbo].[Commune] as x on x.adm2code=k.adm2code INNER JOIN [Haiti_Health_Data_Analysis].[dbo].[factype] as t  on k.factype=t.factype
WHERE (t.facdesc_1)='HOPITAL'
GROUP BY x.adm2_en, t.facdesc_1
​
SELECT * FROM hopital LEFT JOIN dispensaire on hopital.Commune=dispensaire.Commune
WHERE hopital.Num_Of_Hop > dispensaire.Num_Of_Dis
UNION 
SELECT * FROM hopital RIGHT JOIN dispensaire on hopital.Commune=dispensaire.Commune
WHERE hopital.Num_Of_Hop > dispensaire.Num_Of_Dis

-- Question 11 How many  Letality rate per month
SELECT Datename(m,[document_date]) As Month , Cast(Sum([taux_de_letalite])/Count([taux_de_letalite]) as nvarchar(10)) +' %'  As Letality_Rate From [Haiti_Health_Data_Analysis].[dbo].[Covid_cases]
Group by Datename(m,[document_date])
ORDER By Month

-- Question 12 How many Death rate per month
SELECT Datename(m,[document_date]) As Month , Cast(Sum([taux_de_letalite])/Count([taux_de_letalite]) as nvarchar(10)) +' %'  As Death_Rate From [Haiti_Health_Data_Analysis].[dbo].[Covid_cases]
Group by Datename(m,[document_date])
ORDER By Month
​
-- Question 13 How many Prevalence per month
SELECT Datename(m,[document_date]) As Month , Cast(Sum([c].[cas_confirmes])/Sum([p].[IHSI_UNFPA_2019]) as nvarchar(100)) +' %'  As Prevalence_per_m From [Haiti_Health_Data_Analysis].[dbo].[Covid_cases] AS c 
INNER JOIN [Haiti_Health_Data_Analysis].[dbo].[Departement] As p ON [c].[adm1code] = [p].adm1code
Group by Datename(m,[document_date])
ORDER By Month
​
-- Question 14 How many Prevalence by department
SELECT	Datename(WK,cast([document_date] as date)) As Month,Cast([m].[adm2_en] as text), Cast([c].[cas_confirmes]/[p].[IHSI_UNFPA_2019] as nvarchar(100)) +' %'  As Prevalence_per_m From [Haiti_Health_Data_Analysis].[dbo].[Covid_cases] AS c 
INNER JOIN [Haiti_Health_Data_Analysis].[dbo].[Departement] As p ON [c].[adm1code] = [p].adm1code 
INNeR JOIN [Haiti_Health_Data_Analysis].[dbo].[Commune]  AS m ON [m].[adm1code] = [p].adm1code
Group by m.[adm2_en],[p].[IHSI_UNFPA_2019],[c].[cas_confirmes],Datename(Wk,cast([document_date] as date))
ORDER By Prevalence_per_m DESC

