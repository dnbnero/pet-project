MODEL (
  kind FULL,
  cron '0 */8 * * *'
);

SELECT
  substr(tconst, 3)::UInt64 AS title_id,
  titleType::LowCardinality(String) AS title_type,
  primaryTitle::String AS primary_title,
  originalTitle::String AS original_title,
  isAdult::Bool AS is_adult,
  startYear::Nullable(UInt16) AS start_year,
  endYear::Nullable(UInt16) AS end_year,
  runtimeMinutes::Nullable(UInt32) AS runtime_minutes,
  CASE
    WHEN NOT (
      genres IS NULL
    )
    THEN splitByChar(',', genres::String)
    ELSE emptyArrayString()
  END::Array(LowCardinality(String)) AS genres
FROM url('https://datasets.imdbws.com/title.basics.tsv.gz', 'TSVWithNames')