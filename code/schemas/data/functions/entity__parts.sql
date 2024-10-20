-- drop function if exists data.entity__parts();
create or replace function data.entity__parts(
        _entity_id uuid  -- id of the class type
    )
    returns uuid[]
    language plpgsql
    set search_path = def, public
    as $function$

        declare
            _response uuid[]; -- function response object

        begin

            with recursive _parts as (
                    select
                        frc.associated_entity_id
                    from
                        data.entity__aggregation frc
                    where
                        frc.entity_id = _entity_id
                    union all
                    select
                        frc.associated_entity_id
                    from
                        _parts p
                            join data.entity__aggregation frc on p.associated_entity_id = frc.entity_id
                )
            select
                array_agg(associated_entity_id)
                into _response
            from
                _parts;

            return _response;

        end

    $function$;
alter function data.entity__parts(uuid) owner to edr_wheel;
grant execute on function data.entity__parts(uuid) to edr_admin, edr_jwt, edr_edit, edr_read;
comment on function data.entity__parts(uuid) is
    'Returns an array of uuids of the parts (and their parts) of an aggregate entity (`_entity_id`).';