-- drop function if exists data.entity__aggregates();
create or replace function data.entity__aggregates(
        _entity_id uuid  -- id of the class type
    )
    returns uuid[]
    language plpgsql
    set search_path = cm, public
    as $function$

        declare
            _response uuid[]; -- function response object

        begin

            with recursive _aggregates as (
                    select
                        frc.entity_id
                    from
                        data.entity__aggregation frc
                    where
                        frc.associated_entity_id = _entity_id
                    union all
                    select
                        frc.entity_id
                    from
                        _aggregates p
                            join data.entity__aggregation frc on p.entity_id = frc.associated_entity_id
                )
            select
                array_agg(entity_id)
                into _response
            from
                _aggregates;

            return _response;

        end

    $function$;
alter function data.entity__aggregates(uuid) owner to edr_wheel;
grant execute on function data.entity__aggregates(uuid) to edr_admin, edr_jwt, edr_edit, edr_read;
comment on function data.entity__aggregates(uuid) is
    'Returns an array of uuids of the entities of which an entity (`_entity_id`) is a part.';