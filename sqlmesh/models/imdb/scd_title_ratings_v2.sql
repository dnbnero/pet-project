MODEL (
  kind SCD_TYPE_2_BY_COLUMN (
    unique_key title_id,
    columns [avg_rating, num_votes]
  ),
  cron '0 */2 * * *',
  enabled 'false'
);


SELECT
  title_id as title_id,
  avg_rating as avg_rating,
  num_votes as num_votes
FROM imdb_raw.title_ratings