-- drop function if exists data.tf_dataset__default_extent() cascade;
create or replace function data.tf_dataset__default_extent()
    returns trigger
    language plpgsql
    security definer
    as $function$

        begin

            execute
                format(
                    $f$
                        insert into
                            data.dataset__default_extent(
                                dataset_id,
                                extent
                            )
                        select
                            e.dataset_id,
                            data.dataset__extent(e.dataset_id) as extent
                        from
                            %1$s_entity__default_location edl
                                join data.entity e
                                    on edl.entity_id = e.id
                        group by
                            e.dataset_id
                        on conflict (dataset_id) do
                        update
                            set extent = excluded.extent
                        where
                            data.dataset__default_extent.extent is distinct from excluded.extent;
                    $f$,
                    case when tg_op = 'DELETE' then 'old' else 'new' end
                );

            return null;

        end;
    $function$;
alter function data.tf_dataset__default_extent() owner to edr_wheel;
grant execute on function data.tf_dataset__default_extent() to edr_admin, edr_edit;
comment on function data.tf_dataset__default_extent()
    is 'Trigger function that updates a dataset''s default extent after an entity''s default location is inserted/updated/deleted.';

-- drop trigger if exists tr_entity__default_location__delete__dataset__default_extent on data.entity__default_location;
create trigger tr_entity__default_location__delete__dataset__default_extent
    after delete on data.entity__default_location
    referencing OLD table as old_entity__default_location
    for each statement
    execute function data.tf_dataset__default_extent();
comment on trigger tr_entity__default_location__delete__dataset__default_extent on data.entity__default_location
    is 'Fires the trigger function `data.dataset__default_extent()` when an entity''s default location attribute is deleted.';

-- drop trigger if exists tr_entity__default_location__insert__dataset__default_extent on data.entity__default_location;
create trigger tr_entity__default_location__insert__dataset__default_extent
    after insert on data.entity__default_location
    referencing NEW table as new_entity__default_location
    for each statement
    execute function data.tf_dataset__default_extent();
comment on trigger tr_entity__default_location__insert__dataset__default_extent on data.entity__default_location
    is 'Fires the trigger function `data.dataset__default_extent()` when an entity''s default location attribute is inserted.';

-- drop trigger if exists tr_entity__default_location__update__dataset__default_extent on data.entity__default_location;
create trigger tr_entity__default_location__update__dataset__default_extent
    after update on data.entity__default_location
    referencing OLD table as old_entity__default_location NEW table as new_entity__default_location
    for each statement
    execute function data.tf_dataset__default_extent();
comment on trigger tr_entity__default_location__update__dataset__default_extent on data.entity__default_location
    is 'Fires the trigger function `data.dataset__default_extent()` when an entity''s default location attribute is updated.';