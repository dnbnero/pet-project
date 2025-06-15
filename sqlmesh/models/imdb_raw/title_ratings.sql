MODEL (
  kind FULL,
  cron '0 */2 * * *',
  audits (
    accepted_range(column := avg_rating, min_v := 0, max_v := 10)
  )
);

-- SELECT
--   substr(tconst, 3)::UInt64 AS title_id,
--   averageRating::Decimal(3, 1) AS avg_rating,
--   numVotes::UInt64 AS num_votes
-- FROM url('https://datasets.imdbws.com/title.ratings.tsv.gz', 'TSVWithNames')

SELECT
  substr(tconst, 3)::UInt64 AS title_id,
  averageRating::Decimal(3, 1) AS avg_rating,
  numVotes::UInt64 AS num_votes
FROM 'https://datasets.imdbws.com/title.ratings.tsv.gz'