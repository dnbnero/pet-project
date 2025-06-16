MODEL (
  kind FULL,
  cron '0 */2 * * *',
  audits (
    ACCEPTED_RANGE("column" := avg_rating, min_v := 0, max_v := 10)
  ),
  enabled 'false'
);

SELECT
  SUBSTRING(tconst, 3)::UInt64 AS title_id,
  averageRating::DECIMAL(3, 1) AS avg_rating,
  numVotes::UInt64 AS num_votes
FROM read_csv(
  "https://datasets.imdbws.com/title.ratings.tsv.gz",
  delim = '\t',
  header = true,
  columns = {
        'tconst': 'VARCHAR',
        'averageRating': 'DECIMAL(3,1)',
        'numVotes': 'UInt64'
    },
    auto_detect = false
)