package com.miraisolutions.spark.nyc

import org.apache.spark.sql.{DataFrame, SparkSession}
import org.apache.spark.sql.magellan.dsl.expressions._
import org.apache.spark.sql.functions._

object Main {

  private def read_neighborhoods(spark: SparkSession, path: String): DataFrame = {
    import spark.implicits._

    spark.read
      .format("magellan")
      .option("type", "geojson")
      .option("magellan.index", "true")
      .load(path)
      .select($"polygon", $"metadata"("neighborhood").as("name"))
      .cache()
  }

  private var neighborhoods: DataFrame = _

  private val match_neighborhood = (latitude: Double, longitude: Double) => {
    neighborhoods
      .filter(point(lit(longitude), lit(latitude)) within col("polygon"))
      .select("name")
      .collect()
      .map(_.getString(0))
      .headOption
      .getOrElse(null)
  }

  def register_nyc(spark: SparkSession, neighborhoodFile: String): Unit = {
    neighborhoods = read_neighborhoods(spark, neighborhoodFile)
    spark.udf.register("neighborhood", match_neighborhood)
  }
}
