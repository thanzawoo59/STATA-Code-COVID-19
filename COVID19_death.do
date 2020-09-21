********************************************************************************
********************************************************************************
****      Author :THAN ZAW OO
***       Date  :21-9-2020
********************************************************************************
*global c_19 "C:\Users\Lenovo\Google Drive"
set more off
set mem 100m
set trace off
clear

*https://docs.google.com/spreadsheets/d/1-Csmn_rXTQvnkJR8tnFkQEyKBnhq8fz-YxyHidhONiI/edit#gid=97008905


***Importing google sheet into STATA

tempfile gshhet
local sh_id ="1-Csmn_rXTQvnkJR8tnFkQEyKBnhq8fz-YxyHidhONiI"

copy "https://docs.google.com/spreadsheets/d/`sh_id'/export?format=xlsx" `gshhet', replace
import excel `gshhet', sheet("deceased cases")clear firstrow
drop if mi(age)

********************************************************************************
***Recoding age range

recode age (0/5=1 " <6 years") (6/10=2 "6-10 years") (11/20=3 "11-20 years") ///
(21/30=4 "21-30 years") (31/40=5 "31-40 years") (41/50=6 "41-50 years") (51/60=7 "51-60 years") (61/70=8 "61-70 years") (71/80=9 "71-80 years") (81/90=10 "81-90 years") (91/100=10 "91-100 years"), gen (agerange)

replace sex="Female" if sex=="f"
replace sex="Male" if sex=="m"

***Death case & age range
graph hbar (count),  over(agerange, label(labsize(small)))bar(1,color(blue))  bar(2,color(bluishgray ))   blabel(total,format(%9.0f)) legend(off) ytitle( Number of Death case) title(Death case & Age range (Myanmar), size(small)) name(death,replace) 


&&&&&
graph hbar (count),  over(sex, label(labsize(small)))bar(1,color(blue))  bar(2,color(bluishgray ))  blabel(total) legend(off) ytitle("Number of Death case case") title(Number of death case & Age range, size(small)) name(sxe,replace)


graph hbar diabetics hypertension kidneydisease SLE hepatitis stroke asthma heartdisease septicaemia cancer TB, over(agerange)


