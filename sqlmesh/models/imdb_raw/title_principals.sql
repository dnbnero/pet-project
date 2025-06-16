MODEL (
  kind FULL,
  cron '0 */8 * * *',
  physical_properties (
    order_by = (title_id, person_id, ordering)
  ),
  enabled 'false'
);

SELECT
  SUBSTRING(tconst, 3)::UInt64 AS title_id,
  ordering::UInt16 AS ordering,
  SUBSTRING(nconst, 3)::UInt64 AS person_id,
  ASSUMENOTNULL(category)::LowCardinality(STRING) AS category,
  ASSUMENOTNULL(job)::LowCardinality(STRING) AS job,
  CASE
    WHEN NOT (
      characters IS NULL
    )
    THEN JSONEXTRACT(ASSUMENOTNULL(characters), 'Array(String)')
    ELSE EMPTYARRAYSTRING()
  END AS characters
FROM URL('https://datasets.imdbws.com/title.principals.tsv.gz', 'TSVWithNames')