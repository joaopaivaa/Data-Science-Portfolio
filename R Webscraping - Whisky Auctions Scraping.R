library(rvest)
library(magrittr)
library(data.table)

# Defina o HTML fornecido
url <- "https://whisky.auction/auctions/live?src=&pageIndex=0&pageSize=90&sort=Price&dir=desc&type=&category=&minPrice=0&maxPrice=1000000&minAge=0&maxAge=100&vintage=&brand=&bottler=&minStrength=0&maxStrength=100&caskNumber=&country=&bottlingDate=&filter=live"

# Analise o HTML
html <- read_html(url)

# Extraia o título do anúncio
titles <- html %>%
  html_nodes(".lotName1") %>%  # Use a classe "lotName1" como seletor
  html_text()

size_abv <- html %>%
  html_nodes(".lotName3") %>%  # Use a classe "lotName1" como seletor
  html_text()

days_left <- html %>%
  html_nodes(".timerItem.days") %>%  # Use a classe "lotName1" como seletor
  html_text()

hours_left <- html %>%
  html_nodes(".timerItem.hours") %>%  # Use a classe "lotName1" como seletor
  html_text()

minutes_left <- html %>%
  html_nodes(".timerItem.minutes") %>%  # Use a classe "lotName1" como seletor
  html_text()

seconds_left <- html %>%
  html_nodes(".timerItem.seconds") %>%  # Use a classe "lotName1" como seletor
  html_text()

winning_bid <- html %>%
  html_nodes(".winningBid.value") %>%  # Use a classe "lotName1" como seletor
  html_text()

lot <- html %>%
  html_nodes(".lot-no") %>%  # Use a classe "lotName1" como seletor
  html_text()

Age = rep('-', length(titles))
Bottler = rep('-', length(titles))
Classification = rep('-', length(titles))
Country = rep('-', length(titles))
Num_Bottles = rep('-', length(titles))
Region = rep('-', length(titles))
Series = rep('-', length(titles))
Cask_Type = rep('-', length(titles))
Cask_Number = rep('-', length(titles))
Bottling_Date = rep('-', length(titles))
Strength = rep('-', length(titles))

for (i in 1:length(titles)) {

  title_lower <- tolower(titles[i])
  title_subs <- gsub(" ", "-", title_lower)
  
  # Defina o HTML fornecido
  url <- paste0('https://whisky.auction/auctions/lot/',substr(lot[i], 5, nchar(lot[i])),'/',gsub(",", "", gsub(":", "", title_subs)))
  url
  # Analise o HTML
  html <- read_html(url)
  
  # Extraia o título do anúncio
  names <- html %>%
    html_nodes(".waForm-label") %>%  # Use a classe "lotName1" como seletor
    html_text()
  
  values <- html %>%
    html_nodes("p") %>%  # Use a classe "lotName1" como seletor
    html_text()

  for (j in 1:length(names)) {
    nome <- names[j]
    valor <- values[j+3]
    
    if (nome == 'Age') {
      Age[i] <- valor
    }

#############################

    if (nome == 'Bottler') {
      Bottler[i] <- valor
    }
    
#############################
    
    if (nome == 'Classification') {
      Classification[i] <- valor
    }
    
#############################
    
    if (nome == 'Country') {
      Country[i] <- valor
    }
    
#############################
    
    if (nome == 'Number of Bottles') {
      Num_Bottles[i] <- valor
    }
    
#############################
    
    if (nome == 'Region') {
      Region[i] <- valor
    }
    
#############################
    
    if (nome == 'Strength') {
      Strength[i] <- valor
    }
    
#############################
    
    if (nome == 'Cask Type') {
      Cask_Type[i] <- valor
    }
    
#############################
    
    if (nome == 'Bottling Date') {
      Bottling_Date[i] <- valor
    }
    
#############################
    
    if (nome == 'Cask Number') {
      Cask_Number[i] <- valor
    }

#############################
    
    if (nome == 'Series') {
      Series[i] <- valor
    }
    
  }
}

size = substr(size_abv, 1, 5)

data_table <- data.table(
  Title = titles,
  Size = size,
  Days_Left = days_left,
  Hours_Left = hours_left,
  Minutes_Left = minutes_left,
  Seconds_Left = seconds_left,
  Winning_Bid = winning_bid,
  Age = Age,
  Bottler = Bottler,
  Classification = Classification,
  Country = Country,
  Number_Bottles = Num_Bottles,
  Region = Region,
  Series = Series,
  Cask_Type = Cask_Type,
  Cask_Number = Cask_Number,
  Bottling_Date = Bottling_Date,
  Strength = Strength)

View(data_table)

write.csv()
