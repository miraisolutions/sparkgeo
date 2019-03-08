spark_dependencies <- function(spark_version, scala_version, ...) {
  jars = system.file(
    sprintf("java/sparkgeo-%s-%s.jar", spark_version, scala_version),
    package = "sparkgeo"
  )
  if (jars == "")
    # we can still allow spark_connect() to continue, but sparkgeo_register(sc) will fail later
    warning(sprintf(
      "sparkgeo extension: unsupported version combination - spark: %s, scala: %s",
      spark_version,
      scala_version
    ))
  sparklyr::spark_dependency(
    jars = jars,
    packages = sprintf("harsha2010:magellan:1.0.5-s_%s", scala_version)
  )
}

#' @importFrom sparklyr register_extension
.onLoad <- function(libname, pkgname) {
  sparklyr::register_extension(pkgname)
}
