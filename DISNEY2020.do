*SUMMARY STATISTICS
sum pe_ratio_ttm payout_n exp_growth_rate roe beta  st_dev_eps , d

***CORRELATION ANALYSIS 
pwcorr pe_ratio_ttm payout_n exp_growth_rate roe beta  st_dev_eps, sig 
// on a univariate basis pe is positively correlated with STD.DEV EPS and exp growth (good!) but not correlated to BETA, PAYOUT AND ROE(not good)
// growth and payout are NOT correlated each other ( good)
// risk measures are not correlated each other (not good)


**OLS REGRESSION fase1 
reg pe_ratio_ttm payout_n // significant under 95% (NOT good)
reg pe_ratio_ttm exp_growth_rate // significant at 99% (good)
reg pe_ratio_ttm roe // significant at 1% (not good)
reg pe_ratio_ttm beta //  significant BETWEEN 90% AND 95%
reg pe_ratio_ttm st_dev_eps //  significant 99%
gen risk=1 if beta>= 1.5 & beta!=.
replace risk = 0 if beta < 1.5
reg pe_ratio_ttm risk // significant at 95%. P/E IS NEGATIVELY CORRELATED WITH RISK, WE COULD ACCEPT THIS VARIABLE.
// but maybe it works with other variables

**OLS REGRESSION fase2 
**** reg pe_ratio cf g risk
reg pe_ratio_ttm payout_n exp_growth_rate risk
**let's use roe to proxy for economic benefits
reg pe_ratio_ttm roe exp_growth_rate risk

**let's winsorize  
winsor pe_ratio_ttm , g (wpe) p(0.05)
winsor payout_n , g (wpayout) p(0.05)
winsor roe , g (wroe) p(0.05)
winsor exp_growth_rate , g (wgrowth) p(0.05)
winsor beta , g (wbeta) p(0.05)
winsor st_dev_eps , g (wstdev) p(0.05)

reg wpe wpayout wgrowth wbeta // LOW R/SQUARED, PAYOUT NOT SIGNIFICANT
reg wpe wpayout wgrowth wstdev // R/SQUARED AT 42%, PAYOUT NOT SIGNIFICANT
reg wpe wpayout wgrowth risk //R/SQUARED AT 39%, PAYOUT NOT SIGNIFICANT(AGAIN) risk NEGATIVE XD**
//SINCE PAYOUT IS NOT SIGNIFICANT I DO NOT USE IT WHILE I PREFER TO USE IN MY MODEL BOTH STDEV AND RISK.
reg wpe wgrowth risk wstdev
//I OBSERVE THAT RISK IS NEGATIVELY RELATED TO P/E (C.I.<95%) AND ST DEV IS POSITIVELY RELATED TO P/E(C.I.>95%)

// are beta correlated with growth? or payout? or profitability???
reg wbeta wgrowth //no
reg wbeta wpayout //no
reg wbeta wroe //no
// so wtf??

sum wbeta,d // the bulk of beta values are lower than 1.... sample bias?? maybe!
// BUT I DON'T LIKE P-VALUE OF RISK IN MULTIVARIATE REGRESSION....
// let's use stdev ...

sum wstdev,d
gen risk2 = 1 if wstdev >= r(p50) & wstdev!=. // note that you can use this command only after running sum....
replace risk2 = 0 if wstdev < r(p50)
// I MUST ADJUST PAYOUT BY CREATING A DUMMY VARIABLE 
sum wpayout,d
gen cashflows=1 if wpayout >= r(p75) & wpayout!=.
replace cashflows=0 if wpayout < r(p75)
//in this way cashflows is less significant but growth and risk are more significant than in the other models

reg wpe cashflows wgrowth risk2 //RISK 2 MORE SIGNIFICANT BUT WRONG SIGN

sum wstdev,d
gen risk3 = 1 if wstdev >= r(p75) & wstdev!=. // note that you can use this command only after running sum....
replace risk3 = 0 if wstdev < r(p75)

reg wpe cashflows wgrowth risk3 //CASHFLOW COMPLETELY NOT SIGNIFICANT, RISK3 LESS SIGNFICANT

// try to use roe as a proxy for risk (inverse) BUT if you have D/E ratio use it!

sum wroe,d
gen risk4 = 1 if wroe <= r(p25)  // note that you can use this command only after running sum....
replace risk4 = 0 if wroe > r(p25) & wroe!=.

reg wpe wgrowth wbeta //risk4 not sign...WE ARRIVED HERE we are not using cashflows variable and we are using wbeta as risk variable instead of risk4.///


//creating predicted pe...
predict predicted_pe ,xb // note that you can use this command only after running reg...
predict residual, res // note that you can use this command only after running reg
sum predicted_pe, d



///NOW YOU FIND THE PREDICTED ("TRUE") VALUE OF PE RATIO. IN ORDER TO FIND THE VALUE OF YOUR COMPANY YOU JUST NEED TO MULTIPLY THE PREDICTED PE RATIO * EPS (TTM in this case).
* in this case (Disney, May 2020) :
Disney stock price= 115.32$
PE ratio (TTM) = 39.39
median PE ratio ttm from the sample = 19.66
median PE ratio ttm from Damodaran=  47.68 (05 2020)
predicted PE ratio ttm Disney(from ols reg) = 16.96
EPS (ttm) Disney in May 2020 = 2.97 $

*1)comparison against the industry
PE ratio (TTM) = 39.39
median PE ratio ttm from Damodaran=  47.68 (05 2020)
disney is undervalued. current price is 115.32$ but the "value" is (47.68*2.97) = 141.61$ --> BUY!!!
*2)ols
PE ratio (TTM) = 39.39
predicted PE ratio ttm Disney(from ols reg) = 16.96
disney is higly overvalued. current price is 115.32$ but the "value" is (16.96*2.97)= 50.37.$ --> sell!
