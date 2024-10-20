-- drop function if exists data.tf_entity__default_label() cascade;
create or replace function data.tf_entity__default_label()
  returns trigger
  language plpgsql
    security definer
  set search_path = datastore, public
    as $function$

        declare
            _entity_id uuid;

        begin

            _entity_id :=
                coalesce(new.entity_id, old.entity_id);

            update
                data.entity
            set
                default_label = data.class__label('entity',_entity_id)
            where
                id = _entity_id;

            return new;

        end;
    $function$;
alter function data.tf_entity__default_label() owner to edr_wheel;
grant execute on function data.tf_entity__default_label() to edr_admin, edr_edit;
comment on function data.tf_entity__default_label()
    is 'Trigger function that updates a entity''s default label after an attribute is inserted/updated/deleted.';

-- drop trigger if exists tr_entity__assertion__delete__default_label on data.entity__assertion;
create trigger tr_entity__assertion__delete__default_label
    after delete on data.entity__assertion
    for each row
    when (data.entity__label__attribute(old.entity_id, old.attribute_id))
    execute function data.tf_entity__default_label();
comment on trigger tr_entity__assertion__delete__default_label on data.entity__assertion
    is 'Fires the trigger function `data.entity__default_label()` when a label attribute is deleted.';

-- drop trigger if exists tr_entity__assertion__insert__default_label on data.entity__assertion;
create trigger tr_entity__assertion__insert__default_label
    after insert on data.entity__assertion
    for each row
    when (
        data.entity__label__attribute(new.entity_id, new.attribute_id)
    )
    execute function data.tf_entity__default_label();
comment on trigger tr_entity__assertion__insert__default_label on data.entity__assertion
    is 'Fires the trigger function `data.entity__default_label()` when a label attribute is inserted.';

-- drop trigger if exists tr_entity__assertion__update__default_label on data.entity__assertion;
create trigger tr_entity__assertion__update__default_label
    after update on data.entity__assertion
    for each row
    when (
        data.entity__label__attribute(new.entity_id, new.attribute_id)
        and old.value is distinct from new.value
    )
    execute function data.tf_entity__default_label();
comment on trigger tr_entity__assertion__update__default_label on data.entity__assertion
    is 'Fires the trigger function `data.entity__default_label()` when a label attribute is updated.';

-- drop trigger if exists tr_entity__observation__delete__default_label on data.entity__observation;
create trigger tr_entity__observation__delete__default_label
    after delete on data.entity__observation
    for each row
    when (data.entity__label__attribute(old.entity_id, old.attribute_id))
    execute function data.tf_entity__default_label();
comment on trigger tr_entity__observation__delete__default_label on data.entity__observation
    is 'Fires the trigger function `data.entity__default_label()` when a label attribute is deleted.';

-- drop trigger if exists tr_entity__observation__insert__default_label on data.entity__observation;
create trigger tr_entity__observation__insert__default_label
    after insert on data.entity__observation
    for each row
    when (
        data.entity__label__attribute(new.entity_id, new.attribute_id)
    )
    execute function data.tf_entity__default_label();
comment on trigger tr_entity__observation__insert__default_label on data.entity__observation
    is 'Fires the trigger function `data.entity__default_label()` when a label attribute is inserted.';

-- drop trigger if exists tr_entity__observation__update__default_label on data.entity__observation;
create trigger tr_entity__observation__update__default_label
    after update on data.entity__observation
    for each row
    when (
        data.entity__label__attribute(new.entity_id, new.attribute_id)
        and old.value is distinct from new.value
    )
    execute function data.tf_entity__default_label();
comment on trigger tr_entity__observation__update__default_label on data.entity__observation
    is 'Fires the trigger function `data.entity__default_label()` when a label attribute is updated.';

-- drop trigger if exists tr_entity__measurement__delete__default_label on data.entity__measurement;
create trigger tr_entity__measurement__delete__default_label
    after delete on data.entity__measurement
    for each row
    when (data.entity__label__attribute(old.entity_id, old.attribute_id))
    execute function data.tf_entity__default_label();
comment on trigger tr_entity__measurement__delete__default_label on data.entity__measurement
    is 'Fires the trigger function `data.entity__default_label()` when a label attribute is deleted.';

-- drop trigger if exists tr_entity__measurement__insert__default_label on data.entity__measurement;
create trigger tr_entity__measurement__insert__default_label
    after insert on data.entity__measurement
    for each row
    when (
        data.entity__label__attribute(new.entity_id, new.attribute_id)
    )
    execute function data.tf_entity__default_label();
comment on trigger tr_entity__measurement__insert__default_label on data.entity__measurement
    is 'Fires the trigger function `data.entity__default_label()` when a label attribute is inserted.';

-- drop trigger if exists tr_entity__measurement__update__default_label on data.entity__measurement;
create trigger tr_entity__measurement__update__default_label
    after update on data.entity__measurement
    for each row
    when (
        data.entity__label__attribute(new.entity_id, new.attribute_id)
        and old.value is distinct from new.value
    )
    execute function data.tf_entity__default_label();
comment on trigger tr_entity__measurement__update__default_label on data.entity__measurement
    is 'Fires the trigger function `data.entity__default_label()` when a label attribute is updated.';