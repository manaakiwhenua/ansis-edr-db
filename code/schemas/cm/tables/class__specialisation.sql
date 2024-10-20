-- drop table if exists cm.class__specialisation cascade;
create table cm.class__specialisation (
	    id uuid default gen_random_uuid() not null,
	    class_id text not null,
	    sub_class_id text not null,
	    constraint pk_class__specialisation
	        primary key (id),
	    constraint uq_class__specialisation__association
	        unique (class_id, sub_class_id)
            deferrable initially deferred,
	    constraint fk_class__specialisation__class
            foreign key (class_id) references cm.class (id)
            on delete cascade on update cascade
            deferrable initially deferred,
        constraint fk_class__specialisation__sub_class
            foreign key (sub_class_id) references cm.class (id)
            on delete cascade on update cascade
            deferrable initially deferred,
        constraint ck_class__specialisation__recursion
	        check ( not(sub_class_id = any(cm.class__super_class(class_id))) )
	);
-- create index if not exists fx_class__specialisation__class on cm.class__specialisation(class_id);
-- create index if not exists fx_class__specialisation__sub_class on cm.class__specialisation(sub_class_id);
alter table cm.class__specialisation owner to edr_wheel;
grant insert, update, delete on table cm.class__specialisation to edr_admin, edr_jwt, edr_edit;
grant truncate on table cm.class__specialisation to edr_admin;
grant select on table cm.class__specialisation to edr_admin, edr_jwt, edr_edit, edr_read;
comment on table cm.class__specialisation
    is 'Relates class types to the sub-class types that specialise their behaviour.';
comment on column cm.class__specialisation.id
    is 'Class specialisation UUID.';
comment on column cm.class__specialisation.class_id
    is 'Class ID.';
comment on column cm.class__specialisation.sub_class_id
    is 'Sub-class ID.';
comment on constraint uq_class__specialisation__association on cm.class__specialisation
    is 'Ensures only one specialisation association between a class and sub-class is created.';
comment on constraint ck_class__specialisation__recursion on cm.class__specialisation
    is 'Recursion trap. Checks that the sub-class is not already specified as an ancestor of the class.';