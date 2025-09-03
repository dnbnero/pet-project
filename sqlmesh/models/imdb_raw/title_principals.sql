SELECT
  SUBSTRING(tconst, 3)::UInt64 AS title_id,
  ordering::UInt16 AS ordering,
  SUBSTRING(nconst, 3)::UInt64 AS person_id,
  ASSUMENOTNULL(category)::LowCardinality(String) AS category,
  ASSUMENOTNULL(job)::LowCardinality(String) AS job,
  CASE
    WHEN NOT (
      characters IS NULL
    )
    THEN JSONEXTRACT(ASSUMENOTNULL(characters), 'Array(String)')
    ELSE EMPTYARRAYSTRING()
  END AS characters
FROM URL('https://datasets.imdbws.com/title.principals.tsv.gz', 'TSVWithNames')