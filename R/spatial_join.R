#' @title Spatial Join
#' @description Spatially joins two \code{tbl}.
#' @param x \code{tbl} to join.
#' @param y \code{tbl} to join.
#' @param latitude Latitude variable.
#' @param longitude Longitude variable.
#' @param polygon Polygon variable as usually provided by
#' \code{\link{spark_read_geojson}}.
#' @return \code{tbl} resulting from the spatial join.
#' @note The current implementation performs a cartesian product with a
#' subsequent filter since generic joins are not currently available in
#' \pkg{dplyr} (see https://github.com/tidyverse/dplyr/issues/2240).
#' Spark SQL's Catalyst optimizer seems to be able to optimize this
#' in a way it is not necessary to compute a full cartesian product.
#' @references
#' \url{https://github.com/harsha2010/magellan}
#' @import dplyr
#' @export
spatial_join <- function(x, y, latitude, longitude, polygon) {
  latitude <- enquo(latitude)
  longitude <- enquo(longitude)
  polygon <- enquo(polygon)

  # inner join with subsequent filter since generic joins are not available
  # yet in dplyr: https://github.com/tidyverse/dplyr/issues/2240

  x %>%
    mutate(dummy = TRUE) %>% # https://github.com/tidyverse/dplyr/issues/1841
    inner_join(y %>% mutate(dummy = TRUE)) %>%
    mutate(is_within = within(point(!!latitude, !!longitude), !!polygon)) %>%
    filter(is_within) %>%
    select(-one_of("dummy", "is_within"))
}
