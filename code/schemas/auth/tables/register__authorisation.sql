-- drop table if exists auth.register__authorisation cascade;
create table auth.register__authorisation (
	    register_id uuid not null,
	    operator_id uuid not null,
	    operator_access auth_access not null,
	    constraint pk_register__authorisation primary key (register_id,operator_id),
	    constraint fk_register__authorisation__register
            foreign key (register_id) references reg.register (id)
            on delete cascade on update cascade
            deferrable initially deferred,
	    constraint fk_register__authorisation__operator
            foreign key (operator_id) references auth.operator (id)
            on delete cascade on update cascade
            deferrable initially deferred
	);
alter table auth.register__authorisation owner to edr_wheel;
grant insert, update, delete on table auth.register__authorisation to edr_admin, edr_jwt, edr_edit;
grant truncate on table auth.register__authorisation to edr_admin;
grant select on table auth.register__authorisation to edr_admin, edr_jwt, edr_edit, edr_read;
comment on table auth.register__authorisation
    is 'Relates a register to authorised operators (see auth.operator) and the access rights they have.';
comment on column auth.register__authorisation.register_id
    is 'UUID if the register the operator is authorised to access/maintain.';
comment on column auth.register__authorisation.operator_id
    is 'UUID of the authorised operator.';
comment on column auth.register__authorisation.operator_access
    is 'The access rights granted to the authorised operator.';
comment on constraint pk_register__authorisation on auth.register__authorisation
    is 'Ensures an operator is authorised only once per register.';