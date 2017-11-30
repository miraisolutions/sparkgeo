spark_dependencies <- function(spark_version, scala_version, ...) {
  sparklyr::spark_dependency(
    jars = c(
      system.file(
        sprintf("java/sparkgeo-%s-%s.jar", spark_version, scala_version),
        package = "sparkgeo"
      )
    ),
    packages = sprintf("harsha2010:magellan:1.0.5-s_%s", scala_version)
  )
}

#' @importFrom sparklyr register_extension
.onLoad <- function(libname, pkgname) {
  sparklyr::register_extension(pkgname)
}
