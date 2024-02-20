library(text)
install.packages("tidyverse")
library(tm)
library(tidytext)
library(dplyr)
library(ggplot2)
library(tidyr)
library(readr)
library(tokenizers)
install.packages("wordcloud")
install.packages("RColorBrewer")
library(wordcloud)
library(RColorBrewer)
# Read the data
data <- read.csv("MN-DS-news-classification.csv", header = TRUE)

# Check for missing values
missing_values <- any(is.na(data))
if (missing_values) {
  print("There are missing values in the data. Please handle them appropriately.")
} else {
  print("No missing values found in the data.")
}

# Create a Corpus
corpus <- VCorpus(VectorSource(data$title))

# Preprocess the text
corpus <- tm_map(corpus, content_transformer(tolower))
corpus <- tm_map(corpus, removePunctuation)
corpus <- tm_map(corpus, removeNumbers)
corpus <- tm_map(corpus, content_transformer(unnest_tokens))
custom_stop_words <- c("day", "new", "news","can","will") 
corpus <- tm_map(corpus, removeWords,c(stopwords("english"), custom_stop_words))
corpus <- tm_map(corpus, stemDocument)


# Create a Document-Term Matrix (DTM)
dtm <- DocumentTermMatrix(corpus)
dim(dtm)

#most common approach is to remove sparse terms after creating the Document-Term Matrix (DTM) but before applying TF-IDF.
sparse_threshold <- 0.99
dtm_sparse_removed <- removeSparseTerms(dtm, sparse = sparse_threshold)
dim(dtm_sparse_removed) #10917    104

newsdtm_tfidf <- weightTfIdf(dtm_sparse_removed)
tidy_data <- tidy(newsdtm_tfidf)
print(tidy_data)

aggregated_tfidf <- tidy_data %>%
  group_by(term) %>%
  summarise(total_tfidf = sum(count),
            mean_tfidf = mean(count),
            max_tfidf = max(count)) %>%
  arrange(desc(total_tfidf))

View(aggregated_tfidf)

top_terms <- head(aggregated_tfidf, 30)
ggplot(top_terms, aes(x = reorder(term, total_tfidf), y = total_tfidf)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  coord_flip() +
  labs(title = "Top 20 Terms by Total TF-IDF Score",
       x = "Term", 
       y = "Total TF-IDF Score") +
  theme_minimal()

#wordcloud
set.seed(123) 
words <- aggregated_tfidf$term
scores <- aggregated_tfidf$total_tfidf

 
wordcloud(words = words, freq = scores, min.freq = 1,
          max.words = 60, random.order = FALSE,scale = c(2, 0.5),  
          colors = brewer.pal(8, "Dark2"))
#plots the words in order of decreasing frequency (or score)
#scale to alter the words