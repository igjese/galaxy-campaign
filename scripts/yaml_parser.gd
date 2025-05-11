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

    print(result)
    return result


func parse_simple_yaml(text: String) -> Variant:
    var lines = []
    for raw in text.split("\n", false):
        var trimmed = raw.strip_edges(false)
        if trimmed == "" or trimmed.begins_with("#"):
            continue
        lines.append(trimmed)
    return parse_lines(lines)[0]
    

func parse_lines(lines: Array,  start: int = 0, current_indent: int = 0):
    var result = null
    var i = start
    
    var mode = null
    while i < lines.size():
        var raw_line = lines[i]
        var indent = raw_line.length() - raw_line.lstrip(" ").length()
        if indent < current_indent:
            break
        var entry = raw_line.strip_edges()
        
        # pattern match: '-key:' etc
        if entry.begins_with("- "):
            var item = entry.substr(2)     
            if mode == null:
                mode = "list"
                result = []
            elif mode != "list":
                print("Expected list item at line %d" % i)
                
            if not item.ends_with(":"):
                result.append(_parse_value(item))
            else:
                var key = item.left(item.length()-1)
                var subresult = {}
                var parse_result = parse_lines(lines, i+1, current_indent + INDENT_UNIT)
                subresult[key] = parse_result[0]
                i = parse_result[1]
                result.append(subresult)
        i += 1
    return [result, i]


func _parse_structured(lines: Array, current_indent: int, start_idx: int) -> Variant:
    var result = null
    var mode = null
    var i = start_idx

    while i < lines.size():
        var entry = lines[i]
        var indent = entry["indent"]
        var text = entry["text"]

        if indent < current_indent:
            break  # End of this block

        print("🔍 Line %d (indent %d): %s" % [i, indent, text])

        # ---- LIST ITEM ----
        if text.begins_with("- "):
            var item_text = text.substr(2).strip_edges()
            print("📌 Detected list item: %s" % item_text)

            if mode == null:
                mode = "list"
                result = []
            elif mode != "list":
                print("❌ YAML Error: Mixed dict/list at line %d: %s" % [i, text])
                return {}

            if not item_text.ends_with(":"):
                print("❌ YAML Error: List item must be in '- key:' form (no inline value) at line %d: %s" % [i, text])
                return {}

            var key = item_text.substr(0, item_text.length() - 1).strip_edges()

            # Gather nested block
            # Also include lines at the same indent if they’re part of the same logical list block
            var nested_lines = []
            var j = i + 1
            while j < lines.size():
                var next_indent = lines[j]["indent"]
                if next_indent < indent:
                    break
                if next_indent == indent and lines[j]["text"].begins_with("- "):
                    break  # new list item starts
                nested_lines.append(lines[j])
                j += 1


            var nested = _parse_structured(nested_lines, indent, 0)
            result.append({key: nested})
            i = j - 1

        # ---- DICT ENTRY ----
        elif ":" in text:
            var parts = text.split(":", false, 2)
            var key = parts[0].strip_edges()
            var value = parts[1].strip_edges() if parts.size() > 1 else ""
            print("🧱 Dict entry: key = %s, value = %s" % [key, value])

            if mode == null:
                mode = "dict"
                result = {}
            elif mode != "dict":
                print("❌ YAML Error: Mixed dict/list at line %d: %s" % [i, text])
                return {}

            if value == "":
                print("↪️  Opening nested block under key '%s'" % key)
                var nested_lines = []
                var j = i + 1
                while j < lines.size() and lines[j]["indent"] > indent:
                    nested_lines.append(lines[j])
                    j += 1

                var nested = _parse_structured(nested_lines, indent + 1, 0)
                result[key] = nested
                i = j - 1
            else:
                result[key] = _parse_value(value)

        else:
            print("❓ YAML Error: Unrecognized line at %d: %s" % [i, text])

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
        
        
func _advance_to_same_indent(lines: Array, indent: int, start: int) -> int:
    for i in range(start + 1, lines.size()):
        if lines[i]["indent"] <= indent:
            return i - 1
    return lines.size() - 1
