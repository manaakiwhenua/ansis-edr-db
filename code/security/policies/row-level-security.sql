-- ==============================================
-- RLS Policies
-- ==============================================
/*
-- reg.register
alter table reg.register enable row level security;
create policy rls_register__all on reg.register
    for all to edr_jwt
    using (auth.operator__register_access(id,'edit')=200)
    with check (auth.operator__register_access(id,'edit')=200);
create policy rls_register__select on reg.register
    for select to edr_jwt
    using (auth.operator__register_access(id,'read')=200);

-- reg.register__attribute
alter table reg.register__attribute enable row level security;
create policy rls_register__attribute__all on reg.register__attribute
    for all to edr_jwt
    using (auth.operator__register_access(register_id,'edit')=200)
    with check (auth.operator__register_access(register_id,'edit')=200);
create policy rls_dataset__attribute__select on reg.register__attribute
    for select to edr_jwt
    using (auth.operator__register_access(register_id,'read')=200);

-- data.binary_object
alter table data.binary_object enable row level security;
create policy rls_binary_object__all on data.binary_object
    for all to edr_jwt
    using (auth.operator__object_access(id,'edit')=200)
    with check (auth.operator__object_access(id,'edit')=200);
create policy rls_binary_object__select on data.binary_object
    for select to edr_jwt
    using (auth.operator__object_access(id,'read')=200);

-- data.dataset
alter table data.dataset enable row level security;
create policy rls_dataset__all on data.dataset
    for all to edr_jwt
    using (auth.operator__register_access(id,'edit')=200)
    with check (auth.operator__register_access(id,'edit')=200);
create policy rls_dataset__select on data.dataset
    for select to edr_jwt
    using (auth.operator__register_access(id,'read')=200);

-- data.dataset__attribute
alter table data.dataset__attribute enable row level security;
create policy rls_dataset__attribute__all on data.dataset__attribute
    for all to edr_jwt
    using (auth.operator__register_access(dataset_id,'edit')=200)
    with check (auth.operator__register_access(dataset_id,'edit')=200);
create policy rls_dataset__attribute__select on data.dataset__attribute
    for select to edr_jwt
    using (auth.operator__register_access(dataset_id,'read')=200);

-- data.dataset__default_extent
alter table data.dataset__default_extent enable row level security;
create policy rls_dataset__default_extent__all on data.dataset__default_extent
    for all to edr_jwt
    using (auth.operator__register_access(dataset_id,'edit')=200)
    with check (auth.operator__register_access(dataset_id,'edit')=200);
create policy rls_dataset__default_extent__select on data.dataset__default_extent
    for select to edr_jwt
    using (auth.operator__register_access(dataset_id,'read')=200);

-- data.dataset__label_template
alter table data.dataset__label_template enable row level security;
create policy rls_dataset__label_template__all on data.dataset__label_template
    for all to edr_jwt
    using (auth.operator__register_access(dataset_id,'edit')=200)
    with check (auth.operator__register_access(dataset_id,'edit')=200);
create policy rls_dataset__label_template__select on data.dataset__label_template
    for select to edr_jwt
    using (auth.operator__register_access(dataset_id,'read')=200);

-- data.entity
alter table data.entity enable row level security;
create policy rls_entity__all on data.entity
    for all to edr_jwt
    using (auth.operator__register_access(dataset_id,'edit')=200)
    with check (auth.operator__register_access(dataset_id,'edit')=200);
create policy rls_entity__select on data.entity
    for select to edr_jwt
    using (auth.operator__register_access(dataset_id,'read')=200);

-- data.entity__aggregation
alter table data.entity__aggregation enable row level security;
create policy rls_entity__aggregation__all on data.entity__aggregation
    for all to edr_jwt
    using (auth.operator__entity_access(entity_id,'edit')=200)
    with check (auth.operator__entity_access(entity_id,'edit')=200);
create policy rls_entity__aggregation__select on data.entity__aggregation
    for select to edr_jwt
    using (auth.operator__entity_access(entity_id,'read')=200);

-- data.entity__assertion
alter table data.entity__assertion enable row level security;
create policy rls_entity__assertion__all on data.entity__assertion
    for all to edr_jwt
    using (auth.operator__entity_access(entity_id,'edit')=200)
    with check (auth.operator__entity_access(entity_id,'edit')=200);
create policy rls_entity__assertion__select on data.entity__assertion
    for select to edr_jwt
    using (auth.operator__entity_access(entity_id,'read')=200);

-- data.entity__default_location
alter table data.entity__default_location enable row level security;
create policy rls_entity__default_location__all on data.entity__default_location
    for all to edr_jwt
    using (auth.operator__entity_access(entity_id,'edit')=200)
    with check (auth.operator__entity_access(entity_id,'edit')=200);
create policy rls_entity__default_location__select on data.entity__default_location
    for select to edr_jwt
    using (auth.operator__entity_access(entity_id,'read')=200);

-- data.entity__measurement
alter table data.entity__measurement enable row level security;
create policy rls_entity__measurement__all on data.entity__measurement
    for all to edr_jwt
    using (auth.operator__entity_access(entity_id,'edit')=200)
    with check (auth.operator__entity_access(entity_id,'edit')=200);
create policy rls_entity__measurement__select on data.entity__measurement
    for select to edr_jwt
    using (auth.operator__entity_access(entity_id,'read')=200);

-- data.entity__observation
alter table data.entity__observation enable row level security;
create policy rls_entity__observation__all on data.entity__observation
    for all to edr_jwt
    using (auth.operator__entity_access(entity_id,'edit')=200)
    with check (auth.operator__entity_access(entity_id,'edit')=200);
create policy rls_entity__observation__select on data.entity__observation
    for select to edr_jwt
    using (auth.operator__entity_access(entity_id,'read')=200);

-- data.entity__relationship
alter table data.entity__relationship enable row level security;
create policy rls_entity__relationship__all on data.entity__relationship
    for all to edr_jwt
    using (auth.operator__entity_access(entity_id,'edit')=200)
    with check (auth.operator__entity_access(entity_id,'edit')=200);
create policy rls_entity__relationship__select on data.entity__relationship
    for select to edr_jwt
    using (auth.operator__entity_access(entity_id,'read')=200);
*/