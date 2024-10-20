-- drop function if exists data.tf_entity__default_location() cascade;
create or replace function data.tf_entity__default_location()
  returns trigger
  language plpgsql
    security definer
  set search_path = datastore, public
    as $function$

        declare
            _entity_id uuid;
            _location geometry;

        begin

                _entity_id :=
                    coalesce(new.entity_id,old.entity_id);

                _location :=
                    data.entity__location(_entity_id);

                if tg_op = 'DELETE' then
                    delete from
                        data.entity__default_location
                    where
                        entity_id = _entity_id;
                else
                    -- upsert the location
                    insert into
                        data.entity__default_location(
                            entity_id,
                            location
                        )
                    values (
                        _entity_id,
                        _location
                    )
                    on conflict (entity_id) do
                    update
                        set location = excluded.location
                    where
                        data.entity__default_location.location is distinct from excluded.location;
                end if;

                return new;

                exception
                    when others then
                        raise notice E'Error executing tf_entity__default_location %.\n-- SQL State: %\n-- SQL Error: %', _entity_id, sqlstate, sqlerrm;
                        if tg_op = 'UPDATE' then -- remove previous geometry (it has been replaced)
                            raise notice 'Removing previous geometry for entity %. Default location will be added again when a properly structured geometry value is provided.', _entity_id;
                            delete from
                                data.entity__default_location
                            where
                                entity_id = _entity_id;
                        end if;
                        return null;

        end;
    $function$;
alter function data.tf_entity__default_location() owner to edr_wheel;
grant execute on function data.tf_entity__default_location() to edr_admin, edr_edit;
comment on function data.tf_entity__default_location()
    is 'Trigger function that updates a entity''s default location after an attribute is inserted/updated/deleted.';

-- drop trigger if exists tr_entity__observation__delete__default_location on data.entity__observation;
create trigger tr_entity__observation__delete__default_location
    after delete on data.entity__observation
    for each row
    when (data.entity__location__attribute(old.entity_id, old.attribute_id))
    execute function data.tf_entity__default_location();
comment on trigger tr_entity__observation__delete__default_location on data.entity__observation
    is 'Fires the trigger function `data.entity__default_location()` when a location attribute is deleted.';

-- drop trigger if exists tr_entity__observation__insert__default_location on data.entity__observation;
create trigger tr_entity__observation__insert__default_location
    after insert on data.entity__observation
    for each row
    when (
        data.entity__location__attribute(new.entity_id, new.attribute_id)
    )
    execute function data.tf_entity__default_location();
comment on trigger tr_entity__observation__insert__default_location on data.entity__observation
    is 'Fires the trigger function `data.entity__default_location()` when a location attribute is inserted.';

-- drop trigger if exists tr_entity__observation__update__default_location on data.entity__observation;
create trigger tr_entity__observation__update__default_location
    after update on data.entity__observation
    for each row
    when (
        data.entity__location__attribute(new.entity_id, new.attribute_id)
        and old.value is distinct from new.value
    )
    execute function data.tf_entity__default_location();
comment on trigger tr_entity__observation__update__default_location on data.entity__observation
    is 'Fires the trigger function `data.entity__default_location()` when a location attribute is updated.';

-- drop trigger if exists tr_entity__measurement__delete__default_location on data.entity__measurement;
create trigger tr_entity__measurement__delete__default_location
    after delete on data.entity__measurement
    for each row
    when (data.entity__location__attribute(old.entity_id, old.attribute_id))
    execute function data.tf_entity__default_location();
comment on trigger tr_entity__measurement__delete__default_location on data.entity__measurement
    is 'Fires the trigger function `data.entity__default_location()` when a location attribute is deleted.';

-- drop trigger if exists tr_entity__measurement__insert__default_location on data.entity__measurement;
create trigger tr_entity__measurement__insert__default_location
    after insert on data.entity__measurement
    for each row
    when (
        data.entity__location__attribute(new.entity_id, new.attribute_id)
    )
    execute function data.tf_entity__default_location();
comment on trigger tr_entity__measurement__insert__default_location on data.entity__measurement
    is 'Fires the trigger function `data.entity__default_location()` when a location attribute is inserted.';

-- drop trigger if exists tr_entity__measurement__update__default_location on data.entity__measurement;
create trigger tr_entity__measurement__update__default_location
    after update on data.entity__measurement
    for each row
    when (
        data.entity__location__attribute(new.entity_id, new.attribute_id)
        and old.value is distinct from new.value
    )
    execute function data.tf_entity__default_location();
comment on trigger tr_entity__measurement__update__default_location on data.entity__measurement
    is 'Fires the trigger function `data.entity__default_location()` when a location attribute is updated.';