package com.miraisolutions.spark.geo

import org.apache.spark.sql.DataFrame
import org.apache.spark.sql.functions._
import org.apache.spark.sql.magellan.dsl.expressions._

object SpatialJoin {
  private val pointColumnName = "point"

  def join(left: DataFrame, right: DataFrame, latitude: String, longitude: String, polygon: String,
           dropPolygon: Boolean = true): DataFrame = {
    left
      .withColumn(pointColumnName, point(col(longitude), col(latitude)))
      .join(right)
      .where(col(pointColumnName) within col("polygon"))
      .drop(pointColumnName, polygon)
  }
}
