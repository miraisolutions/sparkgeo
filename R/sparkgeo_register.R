#' @title Register sparkgeo and Spark User-Defined Functions (UDFs)
#' @description Registers Magellan rules and custom UDFs with Spark
#' @param sc \code{\link[sparklyr]{spark_connection}} provided by sparklyr.
#' @importFrom sparklyr invoke_static
#' @importFrom sparklyr spark_session
#' @export
sparkgeo_register <- function(sc) {
  invoke_static(sc, "com.miraisolutions.spark.geo.SparkGeo", "register", spark_session(sc))
  invisible()
}
