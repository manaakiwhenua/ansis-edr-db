-- drop function if exists cm.tf_class__system__type__update() cascade;
create or replace function cm.tf_class__system__type__update()
  returns trigger
  language plpgsql
  set search_path = datastore, public
    as $function$

        declare
            _in_use bool;

        begin

            if old.system__type_id is distinct from new.system__type_id then

                with _check as (
                        select
                            true as in_use
                        from
                            data.dataset
                        where
                            class_id = old.id
                        union
                        select
                            true as in_use
                        from
                            data.entity
                        where
                            class_id = old.id
                    )
                select distinct
                    in_use into _in_use
                from
                    _check;

                if coalesce(_in_use,false) then
                    raise exception 'Class % (%) is in use. Its system type cannot be changed.', old.label, old.id;
                end if;

            end if;

            return new;

        end;
    $function$;
alter function cm.tf_class__system__type__update() owner to edr_wheel;
grant execute on function cm.tf_class__system__type__update() to edr_admin, edr_edit;
comment on function cm.tf_class__system__type__update()
    is 'Trigger function that implements a check to ensure that a class hasn''t been referenced in the `data` schema. If it has then changes to the class''s system type are restricted as it will have impacted how the record is stored and managed in the `data` schema.';

-- drop trigger if exists tr_class__update__system__type on cm.class;
create trigger tr_class__update__system__type
    before update on cm.class
    execute function cm.tf_class__system__type__update();
comment on trigger tr_class__update__system__type on cm.class
    is 'Fires the trigger function `cm.tf_class__system__type__update()`.';