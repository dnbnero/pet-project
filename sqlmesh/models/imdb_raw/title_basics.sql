SELECT
  SUBSTRING(tconst, 3)::UInt64 AS title_id,
  titleType::LowCardinality(String) AS title_type,
  primaryTitle::String AS primary_title,
  originalTitle::String AS original_title,
  isAdult::Bool AS is_adult,
  startYear::UInt16 AS start_year,
  endYear::UInt16 AS end_year,
  runtimeMinutes::UInt32 AS runtime_minutes,
  CASE
    WHEN NOT (
      genres IS NULL
    )
    THEN SPLITBYCHAR(',', genres::String)
    ELSE EMPTYARRAYSTRING()
  END::Array(Nullable(LowCardinality(String))) AS genres
FROM URL('https://datasets.imdbws.com/title.basics.tsv.gz', 'TSVWithNames')