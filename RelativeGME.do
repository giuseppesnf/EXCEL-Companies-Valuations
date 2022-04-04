*Nella relative valuation, l'obiettivo è valutare gli asset (di Gamestop) comparandoli con quelli simili sono attualmente prezzati sul mercato.

*Usando i multipli di mercato, si può individuare il sentiment del mercato valutando se il titolo è sottovalutato o sopravvalutato rispetto al nostro gruppo di comparazione.

*L'idea è di trovare aziende comparabili nello stesso settore per formare un campione da utilizzare nella regressione. 

*Idealmente, con un numero sufficiente di imprese tra cui scegliere, le imprese dovrebbero essere raccolte in modo casuale per evitare problemi di BIAS nel sample.

*Ho usato il sample di imprese sfruttato da Damodaran (suddivise per settore di operatività) e ho rimosso per convenzione quelle dove mancavano dati o previsioni di crescità.

*L'obiettivo è trovare quel valore che l'impresa dovrebbe avere in relazione col mercato, in modo tale da determinare una strategia d'investimento BUY or SELL.




****RELATIVE VALUATION****

*media e mediana del sample
sum Pricetosalesttm, d

*media =1.32 | mediana = .735

*E' preferibile la mediana invece della media perché alcuni valori risultano anomali (quindi la mediana è più appropriata).


*PriceToSales di Gamestop = 2.22 (sopra media e mediana)

*se usassimo 0,735 come benchmark di settore, allora potremmo calcolare il prezzo comparato come:

*----> 0,735 * 5.089.800.000 (Net Sales, prese dal Report Annuale 2020) = 3.741.003.000 / 70.770.000 (azioni in circolazione) = 52.861 $ (sopravvalutato rispetto al benchmark)


*****MODELLO DI REGRESSIONE*******

*Price/Sales come variabile dipendente per ottenere il predicted value.


****DATA --> Campione di 52 aziende: nella scelta delle proxy da adottare, come beneficio economico ho preso il NET INCOME, come tasso di crescita attesa la variabile expected growth a 5 anni e per la componente di rischio il BETA MENSILE A 5 ANNI, 

*Come altre variabili "alternative" ho considerato anche il ROE (alternativo al NET INCOME e buono anche come indicatore di crescita attesa) e per la componente rischio ho considerato la variazione % del prezzo delle azioni delle società nelle ultime 52 settimane (weekchange). 


*Correlazione tra le variabili indipendenti //correlation analysis
pwcorr Pricetosalesttm Netincome ROEttm ExpGrowth5y Beta5ymonthly weekchange, sig

*le variabili non mostrano correlazioni anomali tra loro, quindi sono utilizzabili ai fini del modello di regressione.

***********
*prove di regressione (prova con NetIncome)

reg Pricetosalesttm Netincome ExpGrowth5y Beta5ymonthly

*Beta significativo  (good anche il segno "meno" perché variabile di rischio)
*Growth e Net Income NON SIGNIFICATIVI

*provo a creare logaritmo del pricetosalesttm
gen ln_pricetosalesttm = ln(Pricetosalesttm)


*provo areg x assorbire  gli effetti fissi degli stati
areg ln_pricetosalesttm Netincome ExpGrowth5y Beta5ymonthly, a(id_state) robust

*growth e beta significativi
*net income NON SIGN
*cons NON SIGNIFICATIVA <---- è un problema

*Provo ad usare il ROEttm invece del net income
reg Pricetosalesttm ROEttm ExpGrowth5y Beta5ymonthly 

*solo beta significativo

*provo Dummy, settando 1 se il Net Income è maggiore o uguale al 50° percentile (205.500), in caso contrario = 0.

*PS: Il valore mediano dei net income è piuttosto basso dovuto alle difficoltà affrontate nel corso del 2020 nel settore delle vendite retail.

gen dummy_Netincome = 0
replace dummy_Netincome = 1 if Netincome >= 205500 & Netincome != .

*creo in alternativa anche una dummy per il ROE 
gen dummy_ROE = 0
replace dummy_ROE = 1 if ROEttm >= 0 & ROEttm != .


reg Pricetosalesttm dummy_ROE Beta5ymonthly, robust
**SIGNIFICATIVA

reg Pricetosalesttm dummy_Netincome Beta5ymonthly, robust
**SIGNIFICATIVA (sfrutto questa)

******************************* Predicted Value **********************

//Uso solamente il dummy net income come variabile positiva, e il beta5ymonthly come componente rappresentativa del rischio

*Price/SalesTTM = a + B1 * DummyNetIncome + B2 * beta5ymonthly + epslon

reg Pricetosalesttm dummy_Netincome Beta5ymonthly, robust

predict predicted_pricetosales
predict residual, res


*Il fitted value del Price/Sales di Gamestop è 2.459458, contro un valore osservabile di 2.37 (fonte: Yahoo Finance, forse però è aumentato a 2.90).

*2,459458 * 5.089.800.000 = 12.518.149.330 / 70.770.000 = 176,88 $

*Significa che per il mercato il valore "corretto" del titolo GME dovrebbe essere 176,88.

*17 Giugno il titolo è quotato 223,59 ---> QUINDI E' CONSIGLIATO VENDERE (SELL)




















*DOUBT*

*Perché non si fa 2,22 (Price/Sales di GME del sample) ---> 2,22 x 5.089.800.000 / 70.700.000 = 159,66 $

*Cosa succede se uso il valore osservabile di Yahoo Finance (2,37 o 2,90 che sia)?



