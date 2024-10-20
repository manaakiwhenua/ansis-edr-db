-- drop function if exists data.tf_entity__association__delete() cascade;
create or replace function data.tf_entity__association__delete()
    returns trigger
    language plpgsql
    set search_path = datastore, public
    as $function$

        begin

            if cm.check_system__type__association('{edr-entity-aggregation}', old.association_id) then

                delete from
                    data.entity__aggregation
                where
                    id = old.id;

            else

                delete from
                    data.entity__relationship
                where
                    id = old.id;

            end if;

            return null;

        end;
    $function$;
alter function data.tf_entity__association__delete() owner to edr_wheel;
grant execute on function data.tf_entity__association__delete() to edr_admin, edr_jwt, edr_edit;
comment on function data.tf_entity__association__delete()
    is 'An INSTEAD OF trigger function the allows DELETEs on the view `data.entity__association` to be sent to the correct underlying association table.';

-- drop trigger if exists tr_entity__association__upsert on data.entity__association;
create trigger tr_entity__association__delete
    instead of delete on data.entity__association
    for each row
    execute function data.tf_entity__association__delete();
comment on trigger tr_entity__association__delete on data.entity__association
    is 'Fires the INSTEAD OF trigger function the allows DELETEs on the view `data.entity__association` to be sent to the correct underlying association table.';