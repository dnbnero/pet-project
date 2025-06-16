MODEL (
  kind FULL,
  cron '0 */8 * * *',
  enabled 'false'
);

SELECT
  SUBSTRING(tconst, 3)::UInt64 AS title_id,
  titleType::LowCardinality(STRING) AS title_type,
  primaryTitle::TEXT AS primary_title,
  originalTitle::TEXT AS original_title,
  isAdult::BOOLEAN AS is_adult,
  startYear::UInt16 AS start_year,
  endYear::UInt16 AS end_year,
  runtimeMinutes::UInt32 AS runtime_minutes,
  CASE
    WHEN NOT (
      genres IS NULL
    )
    THEN SPLITBYCHAR(',', genres::TEXT)
    ELSE EMPTYARRAYSTRING()
  END::LowCardinality(STRING)[] AS genres
FROM URL('https://datasets.imdbws.com/title.basics.tsv.gz', 'TSVWithNames')