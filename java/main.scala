package com.miraisolutions.spark.geo

import org.apache.spark.sql.SparkSession
import magellan.{Point, Polygon}
import scala.collection.immutable.Map

object UDF {
  def register(spark: SparkSession): Unit = {
    // See https://github.com/harsha2010/magellan#spatial-joins
    magellan.Utils.injectRules(spark)

    spark.udf.register("point", (latitude: Double, longitude: Double) => Point(longitude, latitude))
    spark.udf.register("within", (point: Point, polygon: Polygon) => (point, polygon) match {
      case (null, _) => None
      case (_, null) => None
      case (poi, pol) => Some(poi.within(pol))
    })
    spark.udf.register("metadata_string", (metadata: Map[String, Any], name: String) =>
      metadata(name).asInstanceOf[String])
  }
}
