# Loads the rvest, stringr and dplyr libraries
library(rvest)
library(stringr)
library(dplyr)
  
# Defines the Unicorn Auctions URL (past auctions)
url <- paste0("https://bid.unicornauctions.com/auctions/past?view=grid&page=1&limit=200")

# Scrapes past auctions data
past_auctions <- 
  read_html(url) %>%
  html_element(xpath = "//script[contains(text(),'viewVars =')]") %>%
  html_text() %>%
  # Cleans up the JavaScript to make it parsable as JSON
  str_remove("^\\s+viewVars =") %>%
  str_remove(";\\s+$") %>%
  # Turns into a JSON list
  jsonlite::fromJSON() %>%
  # Extracts the "result_page" from the "auctions" list
  purrr::pluck("auctions", "result_page") %>%
  # Converts the result to a tibble
  as_tibble()

past_auctions <- past_auctions %>%
  
  # Normalizes the start and end time data (some was considered at 00:00 am, so it was one day ahead of the correct one)
  mutate(start_date_normalized = as.POSIXct(time_start, format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC") - 21600,
         end_date_normalized = as.POSIXct(effective_end_time, format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC") - 21600) %>%
  
  mutate(auction_start = as.Date(start_date_normalized),
         auction_end = as.Date(end_date_normalized),
         link = paste0("https://bid.unicornauctions.com", `_detail_url`)) %>%
  
  rename(name = title,
         auction_id = row_id) %>%
  
  select(auction_id, name, link, auction_start, auction_end)
  
# Views the final tibble
View(past_auctions)

# Export a RDS file
saveRDS(past_auctions, file = 'Unicorn Auctions Step 1.rds')
