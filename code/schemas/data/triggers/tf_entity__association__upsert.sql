-- drop function if exists data.tf_entity__association__upsert() cascade;
create or replace function data.tf_entity__association__upsert()
  returns trigger
  language plpgsql
  set search_path = datastore, public
    as $function$

        declare
            _modified_association uuid;
            _temp_row record;

        begin

            select distinct
                ea.id into _modified_association
            from
                data.entity__association ea
                    join cm.association na
                        on new.association_id = na.id
                    join cm.association oa
                        on ea.association_id = oa.id
            where
                ea.id = new.id
                and oa.system__type_id != na.system__type_id;

            if _modified_association is not null then
                raise notice 'Deleting association with modified system__type_id: %', _modified_association;
                delete from data.entity__association where id = _modified_association;
            end if;

            if cm.check_system__type__association('{edr-entity-aggregation}', new.association_id) then

                insert into data.entity__aggregation(
                    id,
                    association_id,
                    entity_id,
                    associated_entity_id,
                    system__order
                )
                values(
                    coalesce(new.id,gen_random_uuid()),
                    new.association_id,
                    new.entity_id,
                    new.associated_entity_id,
                    new.system__order
                )
                on conflict (id) do update
                set
                    id = excluded.id,
                    association_id = excluded.association_id,
                    entity_id = excluded.entity_id,
                    associated_entity_id = excluded.associated_entity_id,
                    system__order = excluded.system__order
                returning
                    *
                into
                    _temp_row;

            else

                insert into data.entity__relationship(
                    id,
                    association_id,
                    entity_id,
                    associated_entity_id,
                    system__order
                )
                values(
                    coalesce(new.id,gen_random_uuid()),
                    new.association_id,
                    new.entity_id,
                    new.associated_entity_id,
                    new.system__order
                )
                on conflict (id) do update
                set
                    id = excluded.id,
                    association_id = excluded.association_id,
                    entity_id = excluded.entity_id,
                    associated_entity_id = excluded.associated_entity_id,
                    system__order = excluded.system__order
                returning
                    *
                into
                    _temp_row;

            end if;

            return new;

        end;
    $function$;
alter function data.tf_entity__association__upsert() owner to edr_wheel;
grant execute on function data.tf_entity__association__upsert() to edr_admin, edr_jwt, edr_edit;
comment on function data.tf_entity__association__upsert()
    is 'An INSTEAD OF trigger function the allows INSERTs and UPDATEs on the view `data.entity__association` to be sent to the correct underlying association table.';

-- drop trigger if exists tr_entity__association__upsert on data.entity__association;
create trigger tr_entity__association__upsert
    instead of insert or update on data.entity__association
    for each row execute function data.tf_entity__association__upsert();
comment on trigger tr_entity__association__upsert on data.entity__association
    is 'Fires the INSTEAD OF trigger function the allows INSERTs and UPDATEs on the view `data.entity__association` to be sent to the correct underlying attribute table.';