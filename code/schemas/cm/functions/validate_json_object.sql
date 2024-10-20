-- drop function if exists cm.validate_json_object;
create or replace function cm.validate_json_object (
        _json_object jsonb,
        _json_schema jsonb
    )
    returns jsonb
    language plpython3u stable
    as
    $py$
        import json
        import jsonschema
        from jsonschema import FormatChecker
        from datetime import datetime


        def datetime_format_checker(instance):
            try:
                if not isinstance(instance, str):
                    return False  # If not a string, it doesn't match the format

                # Attempt to parse the string as a valid date-time
                datetime.strptime(instance, "%Y-%m-%dT%H:%M:%S%z")
                return True
            except ValueError:
                try:
                    # Attempt to parse with decimal seconds
                    datetime.strptime(instance, "%Y-%m-%dT%H:%M:%S.%f%z")
                    return True
                except ValueError:
                    return False


        json_object = json.loads(_json_object)
        json_schema = json.loads(_json_schema)

        result = {}
        exception_report = {}
        errors = []
        json_validation_error = {}
        format_checker = FormatChecker()
        format_checker.checks("date-time")(datetime_format_checker)

        json_validation = jsonschema.Draft202012Validator(json_schema, format_checker=format_checker)
        for json_validation_error in sorted(json_validation.iter_errors(json_object), key=str):
            exception_report['path'] = json_validation_error.json_path.replace('$', 'root')
            exception_report['error'] = json_validation_error.message
            errors.append(exception_report)
            exception_report = {}

        if json_validation_error:
            result['status'] = 'fail'
            result['errors'] = errors
        else:
            result['status'] = 'pass'

        return json.dumps(result)

    $py$;
alter function cm.validate_json_object owner to edr_wheel;
grant execute on function cm.validate_json_object to edr_admin, edr_jwt, edr_edit, edr_read;
comment on function cm.validate_json_object
    is 'Validates a JSON object (`_json_object`) according to the provided JSON Schema (`_json_schema`). Returns a JSON objects with a report on validation errors if the validation fails.';