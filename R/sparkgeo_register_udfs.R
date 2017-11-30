#' @title Register Spark User-Defined Functions (UDFs)
#' @description Registers UDFs with Spark
#' @param sc \code{\link[sparklyr]{spark_connection}} provided by sparklyr.
#' @importFrom sparklyr invoke_static
#' @importFrom sparklyr spark_session
#' @export
sparkgeo_register_udfs <- function(sc) {
  sparklyr::invoke_static(sc, "com.miraisolutions.spark.geo.UDF", "register", spark_session(sc))
  invisible()
}
