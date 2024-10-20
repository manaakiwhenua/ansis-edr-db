-- drop function if exists data.tf_dataset__label_template__update() cascade;
create or replace function data.tf_dataset__label_template__update()
    returns trigger
    language plpgsql
    security definer
    set search_path = datastore, public
    as $function$

        declare
            _class_system__type text;

        begin

            _class_system__type :=
                case when cm.check_system__type__class(
                            'edr-dataset',
                            new.class_id,
                            true
                        )
                     then 'edr-dataset'
                     when cm.check_system__type__class(
                            'edr-entity',
                            new.class_id,
                            true
                        )
                     then 'edr-entity'
                end;

            if _class_system__type = 'edr-dataset' then
                update
                    data.dataset
                set
                    default_label = data.class__label('edr-dataset', id)
                where
                    data.dataset.class_id = new.class_id
                    and data.dataset.id = new.dataset_id
                    and old.system__label_template != new.system__label_template;
            end if;
            if _class_system__type = 'edr-entity' then
                update
                    data.entity
                set
                    default_label = data.class__label('edr-entity',id)
                where
                    data.entity.class_id = new.class_id
                    and data.entity.dataset_id = new.dataset_id
                    and old.system__label_template != new.system__label_template;
            end if;

            return new;

        end;

    $function$;
alter function data.tf_dataset__label_template__update() owner to edr_wheel;
grant execute on function data.tf_dataset__label_template__update() to edr_admin, edr_edit;
comment on function data.tf_dataset__label_template__update()
    is 'Trigger function that updates an entity or dataset''s default label if the class''s dataset level default label template is changed.';

-- drop trigger if exists tr_dataset__label_template__update on data.dataset__label_template;
create trigger tr_dataset__label_template__update
    after update of system__label_template on data.dataset__label_template
    for each row
    execute function data.tf_dataset__label_template__update();
comment on trigger tr_dataset__label_template__update on data.dataset__label_template
    is 'Fires the trigger function `data.tf_dataset__label_template__update()`.';