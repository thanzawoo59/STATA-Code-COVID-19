***STATA-Code-COVID-19

***Author :THAN ZAW OO
***Date  :21-9-2020
*******************************************************************************
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

***********************************************************************************************************************************************************************************************************************************************************************************************************************************************************
***https://ourworldindata.org/mortality-risk-covid
**************************************************************************
**Importin CSV file from web page

import delimited "https://covid.ourworldindata.org/data/owid-covid-data.csv", clear

keep date population_density hospital_beds_per_thousand iso_code  location total_cases new_cases total_deaths new_deaths population median_age aged_65_older aged_70_older extreme_poverty cardiovasc_death_rate diabetes_prevalence female_smokers male_smokers handwashing_facilities hospital_beds_per_thousand life_expectancy human_development_index total_tests

****Renaming var
rename total_tests t_test
lab var t_test "Total test"

rename population_density pden
lab var pden "Population density"

rename hospital_beds_per_thousand hb
lab var hb "hospital beds per thousand"

rename iso_code code
lab var code "Country code"

rename location count
lab var count "Country"

rename total_cases tc
lab var tc "Totao positive cases"

rename new_cases nc
lab var nc "New cases"

rename total_deaths td
lab var td "Total death cases"

rename new_deaths nd
lab var nd "New death cases"

rename population pop
lab var pop "Poulation of the country"

rename  median_age mage
lab var mage "Median age"

rename aged_65_older a65
lab var a65 "Age 65 and older"

rename aged_70_older a70
lab var a70 "Age 70 and older"

rename extreme_poverty expover
lab var expover "Extreme poverty rate"

rename cardiovasc_death_rate cvd
lab var cvd "cardiovasc death rate"

rename diabetes_prevalence dia
lab var dia "diabetes prevalence"

rename female_smokers fsmo
lab var fsmo "Female smoker"

rename male_smokers msmo
lab var msmo "Male smoker"

rename handwashing_facilities hwas
lab var hwas "Handwashing facilities"

rename life_expectancy lexp
lab var lexp "life expectancy"

rename human_development_index hdi
lab var hdi "human development index"

drop if count=="International"
replace tc=0 if mi(tc)

********************************************************************************
***Replace pop desity for missing 

replace pden =167 if count=="Anguilla"
**https://www.paho.org/salud-en-las-americas-2017/?page_id=1694
replace pden =123 if count=="Bonaire Sint Eustatius and Saba"
**https://www.worldometers.info/world-population/falkland-islands-malvinas-population/#:~:text=the%20Falkland%20Islands%20ranks%20number,1%20people%20per%20mi2).
replace pden =0 if count=="Falkland Islands"
**https://www.worldometers.info/world-population/channel-islands-population/
replace pden =915 if count=="Guernsey"
*https://www.google.com/search?q=population+density+of+Jersey+km2&oq=population+density+of+Jersey+km2&aqs=chrome.0.69i59.5598j0j7&sourceid=chrome&ie=UTF-8
replace pden =912 if count=="Jersey"
**https://www.worldometers.info/world-population/montserrat-population/#:~:text=The%20population%20density%20in%20Montserrat,129%20people%20per%20mi2).
replace pden =50 if count=="Montserrat"
*https://www.worldometers.info/world-population/south-sudan-population/#:~:text=The%20population%20density%20in%20South,47%20people%20per%20mi2).&text=The%20median%20age%20in%20South%20Sudan%20is%2019.0%20years.
replace pden =18 if count=="South Sudan"
**https://www.worldometers.info/world-population/syria-population/#:~:text=The%20population%20density%20in%20Syria,247%20people%20per%20mi2).
replace pden =95 if count=="Syria"

*https://worldpopulationreview.com/countries/taiwan-population
replace pden =694 if count=="Taiwan"
*https://www.internetworldstats.com/euro/va.htm
replace pden =767 if count=="Vatican"
*https://www.worldometers.info/demographics/western-sahara-demographics/#:~:text=The%202019%20population%20density%20in,miles).
replace pden =2 if count=="Western Sahara"
*********************************************************************************
gen SEA=0
replace SEA=1 if count=="Brunei" | count=="Cambodia" | count=="Indonesia" | ///
count=="Laos" | count=="Malaysia" | count=="Myanmar" | ///
count=="Philippines" | count=="Singapore" | count=="Thailand" | ///
count=="Timor" | count=="Vietnam"

***Formating string date into date format
split date, p("-")
drop date
egen date=concat(date1 date2 date3)
gen datevar = date(date,"YMD")
format datevar %td
drop date1 date2 date3

tempfile rdata
save `rdata'

***Updated case 
foreach var of varlist tc nc td nd t_test {
bysort  count: egen max_`var'=max(`var')
replace `var'=max_`var'
drop max_`var'
}

bysort count: gen sr=_n
drop if sr>1
drop sr


***Regression model for estimation
***Hospital bed and death rate
preserve
keep if !mi(hb)
keep if !mi(hdi) 
keep if !mi(lexp)
keep if !mi(cvd) 
keep if !mi(dia)
keep if !mi(expover)
pwcorr tc pden hb hdi lexp cvd dia expover

regress  tc  pden hb  lexp cvd dia expover pop a65 a70 
estimates store totdeath
coefplot , drop(_cons) xline(0)  ci(95) ytitle(Effect)   name(positive, replace ) title("Positve case ratio") msymbol(S) graphregion(color(white))
restore

**Total death and its effects
preserve
keep if !mi(hb)
keep if !mi(hdi) 
keep if !mi(lexp)
keep if !mi(cvd) 
keep if !mi(dia)
keep if !mi(expover)
pwcorr td pden hb hdi lexp cvd dia expover hdi

regress  td  pden hb  lexp cvd dia expover pop a65 a70 
estimates store totdeath
coefplot , drop(_cons) xline(0)  ci(95) ytitle(Effect)   name(Death, replace ) title("Death case ratio") msymbol(S) graphregion(color(white))
restore

**total death & HDI
preserve
keep if !mi(hdi)
pwcorr td hdi

regress  td hdi
estimates store tdhdi
coefplot , drop(_cons) xline(0)  ci(95) ytitle(Effect)   name(HDI_tdeath, replace ) title("Death case ratio") msymbol(S) graphregion(color(white))
restore

**HDI & p_case
preserve
keep if !mi(hdi)
regress  tc  hdi
estimates store phdi
coefplot , drop(_cons) xline(0)  ci(95) ytitle(Effect)   name(HDI_pcase, replace ) title("Positve case ratio") msymbol(S) graphregion(color(white))

coefplot tdhdi phdi, drop(_cons) xline(0)  ci(95) ytitle(Effect)   name(HDI_p_d, replace ) title("Positve case ratio") msymbol(S) graphregion(color(white))
restore

***test_
preserve
keep if !mi(t_test)
gen log_t =log(t_test)
regress  log_t tc
estimates store phdi
coefplot , drop(_cons) xline(0)  ci(95) ytitle(Effect)   name(test_tc, replace ) title("Positve case ratio") msymbol(S) graphregion(color(white))

coefplot tdhdi phdi, drop(_cons) xline(0)  ci(95) ytitle(Effect)   name(HDI_p_d, replace ) title("Positve case ratio") msymbol(S) graphregion(color(white))
restore

clear

*********************************************************************************
***Comparising for Myanmar and neighbouring countries of myanmar
use `rdata'
keep datevar count code nc nd tc t_test
drop if mi(code)
split count, p(" ")
egen country=concat(count1 count2 count3 count4 count5)
drop count1-count5
rename tc t_
rename nd d_
rename nc n_
rename t_test tt_
drop code
replace count=country
replace count="BonaireSint"   if count=="BonaireSintEustatiusandSaba"
replace count="CotedIvoire"   if count=="Coted'Ivoire"
replace count="Guinea_Bissau"   if count=="Guinea-Bissau"
replace count="SintMaarten"   if count=="SintMaarten(Dutchpart)"
drop country

***Reshaping data for country level
reshape wide t_ d_ n_ tt_, i(datevar ) j(count)string

foreach var of varlist t_* d_* n_* tt_*{
	replace `var'=0 if mi(`var')
}

preserve 
keep datevar t_* 
egen tot_pop=rowtotal(t_Afghanistan- t_Zimbabwe)
gen log_positive=log(tot_pop)
drop tot_pop
gen mmr=0
reg log_positive t_Myanmar t_Singapore t_Laos t_Thailand
estimates store pop
coefplot , drop(_cons) xline(0)  ci(95) ytitle(Effect)   name(pop, replace ) title("Positve case ratio") msymbol(S) graphregion(color(white))

twoway (line log_positive datevar) 
restore

preserve 
keep datevar d_* 
egen tot_death=rowtotal(d_Afghanistan- d_Zimbabwe)
gen log_d=log(tot_death)

gen mmr=0
reg log_d d_Myanmar d_Singapore d_Laos d_Thailand
estimates store death
coefplot , drop(_cons) xline(0)  ci(95) ytitle(Effect)   name(death, replace ) title("Positve case ratio") msymbol(S) graphregion(color(white))

twoway (line log_d datevar) 
restore

**Myanmar postive and death cases
twoway (line t_Myanmar datevar) (line d_Myanmar datevar)

**Positive cases
lab var t_Myanmar "Myanmar"
lab var t_Thailand "Thailand"
lab var t_Laos "Laos"
lab var t_Singapore "Singapore"  
twoway (line t_Myanmar datevar) (line t_Thailand datevar) ///
(line t_Laos datevar) (line t_Singapore datevar) , title (Positive case changing over time) name(positve,replace) ytitle(Number of positive cases)

restore
**New cases
lab var n_Myanmar "Myanmar"
lab var n_Thailand "Thailand"
lab var n_Laos "Laos"
lab var n_Singapore "Singapore" 

    
twoway (line n_Myanmar datevar) (line n_Thailand datevar) ///
(line n_Laos datevar) (line n_Singapore datevar), title (New case changing over time) name(newcas,replace) ytitle(Number of new positive cases)

**Death cases

lab var d_Myanmar "Myanmar
lab var d_Thailand "Thailand"
lab var d_Laos "Laos"
lab var d_Singapore "Singapore"  
twoway (line d_Myanmar datevar) (line d_Thailand datevar) ///
(line d_Laos datevar) (line d_Singapore datevar) , title (Death case changing over time) name(death,replace) ytitle(number of death cases)
 
**Combing graph
graph combine newcas death, xsize(8) name(p_d,replace)
