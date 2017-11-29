library(sparklyr)
library(sparknyc)
library(dplyr)

sc <- spark_connect(master = "local[*]")

# Downloaded from
# https://raw.githubusercontent.com/harsha2010/magellan/master/examples/datasets/NYC-NEIGHBORHOODS/neighborhoods.geojson
sparknyc_register(sc, "/home/nicola/Downloads/neighborhoods.geojson")

latlon <- data.frame(
  lon = c(-74.013127, -73.968703),
  lat = c(40.700940, 40.775303))

latlonSpark <- copy_to(sc, latlon, "latlon")

latlonSpark %>%
  mutate(neighborhood = neighborhood(lat, lon)) %>%
  collect()

######################################################################################

library(sparklyr)
library(sparkbq)
library(sparknyc)
library(dplyr)

gcpJsonKeyfile <- "/home/nicola/Downloads/mirai-sbb-da847ce33b19.json"
Sys.setenv("GOOGLE_APPLICATION_CREDENTIALS" = gcpJsonKeyfile)

config <- spark_config()
config[["spark.hadoop.google.cloud.auth.service.account.json.keyfile"]] = gcpJsonKeyfile

sc <- spark_connect(master = "local[*]", config = config)

sparknyc_register(sc, "/home/nicola/Downloads/neighborhoods.geojson")

bigquery_defaults(
  billingProjectId = "mirai-sbb",
  gcsBucket = "sbb",
  datasetLocation = "US"
)

start.pickup.time = as.POSIXct("2014-01-06 13:00:00", tz = "UTC")
end.pickup.time = as.POSIXct("2014-01-06 13:30:00", tz = "UTC")

# trips <-
#   spark_read_bigquery(
#     sc = sc,
#     name = "trips2014",
#     projectId = "bigquery-public-data",
#     datasetId = "new_york",
#     tableId = "tlc_yellow_trips_2014"
#   ) %>%
#   filter(payment_type == "CRD") %>%
#   select(pickup_latitude, pickup_longitude, tip_amount, total_amount) %>% # pickup_datetime,
#   mutate(
#     tip_pct = tip_amount / total_amount,
#     neighborhood = neighborhood(pickup_latitude, pickup_longitude)
#   ) %>%
#   group_by(neighborhood) %>%
#   summarize(avg_tip_pct = mean(tip_pct)) %>%
#   collect()

# TODO: use the full 2014 dataset once we are happy with the tests
average_tips_per_neighborhood <- spark_read_bigquery(
  sc = sc,
  name = "trips2014",
  projectId = "bigquery-public-data",
  sqlQuery = paste0('SELECT * FROM `bigquery-public-data.new_york.tlc_yellow_trips_2014` WHERE pickup_datetime >= "', 
                    format(start.pickup.time), 
                    '" AND pickup_datetime < "',
                    format(end.pickup.time),
                    '"')
) %>%
  filter(payment_type == "CRD") %>%
  select(pickup_latitude, pickup_longitude, tip_amount, total_amount) %>% # pickup_datetime,
  mutate(
    tip_pct = tip_amount / total_amount,
    neighborhood = neighborhood(pickup_latitude, pickup_longitude)
  ) %>%
  group_by(neighborhood) %>%
  summarize(avg_tip_pct = mean(tip_pct)) %>%
  collect()

library(geojsonio)
library(leaflet)
geoJsonfile = "/home/nicola/Downloads/neighborhoods.geojson"
nyc_neighborhoods <- geojsonio::geojson_read(geoJsonfile,
                                             what = "sp")

average_tips_with_shapes <- nyc_neighborhoods
average_tips_with_shapes@data <- merge(nyc_neighborhoods@data, average_tips_per_neighborhood, all.x = T)

pal <- colorNumeric(c("#FF0000", "#FFFF00", "#00FF00"), average_tips_with_shapes$avg_tip_pct)

average_tips_with_shapes %>%
  leaflet() %>%
  addProviderTiles(providers$OpenStreetMap.BlackAndWhite,
                   options = providerTileOptions(noWrap = TRUE)) %>%
  addPolygons(weight = 1, opacity = 0.7,
              smoothFactor = 0.3, fillOpacity = 0.7,
              fillColor = ~pal(avg_tip_pct),
              label = ~paste0(neighborhood, " - ", round(avg_tip_pct * 100, 2), "%"),
              highlightOptions = highlightOptions(color = "yellow", weight = 2,
                                                  bringToFront = TRUE)) %>%
  addLegend(pal = pal,
            values = ~avg_tip_pct, 
            opacity = 1,
            title = "Tips %",
            labFormat = labelFormat(
              suffix = ' %',
              transform = function(x) 100 * x))
