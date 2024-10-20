-- drop function if exists data.tf_entity__attribute__upsert() cascade;
create or replace function data.tf_entity__attribute__upsert()
    returns trigger
    language plpgsql
    set search_path = datastore, public
    as $function$

        declare
            _modified_attribute uuid;
            _temp_row record;

        begin

            select distinct
                ea.id into _modified_attribute
            from
                data.entity__attribute ea
                    join cm.attribute na
                        on new.attribute_id = na.id
                    join cm.attribute oa
                        on ea.attribute_id = oa.id
            where
                ea.id = new.id
                and replace(oa.system__type_id,'edr-prediction','edr-measurement') != replace(na.system__type_id,'edr-prediction','edr-measurement');

            if _modified_attribute is not null then
                raise notice 'Deleting attribute with modified system__type_id: %', _modified_attribute;
                delete from data.entity__attribute where id = _modified_attribute;
            end if;

            if cm.check_system__type__attribute('{edr-assertion}', new.attribute_id) then

                insert into data.entity__assertion(
                    id,
                    entity_id,
                    attribute_id,
                    value
                )
                values(
                    coalesce(new.id,gen_random_uuid()),
                    new.entity_id,
                    new.attribute_id,
                    new.value
                )
                on conflict (id) do update
                set
                    id = excluded.id,
                    entity_id = excluded.entity_id,
                    attribute_id = excluded.attribute_id,
                    value = excluded.value
                returning
                    *
                into
                    _temp_row;

            end if;

            if cm.check_system__type__attribute('{edr-observation}', new.attribute_id) then

                insert into data.entity__observation(
                    id,
                    entity_id,
                    attribute_id,
                    value,
                    procedure__entity_id,
                    quality
                )
                values(
                    coalesce(new.id,gen_random_uuid()),
                    new.entity_id,
                    new.attribute_id,
                    new.value,
                    new.procedure__entity_id,
                    new.quality
                )
                on conflict (id) do update
                set
                    id = excluded.id,
                    entity_id = excluded.entity_id,
                    attribute_id = excluded.attribute_id,
                    value = excluded.value,
                    procedure__entity_id = excluded.procedure__entity_id,
                    quality = excluded.quality
                returning
                    *
                into
                    _temp_row;

            end if;

            if cm.check_system__type__attribute('{edr-measurement,edr-prediction}', new.attribute_id) then

                insert into data.entity__measurement(
                    id,
                    entity_id,
                    attribute_id,
                    value,
                    procedure__entity_id,
                    agent_entity_id,
                    time,
                    quality
                )
                values(
                    coalesce(new.id,gen_random_uuid()),
                    new.entity_id,
                    new.attribute_id,
                    new.value,
                    new.procedure__entity_id,
                    new.agent_entity_id,
                    new.time,
                    new.quality
                )
                on conflict (id) do update
                set
                    id = excluded.id,
                    entity_id = excluded.entity_id,
                    attribute_id = excluded.attribute_id,
                    value = excluded.value,
                    procedure__entity_id = excluded.procedure__entity_id,
                    agent_entity_id = excluded.agent_entity_id,
                    time = excluded.time,
                    quality = excluded.quality
                returning
                    *
                into
                    _temp_row;

            end if;

            return new;

        end;
    $function$;
alter function data.tf_entity__attribute__upsert() owner to edr_wheel;
grant execute on function data.tf_entity__attribute__upsert() to edr_admin, edr_jwt, edr_edit;
comment on function data.tf_entity__attribute__upsert()
    is 'An INSTEAD OF trigger function the allows INSERTs and UPDATEs on the view `data.entity__attribute` to be sent to the correct underlying attribute table.';

-- drop trigger if exists tr_entity__attribute__upsert on data.entity__attribute;
create trigger tr_entity__attribute__upsert
    instead of insert or update on data.entity__attribute
    for each row
    execute function data.tf_entity__attribute__upsert();
comment on trigger tr_entity__attribute__upsert on data.entity__attribute
    is 'Fires the INSTEAD OF trigger function the allows INSERTs and UPDATEs on the view `data.entity__attribute` to be sent to the correct underlying attribute table.';