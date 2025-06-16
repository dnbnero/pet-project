MODEL (
  kind FULL,
  cron '0 */8 * * *',
  enabled 'false'
);

SELECT
  SUBSTRING(titleId, 3)::UInt64 AS title_id,
  ordering::UInt16 AS ordering,
  ASSUMENOTNULL(title)::TEXT AS title,
  ASSUMENOTNULL(region)::LowCardinality(STRING) AS region,
  ASSUMENOTNULL(language)::LowCardinality(STRING) AS language,
  ASSUMENOTNULL(types)::LowCardinality(STRING) AS type,
  ASSUMENOTNULL(attributes)::LowCardinality(STRING) AS attribute,
  isOriginalTitle::BOOLEAN AS is_original_title
FROM URL('https://datasets.imdbws.com/title.akas.tsv.gz', 'TSVWithNames')