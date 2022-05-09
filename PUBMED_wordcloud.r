require(easyPubMed)
require(PubMedWordcloud)
require(tidyverse)
require(wordcloud)
require(tokenizers)
new_query <- "(distal radius fracture[Title]) AND ((2011/7/2:2021/7/2[pdat]))"

n <- 50

xml_file <- batch_pubmed_download(
    pubmed_query_string = new_query,
    format = "xml",
    batch_size = 5000
)

search <- data.frame(table_articles_byAuth(xml_file)) %>%
    distinct(pmid, doi, .keep_all = TRUE) # delete duplicate data

write.csv2(search, "pubmed_raw_data.csv")

custom_stop_words <- c(
    "abstracttext", "patient", "patients", "search",
    "research", "literature", "used", "using", "analysis",
    "showed", "clinical", "studies", "study", "age",
    "outcomes", "performed", "total", "background",
    "procedure", "years", "months", "score", "average",
    "mean", "with", "without", "may", "range", "follow",
    "up", "significantly", "significant", "abstract",
    "however", "can"
)

custom_stop_words <- c(
    custom_stop_words,
    tokenize_words(new_query, simplify = TRUE)
)
abstract <-
    cleanAbstracts(search$abstract, yrWords = custom_stop_words)
keywords <-
    cleanAbstracts(search$keywords, yrWords = custom_stop_words)

pdf("abstract_wordcloud.pdf")
wordcloud(
    words = abstract$word,
    freq = abstract$freq,
    min.freq = 1,
    max.words = n,
    random.order = FALSE,
    rot.per = 0.1,
    colors = c("#ABABAB", "#000000", "#6BB03D", "#0070C0")
)
dev.off()
pdf("keywords_wordcloud.pdf")
wordcloud(
    words = keywords$word,
    freq = keywords$freq,
    min.freq = 1,
    max.words = n,
    random.order = FALSE,
    rot.per = 0.1,
    colors = c("#ABABAB", "#000000", "#6BB03D", "#0070C0")
)
dev.off()
