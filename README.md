# sparkgeo: sparklyr extension package providing geospatial analytics capabilities

**sparkgeo** is a [sparklyr](https://spark.rstudio.com/) [extension](https://spark.rstudio.com/articles/guides-extensions.html) package providing an integration with [Magellan](https://github.com/harsha2010/magellan), a Spark package for  geospatial analytics on big data.

## Version Information

**sparkgeo** is under active development and has not been released yet to [CRAN](https://cran.r-project.org/). You can install the latest version through
``` r
devtools::install_github("miraisolutions/sparkgeo", ref = "develop")
```

## Example Usage

``` r
require(sparklyr)
require(sparkgeo)
require(dplyr)
require(tidyr)

# Download geojson file containing NYC neighborhood polygon information
# (http://data.beta.nyc/dataset/pediacities-nyc-neighborhoods)
geojson_file <- "nyc_neighborhoods.geojson"
download.file("https://goo.gl/eu1yWN", geojson_file)

# Start local Spark cluster
config <- spark_config()
sc <- spark_connect(master = "local", config = config)

# Register sparkgeo with Spark
sparkgeo_register(sc)

# Import data from GeoJSON file into a Spark DataFrame
neighborhoods <-
  spark_read_geojson(
    sc = sc,
    name = "neighborhoods",
    path = geojson_file
  ) %>%
  mutate(neighborhood = metadata_string(metadata, "neighborhood")) %>%
  select(neighborhood, polygon, index) %>%
  sdf_persist()

# Download and transform locations of New York City museums;
# see https://catalog.data.gov/dataset/new-york-city-museums
museums.df <- 
  read.csv("https://data.cityofnewyork.us/api/views/fn6f-htvy/rows.csv?accessType=DOWNLOAD",
           stringsAsFactors = FALSE) %>%
  extract(the_geom, into = c("longitude", "latitude"),
          regex = "POINT \\((-?\\d+\\.?\\d*) (-?\\d+\\.?\\d*)\\)") %>%
  mutate(longitude = as.numeric(longitude), latitude = as.numeric(latitude)) %>%
  rename(name = NAME) %>%
  select(name, latitude, longitude)
  
# Create Spark DataFrame from local R data.frame
museums <- copy_to(sc, museums.df, "museums")

# Perform a spatial join to associate museum coordinates to
# corresponding neighborhoods, then show the top 5 neighborhoods
# in terms of number of museums
museums %>%
  sdf_spatial_join(neighborhoods, latitude, longitude) %>%
  select(name, neighborhood) %>%
  group_by(neighborhood) %>%
  summarize(num_museums = n()) %>%
  top_n(5) %>%
  collect()

# Stop local Spark cluster
spark_disconnect(sc)
```

The last `dplyr` pipeline returns:
```
# A tibble: 5 x 2
        neighborhood num_museums
               <chr>       <dbl>
1    Upper East Side          13
2            Chelsea          11
3            Midtown           9
4               SoHo           8
5 Financial District           7
```
