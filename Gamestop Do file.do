

// descriviamo le variabili per un primo check
sum Pricetosalesttm Netincome ROEttm ExpGrowth5y Beta5ymonthly weekchange, d


*******************Correlazione tra le variabili indipendenti**********

//correlation analysis
pwcorr Pricetosalesttm Netincome ROEttm ExpGrowth5y Beta5ymonthly weekchange, sig

**Vi è qualche correlazione, ma niente che suggerisca che qualcosa non va



***************************** Regressione ******************************


**Proviamo senza apportare nessun cambiamento alle variabili

reg Pricetosalesttm Netincome ExpGrowth5y Beta5ymonthly

//Il Beta viene significativo, ma Net Income e Growth no


**winsorizziamo


winsor Netincome , g (win_Netinc) p(0.05)
winsor ExpGrowth5y , g (win_Growth) p(0.05)
winsor ROEttm, g (win_ROE) p (0.05)
winsor Beta5ymonthly, g (win_Beta) p (0.05)

//Proviamo anche a usare il logaritmo di Net_Income

gen ln_net= ln(Netincome)
gen ln_pricetosales = ln(Pricetosalesttm)


areg ln_pricetosales win_Netinc win_Growth Beta5ymonthly, a(id_state) robust
**Assorbo per gli effetti fissi degli stati, ora viene significativo sia growth che beta, ma non lo è la costante. Non cambia nulla anche se uso price to sales invece del logaritmo di price to sales. Scartiamo questa idea. 



reg Pricetosalesttm ln_net win_Growth Beta5y, robust 
**Non viene nulla di significativo


**Proviamo a usare il ROE al posto del Net Income

reg Pricetosales win_ROE win_Growth Beta5y, robust 
**non è cambiato nulla, solo il Beta è significativo


************* Creiamo le Dummy ****************

gen dummy_Netin = 0
replace dummy_Netin = 1 if Netincome >= 205500 & Netincome != .

gen dummy_beta = 0
replace dummy_beta = 1 if Beta5ymonthly >= 1.67 & Beta5ymonthly != .
gen dummy_ROE = 0
replace dummy_ROE = 1 if ROEttm >= 0 & ROEttm != .
gen dummy_growth = 0
replace dummy_growth = 1 if ExpGrowth5y >= 0 & ExpGrowth5y != .

*****Provo le Regressioni con le Dummy



reg Pricetosalesttm win_ROE win_Growth Beta5ymonthly, robust
**non significativa

reg Pricetosalesttm dummy_ROE Beta5ymonthly, robust
**Questa invece viene significativa

reg Pricetosalesttm dummy_Netin Beta5ymonthly, robust
**Viene significativa anche questa

***Queste due ultime regressione vengono entrambe significative, sembrano abbastanza intercambiabili perché i coefficienti sono quasi gli stessi. Useremo la seconda regressione




******************************* Predicted Value **********************

//Usiamo solamente il dummy net income come variabile positiva, e il beta come variabile per il rischio


reg Pricetosalesttm dummy_Netin  Beta5ymonthly, robust
predict predicted_PS
predict residual, res


//il valore fitted per il Price/Sales di Gamestop è 2.459458 contro il valore osservato (yahoo finance) di 2.37. Moltiplichiamo il fitted value per il valore Sales, e otteniamo 2.459458*5.089.800.000 = 12.518.149.330. Dividiamo poi 12.518.149.330 per il numero di azioni in circolazione(70.77 Milioni) e otteniamo un prezzo fitted, secondo il nostro modello, di 176.88. Il prezzo alla data in cui abbiamo effettuato la valutazione è di 180.6 quindi secondo la relative valuation Gamestop è sopravvalutata.  



