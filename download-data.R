library(httr)
library(jsonlite)
library(tidyverse)

get_crypto_data <- function(coin_id, days = "max") {
  url <- paste0("https://api.coingecko.com/api/v3/coins/", coin_id,
                "/market_chart?vs_currency=usd&days=", days)

  message("Trying URL: ", url)
  
  response <- GET(url)

  # Check for success
  if (status_code(response) != 200) {
    print(content(response, as = "text", encoding = "UTF-8"))
    stop("❌ Failed to fetch data. Status code: ", status_code(response))
  }

  # Parse and format
  data <- content(response, as = "text", encoding = "UTF-8") %>%
    fromJSON(flatten = TRUE)

  df <- data$prices %>%
    as_tibble() %>%
    rename(timestamp = V1, price = V2) %>%
    mutate(
      date = as.Date(as.POSIXct(timestamp / 1000, origin = "1970-01-01")),
      .keep = "unused"
    )

  return(df)
}

# ✅ Download and save
btc <- get_crypto_data("bitcoin", days = "365")
eth <- get_crypto_data("ethereum", days = "365")

write_rds(btc, "btc.rds")  # Saved to project folder now
write_rds(eth, "eth.rds")