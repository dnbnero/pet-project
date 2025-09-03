SELECT
  SUBSTRING(tconst, 3)::UInt64 AS title_id,
  averageRating::Decimal(3, 1) AS avg_rating,
  numVotes::UInt64 AS num_votes
FROM READ_CSV(
  "https://datasets.imdbws.com/title.ratings.tsv.gz",
  delim = '\t',
  header = TRUE,
  columns = map('tconst', 'VARCHAR', 'averageRating', 'DECIMAL(3,1)', 'numVotes', 'UInt64'),
  auto_detect = FALSE
)