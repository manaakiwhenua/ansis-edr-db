-- drop function if exists cm.tf_class_model__system__type__update() cascade;
create or replace function cm.tf_class_model__system__type__update()
  returns trigger
  language plpgsql
  set search_path = datastore, public
    as $function$

        declare
            _in_use bool;

        begin

            if old.system__type_id is distinct from new.system__type_id then

                select distinct
                    true into _in_use
                from
                    data.dataset
                where
                    class_model_id = old.id;

                if coalesce(_in_use,false) then
                    raise exception 'Class model % (%) is in use. Its system type cannot be changed.', old.label, old.id;
                end if;

            end if;

            return new;

        end;
    $function$;
alter function cm.tf_class_model__system__type__update() owner to edr_wheel;
grant execute on function cm.tf_class_model__system__type__update() to edr_admin, edr_edit;
comment on function cm.tf_class_model__system__type__update()
    is 'Trigger function that implements a check to ensure that a class model hasn''t been referenced in the `data` schema. If it has then changes to the class model''s system type are restricted as it will have impacted how the record is stored and managed in the `data` schema.';

-- drop trigger if exists tr_class_model__update__system__type on cm.class_model;
create trigger tr_class_model__update__system__type
    before update on cm.class_model
    execute function cm.tf_class_model__system__type__update();
comment on trigger tr_class_model__update__system__type on cm.class_model
    is 'Fires the trigger function `cm.tf_class_model__system__type__update()`.';