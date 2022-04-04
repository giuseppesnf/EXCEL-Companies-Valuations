# Libraries
library(RedditExtractoR)
library(radarchart)
library(tm)
library(syuzhet)

# Getting Reddit Data
links <- reddit_urls(search_terms = "CLOV", page_threshold = 20)

# User network plot
content <- reddit_content(links$URL[1])
user <- user_network(content, include_author = T, agg = TRUE)
user$plot

graph <- construct_graph(content, plot = TRUE)

# Sentiment analysis 
com <- iconv(content$comment, to = 'utf-8-mac')
clov <- get_nrc_sentiment(com)

# Radar chart
x1 <- data.frame(Clover=100*colSums(clov)/sum(clov)) 
x2 <- data.frame(AMC=100*colSums(amc)/sum(amc)) 
x3 <- data.frame(GameStop=100*colSums(gme)/sum(gme)) 
z <- cbind(x1, x2, x3)
labs <- rownames(z)
chartJSRadar(z, 
             labs = labs,
             labelSize = 40,
             main = 'AMC Vs CLOV Vs GME: Sentiment Analysis of Reddit Comments')
