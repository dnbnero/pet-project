SELECT
  SUBSTRING(tconst, 3)::UInt64 AS title_id,
  averageRating::Decimal(3, 1) AS avg_rating,
  numVotes::UInt64 AS num_votes
FROM url(
  'https://datasets.imdbws.com/title.ratings.tsv.gz'
)