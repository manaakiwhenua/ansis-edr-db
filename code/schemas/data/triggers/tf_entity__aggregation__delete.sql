-- drop function if exists data.tf_entity__aggregation__delete() cascade;
create or replace function data.tf_entity__aggregation__delete()
  returns trigger
  language plpgsql
  set search_path = datastore, public
    as $function$

        begin

            delete from
                data.entity
            where
                id = old.associated_entity_id;

            return new;

        end;
    $function$;
alter function data.tf_entity__aggregation__delete() owner to edr_wheel;
grant execute on function data.tf_entity__aggregation__delete() to edr_admin, edr_jwt, edr_edit;
comment on function data.tf_entity__aggregation__delete()
    is 'A trigger function that ensures the aggregated entities in an aggregation are deleted when the aggregate entity is deleted.';

-- drop trigger if exists tr_entity__aggregation__delete on data.entity__aggregation;
create trigger tr_entity__aggregation__delete
    after delete on data.entity__aggregation
    for each row execute function data.tf_entity__aggregation__delete();
comment on trigger tr_entity__aggregation__delete on data.entity__aggregation
    is 'Fires the trigger function `data.tf_entity__aggregation__delete()`.';