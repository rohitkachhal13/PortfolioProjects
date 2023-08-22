/*
Rules to analyze the Student Performance:
•	There are five parameters to analyze the student performance. Parameters are: FA, P, PS, A, E (Test) & OD (For class 3 to 5 subject: Math, EVS & For class 6 to 10 subject: Math, Science).
•	The calculation for different parameter based on class.
•	Exam type for class 3 to 9 & 11 is “UT1”. However, for class 10 & 12 it is “FE1”
•	If parameter is “FA”:
        o	For class 3 to 4 “FA” max marks is 5 in case of subject ‘Math’ & ‘EVS’ & for rest subject “FA” max marks is 10.
        o	For class 5 to 10 “FA” max marks is 5 in case of subject ‘Math’ & ‘Science’ & for rest subject “FA” max marks is 10.
        o	 For class 11 & 12 “FA” max marks is 5.
•	If parameter is “PS”: For all subjects of all class max marks is 5.
•	If parameter is “P”: For all subjects of all class max marks is 5.
•	If parameter is “A”: 
        o	For class 3 to 10 max marks is 10.
        o	For class 11 & 12 max marks is 5.
•	If parameter is “E”: 
        o	For class 3 to 10 max marks is 20.
        o	For class 11 & 12 max marks is 30.
•	If parameter is “OD”: 
        o	For class 3 to 5 subjects are ‘Math’ & ‘EVS’ with max marks is 5.
        o	For class 6 to 10 subjects are ‘Math’ & ‘Science’ with max marks is 5.
        o	“OD” is not applicable for class 11 & 12.
*/	

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------From Google Big Data

------Table 1 :  rd

SELECT time_usec,date(timestamp_micros(time_usec)) as Date,email, event_name,event_type,record_type,org_unit_name_path[SAFE_OFFSET(2)] as 
       log_user_branch,org_unit_name_path[SAFE_OFFSET(3)] as log_user_session,org_unit_name_path[SAFE_OFFSET(4)] as log_user_class_section,
       classroom.course_id,classroom.course_title,classroom.course_work_type,classroom.post_id,classroom.course_work_title,classroom.submission_state,
       classroom.is_late,classroom.has_grade,classroom.impacted_users,classroom.submission_id,classroom.draft_grade,classroom.grade,classroom.
       attachment_types 
FROM `slps-test.slps_analytics.activity` 
WHERE record_type = "classroom" 
and 
(
  UPPER(classroom.course_work_title) LIKE UPPER('UT1%')
OR UPPER(classroom.course_work_title) LIKE UPPER('HY%')
OR UPPER(classroom.course_work_title) LIKE UPPER('UT2%')
OR UPPER(classroom.course_work_title) LIKE UPPER('AE%')
OR UPPER(classroom.course_work_title) LIKE UPPER('FE1%')
OR UPPER(classroom.course_work_title) LIKE UPPER('NA%')
)

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------User Information Table

------Table 2 : infouser

---------Schema
-----------U_Name    String
-----------U_Email   String
-----------U_OU      String

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------Impacted user name from rd & infouser table

------View 1 : rd1

SELECT time_usec,Date,email,log_user_branch,log_user_session,log_user_class_section,record_type,course_work_type,event_name,event_type,course_title,course_work_title,SPLIT(course_work_title, '_')[safe_ordinal(1)] AS Exam_Type,
SPLIT(course_work_title, '_')[safe_ordinal(2)] AS Result_Parameter,SPLIT(course_work_title, '_')[safe_ordinal(5)] AS Assignment_Type,UPPER(SPLIT(course_work_title, '_')[safe_ordinal(3)]) AS Subject,
SPLIT(course_work_title, '_')[safe_ordinal(4)] AS Chapter,impacted_users[SAFE_OFFSET(0)] AS impact_user_id,U_Name AS impact_user_name,SPLIT(course_title, '_')[safe_ordinal(2)] AS impact_user_class_section,
SPLIT(course_work_title, '_')[safe_ordinal(7)] AS Max_Marks,draft_grade,grade,course_id,submission_id,post_id,submission_state,is_late,has_grade,attachment_types
FROM `slps-test.slps_analytics.rd`,`slps-test.slps_analytics.infouser`
WHERE log_user_class_section = 'Teachers'
AND event_name = 'set_grade'
AND impacted_users[SAFE_OFFSET(0)] = U_Email

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------Log user name from rd1 & infouser

------View 2 : rd2

SELECT time_usec,Date,email,log_user_branch,log_user_session,log_user_class_section,record_type,course_work_type,event_name,event_type,U_Name as Teacher_Name,course_title,course_work_title,Exam_Type,Result_Parameter,
Assignment_Type,Subject,Chapter,impact_user_id,impact_user_name,impact_user_class_section,Max_Marks,draft_grade,grade,course_id,submission_id,post_id,submission_state,is_late,has_grade,attachment_types
FROM `slps-test.slps_analytics.rd_1`,`slps-test.slps_analytics.infouser`
WHERE email = U_Email

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------Defining Class Name from rd2
------View 3 : rd3_for_class

SELECT *,
CASE 
WHEN Impact_user_class_section = 'Foundation Blue' or Impact_user_class_section = 'Foundation Green' or Impact_user_class_section = 'Foundation Orange' or Impact_user_class_section = 'Foundation Purple' or 
Impact_user_class_section = 'Foundation Red' 
THEN 'Foundation'

WHEN Impact_user_class_section = 'Nursery Blue' or Impact_user_class_section = 'Nursery Green' or Impact_user_class_section = 'Nursery Orange' or Impact_user_class_section = 'Nursery Purple' or 
Impact_user_class_section = 'Nursery Red' 
THEN 'Nursery'

WHEN Impact_user_class_section = 'KG Blue' or Impact_user_class_section = 'KG Green' or Impact_user_class_section = 'KG Orange' or Impact_user_class_section = 'KG Purple' or Impact_user_class_section = 'KG Red' 
THEN 'KG'

WHEN Impact_user_class_section = 'I BLUE' or Impact_user_class_section = 'I GREEN' or Impact_user_class_section = 'I ORANGE' or Impact_user_class_section = 'I PURPLE' or Impact_user_class_section = 'I RED' 
THEN 'I'

WHEN Impact_user_class_section = 'II BLUE' or Impact_user_class_section = 'II GREEN' or Impact_user_class_section = 'II ORANGE' or Impact_user_class_section = 'II PURPLE' or Impact_user_class_section = 'II RED' 
THEN 'II'

WHEN Impact_user_class_section = 'III BLUE' or Impact_user_class_section = 'III GREEN' or Impact_user_class_section = 'III ORANGE' or Impact_user_class_section = 'III PURPLE' or Impact_user_class_section = 'III RED' 
THEN 'III'

WHEN Impact_user_class_section = 'IV BLUE' or Impact_user_class_section = 'IV GREEN' or Impact_user_class_section = 'IV ORANGE' or Impact_user_class_section = 'IV PURPLE' or Impact_user_class_section = 'IV RED' 
THEN 'IV'

WHEN Impact_user_class_section = 'V BLUE' or Impact_user_class_section = 'V GREEN' or Impact_user_class_section = 'V ORANGE' or Impact_user_class_section = 'V PURPLE' or Impact_user_class_section = 'V RED' 
THEN 'V'

WHEN Impact_user_class_section = 'VI A' or Impact_user_class_section = 'VI B' or Impact_user_class_section = 'VI C' or Impact_user_class_section = 'VI D' or Impact_user_class_section = 'VI E' 
THEN 'VI'

WHEN Impact_user_class_section = 'VII A' or Impact_user_class_section = 'VII B' or Impact_user_class_section = 'VII C' or Impact_user_class_section = 'VII D' or Impact_user_class_section = 'VII E' or 
Impact_user_class_section = 'VII F'
THEN 'VII'

WHEN Impact_user_class_section = 'VIII A' or Impact_user_class_section = 'VIII B' or Impact_user_class_section = 'VIII C' or Impact_user_class_section = 'VIII D' or Impact_user_class_section = 'VIII E' or 
Impact_user_class_section = 'VIII F'
THEN 'VIII'

WHEN Impact_user_class_section = 'IX A' or Impact_user_class_section = 'IX B' or Impact_user_class_section = 'IX C' or Impact_user_class_section = 'IX D' or Impact_user_class_section = 'IX E' or 
Impact_user_class_section = 'IX F'
THEN 'IX'

WHEN Impact_user_class_section = 'X A' or Impact_user_class_section = 'X B' or Impact_user_class_section = 'X C' or Impact_user_class_section = 'X D' or Impact_user_class_section = 'X E' or 
Impact_user_class_section = 'X F'
THEN 'X'

WHEN Impact_user_class_section = 'XI A' or Impact_user_class_section = 'XI B' or Impact_user_class_section = 'XI C' or Impact_user_class_section = 'XI D' or Impact_user_class_section = 'XI E' or 
Impact_user_class_section = 'XI F'
THEN 'XI'

WHEN Impact_user_class_section = 'XII A' or Impact_user_class_section = 'XII B' or Impact_user_class_section = 'XII C' or Impact_user_class_section = 'XII D' or Impact_user_class_section = 'XII E' or 
Impact_user_class_section = 'XII F'
THEN 'XII'

ELSE Impact_user_class_section
END AS Major_Class
FROM `slps-test.slps_analytics.rd_2`

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------Converting marks from string to float from rd3_for_class

------View 4 : rd_4

SELECT time_usec,Date,email,log_user_branch,log_user_session,log_user_class_section,record_type,course_work_type,event_name,event_type,Teacher_Name,course_title,course_work_title,Exam_Type,Result_Parameter,Assignment_Type,
Subject,Chapter,impact_user_id,impact_user_name,impact_user_class_section,SAFE_CAST(Max_Marks AS FLOAT64) as M_Marks,draft_grade,SAFE_CAST(grade AS FLOAT64) as Grade,course_id,submission_id,post_id,submission_state,is_late,has_grade,
attachment_types,Major_Class
FROM `slps_analytics.rd_3_for_class`

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------Latest log of each segment from rd_4

------Viwe 5 : rd_4_max

SELECT t.*
FROM `slps-test.slps_analytics.rd_4` t
JOIN
(SELECT MAX(time_usec) as y,impact_user_id,course_id,post_id
FROM `slps-test.slps_analytics.rd_4` 
GROUP BY impact_user_id,course_id,post_id) h
ON t.time_usec = h.y
ORDER BY t.impact_user_id

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------Unique log of latest log of each segment from rd_4_max

------View 6 : rd_4_unique

SELECT DISTINCT(time_usec),Date,email,log_user_branch,log_user_session,log_user_class_section,record_type,course_work_type,event_name,event_type,Teacher_Name,course_title,course_work_title,Exam_Type,Result_Parameter,
Assignment_Type,Subject,Chapter,impact_user_id,impact_user_name,impact_user_class_section,Major_Class,M_Marks,draft_grade,grade,course_id,submission_id,post_id
FROM `slps_analytics.rd_4_max`
order by impact_user_id

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------“FA” of each subject for student from rd_4_unique

------View 7 :  rd_5_fa

SELECT time_usec,Date,email,log_user_branch,log_user_session,log_user_class_section,record_type,course_work_type,event_name,event_type,Teacher_Name,course_title,course_work_title,Exam_Type,Subject,Chapter,impact_user_id,
impact_user_name,impact_user_class_section,Major_Class,Result_Parameter,Assignment_Type,M_Marks,draft_grade,Grade as FA_Mark,course_id,submission_id,post_id
FROM `slps-test.slps_analytics.rd_4_unique`
WHERE Result_Parameter = 'FA'
ORDER BY impact_user_id

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------Marks conversion of “FA” as per rules from rd_5

------View 8 : rd_5_fa_avg

SELECT Subject,Exam_Type,Result_Parameter,impact_user_id,impact_user_name,impact_user_class_section,Major_Class,course_id,ROUND(SUM(M_Marks),1) as FA_M_Marks, ROUND(SUM(FA_Mark),1) as FA_Total_Marks,

CASE 
WHEN (Exam_Type = 'UT1' AND Subject !='MATH' AND Subject != 'EVS' AND (Major_Class = 'III' OR Major_Class = 'IV'))
THEN ROUND((SUM(FA_Mark)/SUM(M_Marks))*10,1)

WHEN (Exam_Type = 'UT1' AND Subject ='MATH' OR Subject = 'EVS' AND (Major_Class = 'III' OR Major_Class = 'IV'))
THEN ROUND((SUM(FA_Mark)/SUM(M_Marks))*5,1)

WHEN (Exam_Type = 'UT1' AND Subject !='MATH' AND Subject != 'SCIENCE' AND (Major_Class = 'V'))
THEN ROUND((SUM(FA_Mark)/SUM(M_Marks))*10,1)

WHEN (Exam_Type = 'UT1' AND Subject ='MATH' OR Subject = 'SCIENCE' AND (Major_Class = 'V'))
THEN ROUND((SUM(FA_Mark)/SUM(M_Marks))*5,1)        

WHEN (Exam_Type = 'UT1' AND Subject !='MATH' AND Subject != 'SCIENCE' AND (Major_Class = 'VI' OR Major_Class = 'VII' OR Major_Class = 'VIII' OR Major_Class = 'IX'))
THEN ROUND((SUM(FA_Mark)/SUM(M_Marks))*10,1)

WHEN (Exam_Type = 'UT1' AND Subject ='MATH' OR Subject = 'SCIENCE' AND (Major_Class = 'VI' OR Major_Class = 'VII' OR Major_Class = 'VIII' OR Major_Class = 'IX'))
THEN ROUND((SUM(FA_Mark)/SUM(M_Marks))*5,1)

WHEN (Exam_Type = 'FE1' AND Subject !='MATH' AND Subject != 'SCIENCE' AND Major_Class = 'X')
THEN ROUND((SUM(FA_Mark)/SUM(M_Marks))*10,1)

WHEN (Exam_Type = 'FE1' AND Subject ='MATH' OR Subject = 'SCIENCE' AND Major_Class = 'X')
THEN ROUND((SUM(FA_Mark)/SUM(M_Marks))*5,1)

WHEN Exam_Type = 'UT1' AND Major_Class = 'XI'
THEN ROUND((SUM(FA_Mark)/SUM(M_Marks))*5,1)

WHEN Exam_Type = 'FE1' AND Major_Class = 'XII'
THEN ROUND((SUM(FA_Mark)/SUM(M_Marks))*5,1)

ELSE null
END AS FA_Final_Marks
FROM `slps_analytics.rd_5_fa`

GROUP BY impact_user_id,Subject,Major_Class,impact_user_class_section,Exam_Type,Result_Parameter,impact_user_name,course_id

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------“PS” of each subject for student from rd_4_unique

------View 9 :  rd_6_ps

SELECT time_usec,Date,email,log_user_branch,log_user_session,log_user_class_section,record_type,course_work_type,event_name,event_type,Teacher_Name,course_title,course_work_title,Exam_Type,Subject,Chapter,impact_user_id,
impact_user_name,impact_user_class_section,Major_Class,Result_Parameter,Assignment_Type,M_Marks,draft_grade,Grade as PS_Mark,course_id,submission_id,post_id
FROM `slps-test.slps_analytics.rd_4_unique`
WHERE Result_Parameter = 'PS'
ORDER BY impact_user_id

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------Marks conversion of “PS” as per rules from rd_6_ps

------View 10 : rd_6_ps_avg

SELECT Subject,Result_Parameter,Exam_Type,impact_user_id,impact_user_name,impact_user_class_section,Major_Class,course_id,ROUND(SUM(M_Marks),1) as PS_M_Marks, ROUND(SUM(PS_Mark),1) as PS_Total_Marks,

CASE 
WHEN (Exam_Type = 'UT1' AND (Major_Class = 'III' OR Major_Class = 'IV' OR Major_Class = 'V' OR Major_Class = 'VI' OR Major_Class = 'VII' OR Major_Class = 'VIII' OR Major_Class = 'IX' OR Major_Class = 'XI'))
THEN ROUND((SUM(PS_Mark)/SUM(M_Marks))*5,1)

WHEN (Exam_Type = 'FE1' AND (Major_Class = 'X' OR Major_Class = 'XII'))
THEN ROUND((SUM(PS_Mark)/SUM(M_Marks))*5,1)

ELSE null
END AS PS_Final_Marks
FROM `slps_analytics.rd_6_ps`
GROUP BY impact_user_id,Subject,impact_user_class_section,Major_Class,Result_Parameter,Exam_Type,impact_user_name,course_id

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------“P” of each subject for student from rd_4_unique

------View 11 :  rd_7_p

SELECT time_usec,Date,email,log_user_branch,log_user_session,log_user_class_section,record_type,course_work_type,event_name,event_type,Teacher_Name,course_title,course_work_title,Exam_Type,Subject,Chapter,impact_user_id,
impact_user_name,impact_user_class_section,Major_Class,Result_Parameter,Assignment_Type,M_Marks,draft_grade,Grade as P_Mark,course_id,submission_id,post_id
FROM `slps-test.slps_analytics.rd_4_unique`
WHERE Result_Parameter = 'P'
ORDER BY impact_user_id

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------Marks conversion of “P” as per rules from rd_7_p

------View 12 : rd_7_p_avg

SELECT Subject,Result_Parameter,Exam_Type,impact_user_id,impact_user_name,impact_user_class_section,Major_Class,course_id, ROUND(SUM(M_Marks),1) as P_M_Marks, ROUND(SUM(P_Mark),1) as P_Total_Marks,

CASE 
WHEN (Exam_Type = 'UT1' AND (Major_Class = 'III' OR Major_Class = 'IV' OR Major_Class = 'V' OR Major_Class = 'VI' OR Major_Class = 'VII' OR Major_Class = 'VIII' OR Major_Class = 'IX' OR Major_Class = 'XI'))
THEN ROUND((SUM(P_Mark)/SUM(M_Marks))*5,1)

WHEN (Exam_Type = 'FE1' AND (Major_Class = 'X' OR Major_Class = 'XII'))
THEN ROUND((SUM(P_Mark)/SUM(M_Marks))*5,1)

ELSE null
END AS P_Final_Marks
FROM `slps_analytics.rd_7_p`

GROUP BY impact_user_id,Subject,impact_user_class_section,Major_Class,Result_Parameter,Exam_Type,impact_user_name,course_id

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------“A” of each subject for student from rd_4_unique

------View 13 :  rd_8_a

SELECT time_usec,Date,email,log_user_branch,log_user_session,log_user_class_section,record_type,course_work_type,event_name,event_type,Teacher_Name,course_title,course_work_title,Exam_Type,Subject,Chapter,impact_user_id,
impact_user_name,impact_user_class_section,Major_Class,Result_Parameter,Assignment_Type,M_Marks,draft_grade,Grade as A_Mark,course_id,submission_id,post_id
FROM `slps-test.slps_analytics.rd_4_unique`
WHERE Result_Parameter = 'A'
ORDER BY impact_user_id

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------Marks conversion of “A” as per rules from rd_8_a

------View 14 :  rd_8_a_avg

SELECT Subject,Result_Parameter,Exam_Type,impact_user_id,impact_user_name,impact_user_class_section,Major_Class,course_id, ROUND(SUM(M_Marks),1) as A_M_Marks, ROUND(SUM(A_Mark),1) as A_Total_Marks,

CASE 
WHEN Exam_Type = 'UT1' AND Major_Class = 'XI'
THEN ROUND((SUM(A_Mark)/SUM(M_Marks))*5,1)

WHEN Exam_Type = 'FE1' AND Major_Class = 'XII'
THEN ROUND((SUM(A_Mark)/SUM(M_Marks))*5,1)

WHEN Exam_Type = 'UT1' AND (Major_Class = 'III' OR Major_Class = 'IV' OR Major_Class = 'V' OR Major_Class = 'VI' OR Major_Class = 'VII' OR Major_Class = 'VIII' OR Major_Class = 'IX')
THEN ROUND((SUM(A_Mark)/SUM(M_Marks))*10,1)

WHEN Exam_Type = 'FE1' AND Major_Class = 'X'
THEN ROUND((SUM(A_Mark)/SUM(M_Marks))*10,1)

ELSE null
END AS A_Final_Marks
FROM `slps_analytics.rd_8_a`
GROUP BY impact_user_id,Subject,impact_user_class_section,Major_Class,Result_Parameter,Exam_Type,impact_user_name,course_id

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------“E” of each subject for student from rd_4_unique

------View 15 :  rd_9_e

SELECT time_usec,Date,email,log_user_branch,log_user_session,log_user_class_section,record_type,course_work_type,event_name,event_type,Teacher_Name,course_title,course_work_title,Exam_Type,Subject,Chapter,impact_user_id,
impact_user_name,impact_user_class_section,Major_Class,Result_Parameter,Assignment_Type,M_Marks,draft_grade,Grade as E_Mark,course_id,submission_id,post_id
FROM `slps-test.slps_analytics.rd_4_unique`
WHERE Result_Parameter = 'E'
ORDER BY impact_user_id

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------Marks conversion of “E” as per rules from rd_9_e

------View 16 :  rd_9_e_avg

SELECT Subject,Result_Parameter,Exam_Type,impact_user_id,impact_user_name,impact_user_class_section,Major_Class,course_id, ROUND(SUM(M_Marks),1) as E_M_Marks, ROUND(SUM(E_Mark),1) as E_Total_Marks,

CASE 
WHEN Exam_Type = 'UT1' AND Major_Class = 'XI'
THEN ROUND((SUM(E_Mark)/SUM(M_Marks))*30,1)

WHEN Exam_Type = 'FE1'AND Major_Class = 'XII'
THEN ROUND((SUM(E_Mark)/SUM(M_Marks))*30,1)

WHEN Exam_Type = 'UT1' AND (Major_Class = 'III' OR Major_Class = 'IV' OR Major_Class = 'V' OR Major_Class = 'VI' OR Major_Class = 'VII' OR Major_Class = 'VIII' OR Major_Class = 'IX')
THEN ROUND((SUM(E_Mark)/SUM(M_Marks))*20,1)

WHEN Exam_Type = 'FE1' AND Major_Class = 'X'
THEN ROUND((SUM(E_Mark)/SUM(M_Marks))*20,1)

ELSE null
END AS E_Final_Marks
FROM `slps_analytics.rd_9_e`
GROUP BY impact_user_id,Subject,impact_user_class_section,Major_Class,Result_Parameter,Exam_Type,impact_user_name,course_id

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------“OD” of each subject for student from rd_4_unique

------View 17 :  rd_10_od

SELECT time_usec,Date,email,log_user_branch,log_user_session,log_user_class_section,record_type,course_work_type,event_name,event_type,Teacher_Name,course_title,course_work_title,Exam_Type,Subject,Chapter,impact_user_id,
impact_user_name,impact_user_class_section,Major_Class,Result_Parameter,Assignment_Type,M_Marks,draft_grade,Grade as OD_Mark,course_id,submission_id,post_id
FROM `slps-test.slps_analytics.rd_4_unique`
WHERE Result_Parameter = 'OD'
ORDER BY impact_user_id

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------Marks conversion of “OD” as per rules from rd_10_od

------View 18 :  rd_10_od_avg

SELECT Subject,Result_Parameter,Exam_Type,impact_user_id,impact_user_name,impact_user_class_section,Major_Class,course_id,ROUND(SUM(M_Marks),1) as OD_M_Marks, ROUND(SUM(OD_Mark),1) as OD_Total_Marks,

CASE 
WHEN (Exam_Type = 'UT1' AND (Major_Class = 'III' OR Major_Class = 'IV' OR Major_Class = 'V' OR Major_Class = 'VI' OR Major_Class = 'VII' OR Major_Class = 'VIII' OR Major_Class = 'IX'))
THEN ROUND((SUM(OD_Mark)/SUM(M_Marks))*5,1)

WHEN (Exam_Type = 'FE1' AND Major_Class = 'X')
THEN ROUND((SUM(OD_Mark)/SUM(M_Marks))*5,1)

ELSE null
END AS OD_Final_Marks
FROM `slps_analytics.rd_10_od`
GROUP BY impact_user_id,Subject,impact_user_class_section,Major_Class,Result_Parameter,Exam_Type,impact_user_name,course_id

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------Joining “FA” &  “PS” marks from rd_5_fa_avg & rd_6_ps_avg

------View 19 :  rd_11_Total_fa_ps

SELECT a.Subject,a.Exam_Type,a.impact_user_id,a.impact_user_name,a.impact_user_class_section,a.Major_Class,a.course_id,a.FA_M_Marks,a.FA_Total_Marks,a.FA_Final_Marks,b.PS_M_Marks,b.PS_Total_Marks,b.PS_Final_Marks
FROM `slps_analytics.rd_5_fa_avg` a
LEFT OUTER JOIN `slps_analytics.rd_6_ps_avg` b
ON a.impact_user_id = b.impact_user_id
AND a.Subject = b.Subject
AND a.course_id = b.course_id
AND a.Exam_Type = b.Exam_Type
ORDER BY a.impact_user_id

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------Joining  “P” marks into rd_11_Total_fa_ps from rd_7_p_avg

------View 20 :  rd_11_Total_fa_ps_p

SELECT a.*,b.P_M_Marks,b.P_Total_Marks,b.P_Final_Marks
FROM `slps_analytics.rd_11_Total_fa_ps` a
LEFT OUTER JOIN `slps_analytics.rd_7_p_avg` b
ON a.impact_user_id = b.impact_user_id
AND a.Subject = b.Subject
AND a.course_id = b.course_id
AND a.Exam_Type = b.Exam_Type
ORDER BY a.impact_user_id

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------Joining  “A” marks into rd_11_Total_fa_ps_p from rd_8_a_avg

------View 21 :  rd_11_Total_fa_ps_p_a

SELECT a.*,b.A_M_Marks,b.A_Total_Marks,b.A_Final_Marks
FROM `slps_analytics.rd_11_Total_fa_ps_p` a
LEFT OUTER JOIN `slps_analytics.rd_8_a_avg` b
ON a.impact_user_id = b.impact_user_id
AND a.Subject = b.Subject
AND a.course_id = b.course_id
AND a.Exam_Type = b.Exam_Type
ORDER BY a.impact_user_id

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------Joining  “E” marks into rd_11_Total_fa_ps_p_a from rd_9_e_avg

------View 22 :  rd_11_Total_fa_ps_p_a_e

SELECT a.*,b.E_M_Marks,b.E_Total_Marks,b.E_Final_Marks
FROM `slps_analytics.rd_11_Total_fa_ps_p_a` a
LEFT OUTER JOIN `slps_analytics.rd_9_e_avg` b
ON a.impact_user_id = b.impact_user_id
AND a.Subject = b.Subject
AND a.course_id = b.course_id
AND a.Exam_Type = b.Exam_Type
ORDER BY a.impact_user_id

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------Joining  “OD” marks into rd_11_Total_fa_ps_p_a_e from rd_10_od_avg

------View 23 :  rd_13_all

SELECT a.*,b.OD_M_Marks AS OD_M_Marks,b.OD_Total_Marks AS OD_Total_Marks,b.OD_Final_Marks AS OD_Final_Marks
FROM `slps_analytics.rd_11_Total_fa_ps_p_a_e` a
LEFT OUTER JOIN `slps_analytics.rd_10_od_avg` b
ON a.impact_user_id = b.impact_user_id
AND a.Subject = b.Subject
AND a.course_id = b.course_id
AND a.Exam_Type = b.Exam_Type
ORDER BY a.impact_user_id


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------Adding the different parameter marks for each subject from rd_13_all to finalize the data

------View 24 :  rd_13_all_final

SELECT *,(COALESCE(FA_Final_Marks,0)+COALESCE(PS_Final_Marks,0)+COALESCE(P_Final_Marks,0)+COALESCE(A_Final_Marks,0)+COALESCE(E_Final_Marks,0)+COALESCE(OD_Final_Marks,0)) AS TOTAL
FROM `slps_analytics.rd_13_all`





