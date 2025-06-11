MODEL (
  kind FULL,
  cron '0 */8 * * *',
  audits (
    id_is_uniq
  )
);

SELECT
  substr(nconst, 3)::UInt64 AS person_id,
  assumeNotNull(primaryName)::String AS person_name,
  birthYear::Nullable(UInt16) AS birth_year,
  deathYear::Nullable(UInt16) AS death_year,
  CASE
    WHEN NOT (
      knownForTitles IS NULL
    )
    THEN arrayMap(x -> substr(x, 3)::UInt64, splitByChar(',', knownForTitles::String))
    ELSE emptyArrayUInt64()
  END AS known_for_titles
FROM url('https://datasets.imdbws.com/name.basics.tsv.gz', 'TSVWithNames');

AUDIT (
  name id_is_uniq
);

SELECT
  person_id
FROM @this_model
GROUP BY
  person_id
HAVING
  count() > 1