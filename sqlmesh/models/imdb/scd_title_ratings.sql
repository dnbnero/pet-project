MODEL (
  kind INCREMENTAL_UNMANAGED,
  cron '0 */2 * * *',
  columns (
    title_id UInt64,
    avg_rating DECIMAL(3, 1),
    num_votes UInt64,
    _loaded  TIMESTAMP
  ),
  enabled 'false'
);

with latest_row as (
  select
    title_id as title_id,
    avg_rating as avg_rating,
    num_votes as num_votes
  from @this_model
  qualify row_number() over (partition by title_id order by _loaded desc) = 1
)
, raw_data as (
  SELECT
    title_id as title_id,
    avg_rating as avg_rating,
    num_votes as num_votes,
    timezone('UTC', now())::timestamp as _loaded
  FROM imdb_raw.title_ratings
)
, new_rows as (
  select
    title_id as title_id,
    avg_rating as avg_rating,
    num_votes as num_votes, 
    _loaded as _loaded
  from raw_data
  where title_id not in (select title_id from @this_model)
)
, updated_rows as (
  select
    rd.title_id as title_id,
    rd.avg_rating as avg_rating,
    rd.num_votes as num_votes,
    rd._loaded as _loaded
  from raw_data rd 
  join latest_row lr
    on rd.title_id = lr.title_id
  where
    rd.avg_rating <> lr.avg_rating
    or rd.num_votes <> lr.num_votes
)
select
  title_id as title_id,
  avg_rating as avg_rating,
  num_votes as num_votes,
  _loaded as _loaded
from new_rows
union all by name 
select
  title_id as title_id,
  avg_rating as avg_rating,
  num_votes as num_votes, 
  _loaded as _loaded
from updated_rows