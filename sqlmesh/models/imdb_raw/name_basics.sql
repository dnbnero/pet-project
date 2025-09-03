SELECT
  SUBSTRING(nconst, 3)::UInt64 AS person_id,
  ASSUMENOTNULL(primaryName)::String AS person_name,
  birthYear::UInt16 AS birth_year,
  deathYear::UInt16 AS death_year,
  CASE
    WHEN NOT (
      knownForTitles IS NULL
    )
    THEN ARRAYMAP(x -> SUBSTRING(x, 3)::UInt64, SPLITBYCHAR(',', knownForTitles::String))
    ELSE EMPTYARRAYUINT64()
  END AS known_for_titles
FROM URL('https://datasets.imdbws.com/name.basics.tsv.gz', 'TSVWithNames')