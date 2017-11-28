spec <- sparklyr::spark_default_compilation_spec()
spec <- Filter(function(e) e$spark_version >= "2.0.0", spec)
spec <- Map(function(e) {
    scala_version <- gsub(pattern = ".*scala-([0-9]+\\.[0-9]+).*", "\\1", e$scalac_path)
    # e$jar_dep <- sprintf("harsha2010:magellan:1.0.5-s_%s", scala_version)
    e$jar_dep <- sprintf("/home/mstuder/.ivy2/cache/harsha2010/magellan/jars/magellan-1.0.5-s_%s.jar", scala_version)
    e
  }, spec)
sparklyr::compile_package_jars(spec = spec)
