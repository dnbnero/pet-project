MODEL (
  kind FULL,
  cron '0 */8 * * *'
);

SELECT
  substr(titleId, 3)::UInt64 AS title_id,
  ordering::UInt16 AS ordering,
  assumeNotNull(title)::String AS title,
  assumeNotNull(region)::LowCardinality(String) AS region,
  assumeNotNull(language)::LowCardinality(String) AS language,
  assumeNotNull(types)::LowCardinality(String) AS type,
  assumeNotNull(attributes)::LowCardinality(String) AS attribute,
  isOriginalTitle::Bool AS is_original_title
FROM url('https://datasets.imdbws.com/title.akas.tsv.gz', 'TSVWithNames')