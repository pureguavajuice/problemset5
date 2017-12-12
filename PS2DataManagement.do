clear
version 14
set matsize 300

//Set CFETdir to your directory of choice, set WebURL to the root page
//containing files you'd like to download
//global NIFTIdir "\ldb92\Desktop\StataFiles_NIFTI"
global WebURL "https://sites.google.com/site/bivonastatadatasets/data-management/"
global CFETdir "\\acquisitions.rutgers.edu\redirection$\ldb92\Desktop"

sysdir set PLUS $CFETdir

//install renvars and missings
net from http://www.stata-journal.com/software/sj5-4 //renvars is dm88_1
net from http://www.stata-journal.com/software/sj17-3 //renvars is dm0085_1

///////////////////////////////////////////////////////////
/*-------- Step 1: Formatting Data for Merges ---------- */
///////////////////////////////////////////////////////////

//File number 1: Basic Survey Pre-test

import excel ${WebURL}CFET%20Basic%20Survey%202017%20-%20Pre.xlsx, first clear

drop if length(Name)<1

renvars Name-Nutrition \ name cook garden plantid vegid talkcust money dealissues pubspeak ///
newpeople oppress racism stereo fact foodsys indag farm urbfarm organic chemfree ///
enviro jobaccess desert foodaccess foodjust envirojust socialjust camdenhist privilege carbon conflict ///
istate nutrition

missings dropvars, force

preserve
collapse (mean) cook-nutrition
save COLLAPSEDBasic2017_PRE.dta, replace
restore

sort name

gen id= _n
order id, first

renvars name-nutrition, pref(PRE)

save BasicSurv2017_PRE.dta, replace

//---------------------------------------------------------------------------
//File number 2: Basic Survey Post-test

import excel ${WebURL}CFET%20Basic%20Survey%202017%20-%20Post.xlsx, first clear

missings dropvars, force
missings dropobs, force

renvars Name-Nutrition \  name cook garden plantid vegid talkcust money dealissues pubspeak ///
newpeople oppress racism stereo fact foodsys indag farm urbfarm organic chemfree ///
enviro jobaccess desert foodaccess foodjust envirojust socialjust camdenhist privilege carbon conflict ///
istate nutrition

preserve
collapse (mean) cook-nutrition
save COLLAPSEDBasic2017_POST.dta, replace
restore

renvars name-nutrition, pref(POST)
sort POSTname
gen id = _n
order id, first

save BasicSurv2017_POST.dta, replace

//-----------------------------------------------------------------------------
//File number 3: Food Corps Survey Pre-test

import excel ${WebURL}CFET%20Food%20Corps%20Survey%202017%20-%20Pre.xlsx, first clear
missings dropvars, force
missings dropobs, force

renvars Name-CollardGreens \ name lett carrot zucch spinach radish ///
cauli peas bellpep tom grbean kale beet bok swpot broc ///
cuke chard collard

renvars name-collard, pref(PRE)

sort PREname
gen id = _n
order id, first

destring PREtom-PREcollar, replace ignore("?")

save FoodCorpsSurv2017_PRE.dta, replace


//-----------------------------------------------------------------------------
//File number 4: Food Corps Survey Post-test

import excel ${WebURL}CFET%20Food%20Corps%20Survey%202017%20-%20Post.xlsx,first clear 
missings dropvars, force
missings dropobs, force

renvars Name-CollardGreens \ name lett carrot zucch spinach radish ///
cauli peas bellpep tom grbean kale beet bok swpot broc ///
cuke chard collard

renvars name-collard, pref(POST)

sort POSTname
gen id = _n
order id, first

destring POSTlett-POSTcollard, replace

save FoodCorpsSurv2017_POST.dta, replace

//-----------------------------------------------------------------------------
//File number 5: Food Bank Survey Pre-test
import excel ${WebURL}Food%20Bank%20Survey%202017%20-%20Pre.xlsx,first clear
missings dropvars, force

renvars Name- Iknowhowtouseaunitpricet \ name myplate foodgroup grain ///
nutlabel recipe extrafood unitprice

renvars name-unitprice, pref(PRE)

sort PREname
gen id = _n
order id, first

save FoodBankSurv2017_PRE.dta, replace

//-----------------------------------------------------------------------------
//File number 6: Food Bank Survey Post-test

import excel ${WebURL}Food%20Bank%20Survey%202017%20-%20Post.xlsx,first clear
missings dropvars, force
missings dropobs, force

renvars Name- Iknowhowtouseaunitpricet \ name myplate foodgroup grain ///
nutlabel recipe extrafood unitprice

renvars name-unitprice, pref(POST)

sort POSTname
gen id = _n
order id, first

save FoodBankSurv2017_POST.dta, replace



///////////////////////////////////////////////////////////
/*----------------- Step 2: Merges and Appends --------------------- */
///////////////////////////////////////////////////////////

/* The individual data files should now be ready to merge. Because the data sets
are quite small (we only have 12 youth interns) managing the merges should be
relatively easy*/


// Appending pre and post tests of basic survey
use COLLAPSEDBasic2017_PRE, clear
append using COLLAPSEDBasic2017_POST



///////////////////////////////////////////////////////////////////////////////
//Performing the simple 1:1 merges

use BasicSurv2017_PRE, clear
merge 1:1 id using BasicSurv2017_POST.dta
save MergedBasicSurvey2017.dta, replace


loc scores cook garden plantid vegid talkcust money dealissues pubspeak ///
newpeople oppress racism stereo fact foodsys indag farm urbfarm organic chemfree ///
enviro jobaccess desert foodaccess foodjust envirojust socialjust camdenhist privilege carbon conflict ///
istate nutrition

foreach x in `scores'{
	egen DIFF`x' = diff(PRE`x' POST`x')
}

use FoodCorpsSurv2017_PRE, clear
merge 1:1 id using FoodCorpsSurv2017_POST.dta
save MergedFoodCorpsSurvey2017.dta, replace

loc foodcorps name lett carrot zucch spinach radish cauli peas bellpep tom grbean kale beet /// 
bok swpot broc cuke chard collard

foreach y in `foodcorps'{
	egen DIFF`y' = diff(PRE`y' POST`y')
}
