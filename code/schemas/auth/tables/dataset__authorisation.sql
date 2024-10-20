-- drop table if exists auth.dataset__authorisation cascade;
create table auth.dataset__authorisation (
	    dataset_id uuid not null,
	    operator_id uuid not null,
	    operator_access auth_access not null,
	    constraint pk_dataset__authorisation primary key (dataset_id,operator_id),
	    constraint fk_dataset__authorisation__dataset
            foreign key (dataset_id) references data.dataset (id)
            on delete cascade on update cascade
            deferrable initially deferred,
	    constraint fk_dataset__authorisation__operator
            foreign key (operator_id) references auth.operator (id)
            on delete cascade on update cascade
            deferrable initially deferred
	);
alter table auth.dataset__authorisation owner to edr_wheel;
grant insert, update, delete on table auth.dataset__authorisation to edr_admin, edr_edit;
grant truncate on table auth.dataset__authorisation to edr_admin;
grant select on table auth.dataset__authorisation to edr_admin, edr_jwt, edr_edit, edr_read;
comment on table auth.dataset__authorisation
    is 'Relates a dataset to authorised operators (see auth.operator) and the access rights they have.';
comment on column auth.dataset__authorisation.dataset_id
    is 'UUID if the dataset the operator is authorised to access/maintain.';
comment on column auth.dataset__authorisation.operator_id
    is 'UUID of the authorised operator.';
comment on column auth.dataset__authorisation.operator_access
    is 'The access rights granted to the authorised operator.';
comment on constraint pk_dataset__authorisation on auth.dataset__authorisation
    is 'Ensures an operator is authorised only once per dataset.';