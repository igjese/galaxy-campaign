extends Node

'''
Simplified YAML parser, which supports:
- Top-level dictionaries (like goal: seek_and_destroy)
- Top-level lists of dictionaries (like your combat_rules.yaml)
- Nested lists and scalars
- Basic types (int, float, bool, string)
- Simple indentation-based structure (2 spaces)
'''

# Parses simplified YAML to a Dictionary or Array
func parse_simple_yaml(text: String) -> Variant:
    var lines = text.split("\n", false)
    return _parse_lines(lines)

func _parse_lines(lines: PackedStringArray, base_indent := 0, start_line := 0) -> Variant:
    var result = []
    var current_dict = {}
    var mode = null  # 'dict' or 'list'

    var i = start_line
    while i < lines.size():
        var raw_line = lines[i]
        var indent = raw_line.length() - raw_line.lstrip(" ").length()
        if indent < base_indent or raw_line.strip_edges() == "" or raw_line.strip_edges().begins_with("#"):
            if indent < base_indent:
                break  # end of current block
            i += 1
            continue

        var line = raw_line.strip_edges()

        if line.begins_with("- "):  # list item
            if mode == null:
                mode = "list"
                result = []
            elif mode != "list":
                push_error("Mixed dict/list mode at line %d: %s" % [i, line])
                return {}

            var value_line = line.substr(2, line.length()).strip_edges()
            if ": " in value_line:  # dict entry inside list
                var sub_lines = PackedStringArray()
                sub_lines.append(value_line)
                var sub_indent = indent + 2
                var j = i + 1
                while j < lines.size():
                    var next_indent = lines[j].length() - lines[j].lstrip(" ").length()
                    if next_indent < sub_indent:
                        break
                    sub_lines.append(lines[j])
                    j += 1
                result.append(_parse_lines(sub_lines, sub_indent))
                i = j - 1
            else:
                result.append(_parse_value(value_line))
        elif ": " in line:  # key-value pair
            if mode == null:
                mode = "dict"
                result = {}
            elif mode != "dict":
                push_error("Mixed dict/list mode at line %d: %s" % [i, line])
                return {}

            var parts = line.split(":", false, 2)
            var key = parts[0].strip_edges()
            var value = parts[1].strip_edges()
            if value == "":
                # Possibly a nested block
                var sub_indent = indent + 2
                var sub_lines = PackedStringArray()
                var j = i + 1
                while j < lines.size():
                    var next_indent = lines[j].length() - lines[j].lstrip(" ").length()
                    if next_indent < sub_indent:
                        break
                    sub_lines.append(lines[j])
                    j += 1
                result[key] = _parse_lines(sub_lines, sub_indent)
                i = j - 1
            else:
                result[key] = _parse_value(value)
        i += 1

    return result

func _parse_value(value: String) -> Variant:
    value = value.strip_edges()
    
    # Check for integer
    if value.is_valid_float() and "." not in value:
        return int(value)
    elif value.is_valid_float():
        return float(value)
    elif value == "true":
        return true
    elif value == "false":
        return false
    elif value.begins_with("\"") and value.ends_with("\""):
        return value.substr(1, value.length() - 2)
    else:
        return value
