-- drop function if exists data.class__label(text,text);
create or replace function data.class__label(
        _attribute_table_prefix text,   -- the prefix of the attribute table (dataset or entity)
        _class_id text                  -- id of the target class
    )
    returns text
    language plpgsql
    set search_path = cm, public
    as $function$

        declare
            _system__label_template text; -- the template to be used
            _sql text;
            _response text; -- function response object

        begin

            if _attribute_table_prefix = 'dataset' then
                    select
                        coalesce(
                            clt.system__label_template,
                            cl.system__label_template
                        )
                    into
                        _system__label_template
                    from
                        data.dataset c
                            left join cm.class cl
                                on c.class_id = cl.id
                            left join data.dataset__label_template clt
                                on c.class_id = clt.class_id
                                   and c.id = clt.dataset_id
                    where
                        c.id = _class_id;
                 else
                    select
                        coalesce(
                            clt.system__label_template,
                            cl.system__label_template
                        )
                    into
                        _system__label_template
                    from
                        data.entity e
                            left join data.dataset c
                                on e.dataset_id = c.id
                            left join cm.class cl
                                on e.class_id = cl.id
                            left join data.dataset__label_template clt
                                on e.class_id = clt.class_id
                                   and c.id = clt.dataset_id
                    where
                        e.id = _class_id;
                end if;

            _sql :=
                concat(
                    $$select concat('$$,
                    regexp_replace(
                        _system__label_template,
                        '(\${.+?})',
                        $$', data.class__label_variable_value('$$ || _attribute_table_prefix || $$', '$$ || _class_id || $$', '\1'), '$$,
                        1,
                        0,
                        'i'
                    ),
                    $$')$$
                );

            execute _sql into _response;

            return _response;

            exception
                when others then
                    raise notice E'Error building % label for %.\n-- SQL State: %\n-- SQL Error: %', _attribute_table_prefix, _class_id, sqlstate, sqlerrm;
                    return 'xx-bad-source-value(s)-xx';

        end

    $function$;
alter function data.class__label(text,text) owner to edr_wheel;
grant execute on function data.class__label(text,text) to edr_admin, edr_jwt, edr_edit, edr_read;
comment on function data.class__label(text,text)
    is 'Returns a class''s (`_class_id`) formatted label based on the template defined in `cm.class`|`data.dataset__label_template.system__label_template`.';