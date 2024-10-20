-- drop function if exists data.tf_entity__attribute__delete() cascade;
create or replace function data.tf_entity__attribute__delete()
    returns trigger
    language plpgsql
    set search_path = datastore, public
    as $function$

        begin

            if cm.check_system__type__attribute('{edr-assertion}', old.attribute_id) then

                delete from
                    data.entity__assertion
                where
                    id = old.id;

            end if;

            if cm.check_system__type__attribute('{edr-observation}', old.attribute_id) then

                delete from
                    data.entity__observation
                where
                    id = old.id;

            end if;

            if cm.check_system__type__attribute('{edr-measurement,edr-prediction}', old.attribute_id) then

                delete from
                    data.entity__measurement
                where
                    id = old.id;

            end if;

            return null;

        end;
    $function$;
alter function data.tf_entity__attribute__delete() owner to edr_wheel;
grant execute on function data.tf_entity__attribute__delete() to edr_admin, edr_jwt, edr_edit;
comment on function data.tf_entity__attribute__delete()
    is 'An INSTEAD OF trigger function the allows DELETEs on the view `data.entity__attribute` to be sent to the correct underlying attribute table.';

create trigger tr_entity__attribute__delete
    instead of delete on data.entity__attribute
    for each row
    execute function data.tf_entity__attribute__delete();
comment on trigger tr_entity__attribute__delete on data.entity__attribute
    is 'Fires the INSTEAD OF trigger function the allows DELETEs on the view `data.entity__attribute` to be sent to the correct underlying attribute table.';