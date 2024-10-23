-- clean up
truncate table
    reg.register
    cascade;
truncate table
    auth.register__authorisation
    cascade;

-- insert registers
insert into reg.register (id, default_label, register_id)
    values ('a7187fec-1098-4c4d-a2bf-9d5544deeaa2', 'ANSIS Registry', null),
           ('54c83d3f-3314-438f-a5b3-54fd34480bdb', 'Domain Model', 'a7187fec-1098-4c4d-a2bf-9d5544deeaa2'),
           ('e3f68055-82bf-4e3d-a30c-3bf3eaf4eb1d', 'Vocabularies', 'a7187fec-1098-4c4d-a2bf-9d5544deeaa2');

-- add register__attribute table inserts

-- insert register authorisations
insert into auth.register__authorisation(register_id, operator_id, operator_access)
    values ('a7187fec-1098-4c4d-a2bf-9d5544deeaa2','5a4031c0-2136-411f-a80f-960e14a6d68e','admin');  -- Allow anonymous admin for this project.