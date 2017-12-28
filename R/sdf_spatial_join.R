#' @title Spatial Join
#' @description Spatially joins two \code{tbl}.
#' @param left An object coercable to a Spark DataFrame.
#' @param right An object coercable to a Spark DataFrame.
#' @param latitude Latitude variable.
#' @param longitude Longitude variable.
#' @param polygon Variable representing the polygon to join.
#' @param dropPolyAfterJoin \code{logical} specifying whether
#' the polygon column (and the index if available) should be
#' dropped after the join. Defaults to \code{TRUE}.
#' @return \code{tbl_spark} resulting from the spatial join.
#' @references
#' \url{https://github.com/harsha2010/magellan}
#' \url{https://magellan.ghost.io/how-does-magellan-scale-geospatial-queries/}
#' @importFrom sparklyr spark_dataframe
#' @importFrom sparklyr spark_connection
#' @importFrom sparklyr invoke_static
#' @importFrom sparklyr sdf_register
#' @import dplyr
#' @export
sdf_spatial_join <- function(left, right, latitude, longitude, polygon = "polygon",
                             dropPolyAfterJoin = TRUE) {
  latitude <- quo_name(enquo(latitude))
  longitude <- quo_name(enquo(longitude))
  polygon <- quo_name(enquo(polygon))

  sdf_left <- spark_dataframe(left)
  sdf_right <- spark_dataframe(right)
  sc <- spark_connection(sdf_left)

  invoke_static(sc, "com.miraisolutions.spark.geo.SpatialJoin", "join", sdf_left,
                sdf_right, latitude, longitude, polygon, dropPolyAfterJoin) %>%
    sdf_register()
}
