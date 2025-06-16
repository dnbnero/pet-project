MODEL (
  kind FULL,
  cron '0 */8 * * *',
  enabled 'false'
);

SELECT
  SUBSTRING(tconst, 3)::UInt64 AS title_id,
  CASE
    WHEN NOT (
      directors IS NULL
    )
    THEN ARRAYMAP(x -> SUBSTRING(x, 3)::UInt64, SPLITBYCHAR(',', directors::TEXT))
    ELSE EMPTYARRAYUINT64()
  END AS directors,
  CASE
    WHEN NOT (
      writers IS NULL
    )
    THEN ARRAYMAP(x -> SUBSTRING(x, 3)::UInt64, SPLITBYCHAR(',', writers::TEXT))
    ELSE EMPTYARRAYUINT64()
  END AS writers
FROM URL('https://datasets.imdbws.com/title.crew.tsv.gz', 'TSVWithNames')