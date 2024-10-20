-- drop function if exists cm.tf_class__system__label_template__update() cascade;
create or replace function cm.tf_class__system__label_template__update()
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
                            new.id,
                            true
                        )
                     then 'edr-dataset'
                     when cm.check_system__type__class(
                            'edr-entity',
                            new.id,
                            true
                        )
                     then 'edr-entity'
                end;

            if old.system__label_template != new.system__label_template then
                if _class_system__type = 'edr-dataset' then
                    update
                        data.dataset
                    set
                        default_label = data.dataset__label(id)
                    where
                        data.dataset.class_id = new.id
                        and not exists (
                            select
                                0
                            from
                                data.dataset__label_template clt
                            where
                                clt.dataset_id = data.dataset.id
                                and clt.class_id = data.dataset.class_id
                        );
                end if;
                if _class_system__type = 'entity' then
                    update
                        data.entity
                    set
                        default_label = data.entity__label(id)
                    where
                        data.entity.class_id = new.id
                        and not exists (
                            select
                                0
                            from
                                data.dataset__label_template clt
                            where
                                clt.dataset_id = data.entity.dataset_id
                                and clt.class_id = data.entity.class_id
                        );
                end if;
            end if;

            return new;

        end;

    $function$;
alter function cm.tf_class__system__label_template__update() owner to edr_wheel;
grant execute on function cm.tf_class__system__label_template__update() to edr_admin, edr_edit;
comment on function cm.tf_class__system__label_template__update()
    is 'Trigger function that updates an entity or dataset''s default label if the class''s default label template is changed. Does not update labels templated at a dataset level.';

-- drop trigger if exists tr_class__update__system__label_template on cm.class;
create trigger tr_class__update__system__label_template
    after update of system__label_template on cm.class
    for each row
    execute function cm.tf_class__system__label_template__update();
comment on trigger tr_class__update__system__label_template on cm.class
    is 'Fires the trigger function `cm.tf_class__system__label_template__update()`.';