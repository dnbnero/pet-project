SELECT
  SUBSTRING(tconst, 3)::UInt64 AS title_id,
  CASE
    WHEN NOT (
      directors IS NULL
    )
    THEN ARRAYMAP(x -> SUBSTRING(x, 3)::UInt64, SPLITBYCHAR(',', directors::String))
    ELSE EMPTYARRAYUINT64()
  END AS directors,
  CASE
    WHEN NOT (
      writers IS NULL
    )
    THEN ARRAYMAP(x -> SUBSTRING(x, 3)::UInt64, SPLITBYCHAR(',', writers::String))
    ELSE EMPTYARRAYUINT64()
  END AS writers
FROM URL('https://datasets.imdbws.com/title.crew.tsv.gz', 'TSVWithNames')