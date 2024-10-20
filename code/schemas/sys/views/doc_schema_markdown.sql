-- drop view if exists sys.doc_schema_markdown cascade;
create or replace view sys.doc_schema_markdown as
    with _column_def as (
            select
                c.schema_name,
                c.table_name,
                string_agg(
                    concat(
                        '| ', c.column_name, ' | ', c.data_type, ' | ',
                        case when not(t.table_type ~ 'view') then
                            concat(
                                c.key, ' | ', '`' || c.fk_references || '`' , ' | ', c.is_nullable, ' | ',
                                case
                                    when
                                        strpos(c.column_default, '''') > 0
                                    then c.column_default
                                    else '`' || c.column_default || '`'
                                end,
                                ' | '
                            )
                        end,
                        c.column_description, ' |'
                    ),
                    E'\n'
                ) || E'\n' as doc_markdown
            from
                sys.doc_column c
                    join sys.doc_table t on c.schema_name = t.schema_name
                                        and c.table_name = t.table_name
            group by
                c.schema_name,
                c.table_name
        ),
        _constraint_def as (
            select
                schema_name,
                table_name,
                string_agg(
                concat(
                        '| ', constraint_name, ' | ', constraint_type, ' | ', '`' || constraint_columns || '`', ' | ', constraint_description, ' |'
                    ),
                    E'\n'
                ) as doc_markdown
            from
                sys.doc_constraint
            group by
                schema_name,
                table_name
        ),
        _index_def as (
            select
                schema_name,
                table_name,
                string_agg(
                    concat(
                        '| ', index_name, ' | ', index_type, ' | ', '`' || index_columns || '`', ' |'
                    ),
                    E'\n'
                ) as doc_markdown
            from
                sys.doc_index
            group by
                schema_name,
                table_name
        ),
        _table_def as (
            select
                t.schema_name,
                t.table_name,
                concat_ws(
                    E'\n',
                    concat(
                        '### ', t.schema_name, '.', t.table_name, ' \[', t.table_type, '\]',
                        E'\n'
                    ),
                    t.table_description,
                    concat(
                        E'\n',
                        '| Column | Data type | ',
                        case when not(t.table_type ~ 'view') then
                            'Key | FK References | Null | Default | '
                        end,
                        'Definition |'
                    ),
                    concat(
                        '| ------ | --------- | ',
                        case when not (t.table_type ~ 'view') then
                            '--- | ------------- | ---- | ------- | '
                        end,
                        '---------- |'
                    ),
                    c.doc_markdown,
                    '| Constraint | Type | Columns | Description |' || E'\n' ||
                    '| ---------- | ---- | ------- | ----------- |' || E'\n' ||
                    ct.doc_markdown || E'\n',
                    '| Index | Type | Columns |' || E'\n' ||
                    '| ----- | ---- | ------- |' || E'\n' ||
                    ix.doc_markdown || E'\n'
                ) as doc_markdown
            from
                sys.doc_table t
                    left join _column_def c on t.schema_name = c.schema_name
                                           and t.table_name = c.table_name
                    left join _constraint_def ct on t.schema_name = ct.schema_name
                                                and t.table_name = ct.table_name
                    left join _index_def ix on t.schema_name = ix.schema_name
                                                and t.table_name = ix.table_name
        ),
        _function_def as (
            select
                schema_name,
                concat_ws(
                    E'\n',
                    E'\n',
                    '| Function | Type | Arguments | Returns | Description |',
                    '| -------- | ---- | --------- | ------- | ----------- |',
                    string_agg(
                        concat(
                            '| ', function_name, ' | ', function_type, ' | ', function_arguments, ' | ', function_returns, ' | ', function_description, ' |'
                        ),
                        E'\n'
                    )
                ) as doc_markdown
            from
                sys.doc_function
            group by
                schema_name
        )
    select
        s.schema_name,
        concat(
            '[//]: # "Autogenerated from EDR database view sys.doc_schema_markdown"',
            E'\n\n',
            '# EDR ', s.schema_name, ' Schema Documentation',
            E'\n\n',
            '## Overview',
            E'\n',
            s.schema_description,
            E'\n\n',
            '> __Figure__ `',
            s.schema_name,
            '` schema tables.',
            E'\n\n',
            '![schema - ',
            s.schema_name,
            '](../figs/schema%20-%20',
            s.schema_name,
            '.png)',
            E'\n\n',
            '## Tables and views' ||
            E'\n\n' ||
            string_agg(
                t.doc_markdown,
                E'\n'
            ),
            E'\n\n' ||
            '## Functions' ||
            f.doc_markdown
        ) as doc_markdown
    from
        sys.doc_schema s
            left join _table_def t on s.schema_name = t.schema_name
            left join _function_def f on s.schema_name = f.schema_name
    group by
        s.schema_name,
        s.schema_description,
        f.doc_markdown;
alter table sys.doc_schema_markdown owner to edr_wheel;
grant select on table sys.doc_schema_markdown to edr_admin, edr_jwt, edr_edit, edr_read;
comment on view sys.doc_schema_markdown
    is 'Documentation of EDR database schema and their contents, formatted using markdown.';
comment on column sys.doc_schema_markdown.schema_name
    is 'The name of the database schema.';
comment on column sys.doc_schema_markdown.doc_markdown
    is 'The markdown document.';