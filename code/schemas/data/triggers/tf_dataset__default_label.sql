-- drop function if exists data.tf_dataset__default_label() cascade;
create or replace function data.tf_dataset__default_label()
    returns trigger
    language plpgsql
    security definer
    set search_path = datastore, public
    as $function$

        declare
            _dataset_id uuid;

        begin

            _dataset_id :=
                coalesce(new.dataset_id, old.dataset_id);

            update
                data.dataset
            set
                default_label = data.class__label('dataset',_dataset_id)
            where
                id = _dataset_id;

            return new;

        end;
    $function$;
alter function data.tf_dataset__default_label() owner to edr_wheel;
grant execute on function data.tf_dataset__default_label() to edr_admin, edr_edit;
comment on function data.tf_dataset__default_label()
    is 'Trigger function that updates a dataset''s default label after an attribute is inserted/updated';

-- drop trigger if exists tr_dataset__attribute__delete__default_label on data.dataset__attribute;
create trigger tr_dataset__attribute__delete__default_label
    after delete on data.dataset__attribute
    for each row
    when (
        data.dataset__label__attribute(old.dataset_id, old.attribute_id)
    )
    execute function data.tf_dataset__default_label();
comment on trigger tr_dataset__attribute__delete__default_label on data.dataset__attribute
    is 'Fires the trigger function `data.entity__default_label()` when a label attribute is deleted.';

-- drop trigger if exists tr_dataset__attribute__insert__default_label on data.dataset__attribute;
create trigger tr_dataset__attribute__insert__default_label
    after insert on data.dataset__attribute
    for each row
    when (
        data.dataset__label__attribute(new.dataset_id, new.attribute_id)
    )
    execute function data.tf_dataset__default_label();
comment on trigger tr_dataset__attribute__insert__default_label on data.dataset__attribute
    is 'Fires the trigger function `data.entity__default_label()` when a label attribute is inserted.';

-- drop trigger if exists tr_dataset__attribute__update__default_label on data.dataset__attribute;
create trigger tr_dataset__attribute__update__default_label
    after update on data.dataset__attribute
    for each row
    when (
        data.dataset__label__attribute(new.dataset_id, new.attribute_id)
        and old.value is distinct from new.value
    )
    execute function data.tf_dataset__default_label();
comment on trigger tr_dataset__attribute__update__default_label on data.dataset__attribute
    is 'Fires the trigger function `data.entity__default_label()` when a label attribute is updated.';