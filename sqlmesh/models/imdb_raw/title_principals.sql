MODEL (
  kind FULL,
  cron '0 */8 * * *',
  physical_properties (
        order_by = (title_id, person_id, ordering)
    )
);

SELECT
  substr(tconst, 3)::UInt64 AS title_id,
  ordering::UInt16 AS ordering,
  substr(nconst, 3)::UInt64 AS person_id,
  assumeNotNull(category)::LowCardinality(String) AS category,
  assumeNotNull(job)::LowCardinality(String) AS job,
  CASE
    WHEN NOT (
      characters IS NULL
    )
    THEN JSONExtract(assumeNotNull(characters), 'Array(String)')
    ELSE emptyArrayString()
  END AS characters
FROM url('https://datasets.imdbws.com/title.principals.tsv.gz', 'TSVWithNames')