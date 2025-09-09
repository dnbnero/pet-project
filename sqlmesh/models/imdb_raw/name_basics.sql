SELECT
  SUBSTRING(nconst, 3)::UInt64 AS person_id,
  assumeNotNull(primaryName)::String AS person_name,
  birthYear::UInt16 AS birth_year,
  deathYear::UInt16 AS death_year,
  CASE
    WHEN NOT (
      knownForTitles IS NULL
    )
    THEN arrayMap(x -> SUBSTRING(x, 3)::UInt64, splitByChar(',', knownForTitles::String))
    ELSE emptyArrayUInt64()
  END AS known_for_titles
FROM url('https://datasets.imdbws.com/name.basics.tsv.gz', 'TSVWithNames')