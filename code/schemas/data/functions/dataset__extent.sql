-- drop function if exists data.dataset__extent(uuid);
create or replace function data.dataset__extent(
        _dataset_id uuid     -- id of the target class
    )
    returns geometry
    language plpgsql
    set search_path = cm, public
    as $function$

        declare
            _response text; -- function response object

        begin

            -- recursive ... get nested datasets
            with recursive _dataset_locations as (
                    select
                        e.dataset_id,
                        edl.location
                    from
                        data.entity e
                            join data.entity__cmault_location edl
                                on e.id = edl.entity_id
                    where
                        e.dataset_id = _dataset_id
                    union
                    select
                        dl.dataset_id,
                        edl.location
                    from
                        _dataset_locations dl
                            join data.dataset d
                                on dl.dataset_id = d.parent_dataset_id
                            join data.entity e
                                on d.id = e.dataset_id
                            join data.entity__cmault_location edl
                                on e.id = edl.entity_id
                )
            select
                st_buffer(
                    st_concavehull(
                        st_collect(
                            location
                        ),
                        0
                    ),
                    0.01,
                    'endcap=round join=round'
                ) into _response
            from
                _dataset_locations
            group by
                dataset_id;

            return _response;

            exception
                when others then
                    raise notice E'Error building extent for dataset %.\n-- SQL State: %\n-- SQL Error: %', _dataset_id, sqlstate, sqlerrm;
                    return null::geometry;

        end

    $function$;
alter function data.dataset__extent(uuid) owner to edr_wheel;
grant execute on function data.dataset__extent(uuid) to edr_admin, edr_jwt, edr_edit, edr_read;
comment on function data.dataset__extent(uuid)
    is 'Returns a dataset''s (`_dataset_id`) extent as a buffered convex hull (with lightly rounded vertices for aesthetic reasons) enclosing the cmault locations of member entities.';