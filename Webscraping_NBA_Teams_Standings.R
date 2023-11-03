# Load the rvest library
library('rvest')

setwd("C:/Users/joaov/Documents/TwitterBot/")
 
# Define the URL of the websites to be scraped
url <- 'https://www.basketball-reference.com/leagues/NBA_2024_standings.html'
  
# Read the HTML from the specified URL
site <- read_html(url)
  
# Find the table elements in the HTML
# Convert them into data frames, and store them in the 'tables' variable
tables <- site %>%
  html_nodes('table') %>%
  html_table(fill = TRUE)

eastern_conf = tables[[1]]
western_conf = tables[[2]]

#View(tables[[2]])
#View(tables[[1]])

# Turns the combined table into a CSV file
write.csv(eastern_conf, "NBA_Eastern_Conference_Standings.csv", row.names = FALSE)

# Turns the combined table into a CSV file
write.csv(western_conf, "NBA_Western_Conference_Standings.csv", row.names = FALSE)