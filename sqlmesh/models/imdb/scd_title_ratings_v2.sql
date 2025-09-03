MODEL (
  kind SCD_TYPE_2_BY_COLUMN (
    unique_key title_id,
    columns [avg_rating, num_votes]
  ),
  cron '0 */2 * * *'
);

SELECT
  title_id AS title_id,
  avg_rating AS avg_rating,
  num_votes AS num_votes
FROM imdb_raw.title_ratings