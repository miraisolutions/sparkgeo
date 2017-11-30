#' @title Reading GeoJSON files
#' @description Imports data from GeoJSON files into Spark DataFrames.
#' @param sc \code{\link[sparklyr]{spark_connection}} provided by sparklyr.
#' @param name The name to assign to the newly generated table (see also
#' \code{\link[sparklyr]{spark_read_source}}).
#' @param path The path to the GeoJSON file. This may be a local path or
#' an HDFS path.
#' @param magellanIndex \code{logical} specifying whether geometries should
#' be indexed when loading the data (see
#' \url{https://github.com/harsha2010/magellan#creating-indexes-while-loading-data}).
#' Indexing creates an additional column called "index" which holds the list of
#' ZOrder curves of the given precision (see argument \code{magellanIndexPrecision}).
#' Defaults to \code{TRUE}.
#' @param magellanIndexPrecision \code{integer} specifying the precision to use for creating
#' the ZOrder curves.
#' @param ... Additional arguments passed to \code{\link[sparklyr]{spark_read_source}}.
#' @return A \code{tbl_spark} which provides a \code{dplyr}-compatible reference to a
#' Spark DataFrame.
#' @references
#' \url{https://github.com/harsha2010/magellan}
#' \url{http://geojson.org/}
#' @family Spark serialization routines
#' @seealso \code{\link[sparklyr]{spark_read_source}}
#' @keywords file, connection
#' @importFrom sparklyr spark_read_source
#' @export
spark_read_geojson <- function(sc, name, path, magellanIndex = TRUE, magellanIndexPrecision = 30L, ...) {
  spark_read_source(
    sc = sc,
    name = name,
    source = "magellan",
    options = list(
      "type" = "geojson",
      "magellan.index" = ifelse(magellanIndex, "true", "false"),
      "magellan.index.precision" = as.character(magellanIndexPrecision),
      "path" = path
    ),
    ...
  )
}
