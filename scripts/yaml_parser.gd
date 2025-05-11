extends Node

'''
Simplified YAML parser, which supports:
- Top-level dictionaries (like goal: seek_and_destroy)
- Top-level lists of dictionaries (like your combat_rules.yaml)
- Nested lists and scalars
- Basic types (int, float, bool, string)
- Simple indentation-based structure (4 spaces because godot editor)
'''

const INDENT_UNIT := 2

func load_yaml(path: String) -> Variant:
    var file := FileAccess.open(path, FileAccess.READ)
    if not file:
        print("[YamlParser] Could not open file: " + path)
        return {}

    var text := file.get_as_text()
    file.close()

    var result = parse_simple_yaml(text)
    if result == null:
        print("[YamlParser] Failed to parse YAML from: " + path)
        return {}

    print(JSON.stringify(result, "  "))
    return result


func parse_simple_yaml(text: String) -> Variant:
    var lines = []
    for raw in text.split("\n", false):
        var trimmed = raw.strip_edges(false)
        if trimmed == "" or trimmed.begins_with("#"):
            continue
        lines.append(trimmed)
    return parse_lines(lines)[0]
    

func parse_lines(lines: Array, start: int = 0, current_indent: int = 0):
    var result = null
    var i = start
    var mode = null

    while i < lines.size():
        var raw_line = lines[i]
        var indent = raw_line.length() - raw_line.lstrip(" ").length()
        if indent < current_indent:
            print("🔚 End of block at line %d (indent %d < %d)" % [i, indent, current_indent])
            break

        var entry = raw_line.strip_edges()
        print("🔍 Line %d (indent %d): %s" % [i, indent, entry])

        if entry.begins_with("- "):
            var item = entry.substr(2).strip_edges()
            print("📌 List item: %s" % item)

            if mode == null:
                mode = "list"
                result = []
                print("📋 Start of list block")
            elif mode != "list":
                print("❌ Expected list item, but dict mode is active")
                return [{}, i]
                
            if not item.ends_with(":"):
                var parsed = _parse_value(item)
                print("📦 Scalar list value: %s" % str(parsed))
                result.append(parsed)
            else:
                var key = item.left(item.length() - 1).strip_edges()
                print("📂 Nested list block under key '%s'" % key)
                var parse_result = parse_lines(lines, i + 1, current_indent + INDENT_UNIT)
                var subresult = {}
                subresult[key] = parse_result[0]
                result.append(subresult)
                i = parse_result[1]
                continue
        else:
            if mode == "list":
                print("🔚 Closing list block because line is not a list item")
                return [result, i]
            
            print("🧱 Dict entry: %s" % entry)

            if mode == null:
                mode = "dict"
                result = {}
                print("📄 Start of dict block")
            elif mode != "dict":
                print("❌ Expected dict entry, but list mode is active")
                return [{}, i]

            if entry.ends_with(":"):
                var key = entry.left(entry.length() - 1).strip_edges()
                print("📂 Nested dict block under key '%s'" % key)
                var parse_result = parse_lines(lines, i + 1, current_indent + INDENT_UNIT)
                result[key] = parse_result[0]
                i = parse_result[1]
                continue
            else:
                var parts = entry.split(":", false, 2)
                if parts.size() < 2:
                    print("❌ Invalid one-liner dict at line %d: %s" % [i, entry])
                else:
                    var key = parts[0].strip_edges()
                    var value = _parse_value(parts[1].strip_edges())
                    print("➡️  Key = %s, Value = %s" % [key, str(value)])
                    result[key] = value
        i += 1
    return [result, i]


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
        
        
