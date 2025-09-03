SELECT
  SUBSTRING(tconst, 3)::UInt64 AS title_id,
  SUBSTRING(parentTconst, 3)::UInt64 AS parent_title_id,
  ASSUMENOTNULL(seasonNumber)::UInt16 AS season_number,
  ASSUMENOTNULL(episodeNumber)::UInt16 AS episode_number
FROM URL('https://datasets.imdbws.com/title.episode.tsv.gz', 'TSVWithNames')