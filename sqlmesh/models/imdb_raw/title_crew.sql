MODEL (
  kind FULL,
  cron '0 */8 * * *'
);

SELECT
  substr(tconst, 3)::UInt64 AS title_id,
  CASE
    WHEN NOT (
      directors IS NULL
    )
    THEN arrayMap(x -> substr(x, 3)::UInt64, splitByChar(',', directors::String))
    ELSE emptyArrayUInt64()
  END AS directors,
  CASE
    WHEN NOT (
      writers IS NULL
    )
    THEN arrayMap(x -> substr(x, 3)::UInt64, splitByChar(',', writers::String))
    ELSE emptyArrayUInt64()
  END AS writers
FROM url('https://datasets.imdbws.com/title.crew.tsv.gz', 'TSVWithNames')