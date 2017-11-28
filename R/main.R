#' @importFrom sparklyr invoke_static
#' @importFrom sparklyr spark_session
#' @export
sparknyc_register <- function(sc, neighborhoodFile) {
  sparklyr::invoke_static(sc, "com.miraisolutions.spark.nyc.Main", "register_nyc", spark_session(sc), neighborhoodFile)
}
