# Load the rvest library
library('rvest')

setwd("C:/Users/joaov/Documents/TwitterBot/")

# List of teams abbreviations
teams <- c('ATL','BOS','BRK','NYK','PHI','TOR','CLE','MIL','IND','CHI',
           'MIA','ORL','CHO','WAS','DEN','OKC','MIN','POR','UTA','LAC',
           'PHO','LAL','GSW','NOP','DAL','HOU','SAS','MEM','DET','SAC')

# Create an empty list to store the tables
all_tables_per_game <- list()
all_tables_totals <- list()

# Loop over teams abbreviations
for(team in teams){
  
  # Define the URL of the websites to be scraped
  url <- paste0('https://www.basketball-reference.com/teams/', team, '/2024.html')
  
  # Read the HTML from the specified URL
  site <- read_html(url)
  
  # Find the table elements in the HTML
  # Convert them into data frames, and store them in the 'tables' variable
  tables <- site %>%
    html_nodes('table') %>%
    html_table(fill = TRUE)
  
  # Add a Team column to the table with the team name
  tables[[2]]$Team <- team
  
  # Add the table to the list of all tables
  all_tables_per_game[[team]] <- tables[[2]]
  all_tables_totals[[team]] <- tables[[3]]
}

# Combine all the tables into a single table
combined_table_per_game <- do.call(rbind, all_tables_per_game)
#View(combined_table_per_game)

# Combine all the tables into a single table
combined_table_totals <- do.call(rbind, all_tables_totals)
#View(combined_table_totals)

# Turns the combined table into a CSV file
write.csv(combined_table_per_game, "NBA_Players_Data_Per_Game.csv", row.names = FALSE)

# Turns the combined table into a CSV file
write.csv(combined_table_totals, "NBA_Players_Data_Totals.csv", row.names = FALSE)
