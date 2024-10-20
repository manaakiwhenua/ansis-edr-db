create schema if not exists reg authorization edr_wheel;  -- registry
comment on schema reg
    is 'The `reg` schema holds tables, views and functions for the registry used to organise, publish and govern concepts, concept schemes and collections, class models, entities and their datasets.';