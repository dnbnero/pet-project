SELECT
  SUBSTRING(titleId, 3)::UInt64 AS title_id,
  ordering::UInt16 AS ordering,
  ASSUMENOTNULL(title)::String AS title,
  ASSUMENOTNULL(region)::LowCardinality(String) AS region,
  ASSUMENOTNULL(language)::LowCardinality(String) AS language,
  ASSUMENOTNULL(types)::LowCardinality(String) AS type,
  ASSUMENOTNULL(attributes)::LowCardinality(String) AS attribute,
  isOriginalTitle::Bool AS is_original_title
FROM URL('https://datasets.imdbws.com/title.akas.tsv.gz', 'TSVWithNames')