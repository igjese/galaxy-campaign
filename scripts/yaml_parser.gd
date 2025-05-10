extends Node

'''
Simplified YAML parser, which supports:
- Top-level dictionaries (like goal: seek_and_destroy)
- Top-level lists of dictionaries (like your combat_rules.yaml)
- Nested lists and scalars
- Basic types (int, float, bool, string)
- Simple indentation-based structure (4 spaces because godot editor)
'''

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
        var trimmed = raw.strip_edges()
        if trimmed == "" or trimmed.begins_with("#"):
            continue
        var indent = raw.length() - raw.lstrip(" ").length()
        if indent % 4 != 0:
            print("YAML error: indent not multiple of 4")
            continue
        lines.append({
            "indent": indent / 4,
            "text": trimmed
        })
    return _parse_structured(lines, 0, 0)

func _parse_structured(lines: Array, current_indent: int, start_idx: int) -> Variant:
    var result = null
    var mode = null
    var i = start_idx

    while i < lines.size():
        var entry = lines[i]
        var indent = entry["indent"]
        var text = entry["text"]

        if indent < current_indent:
            print("⤴️  End of block at indent %d (line %d: %s)" % [current_indent, i, text])
            break

        print("🔍 Line %d (indent %d): %s" % [i, indent, text])

        # ---- LIST ITEM ----
        if text.begins_with("- "):
            var item_text = text.substr(2).strip_edges()
            print("📌 Detected list item: ", item_text)

            if mode == null:
                mode = "list"
                result = []
            elif mode != "list":
                print("❌ YAML Error: Mixed list/dict at line %d: %s" % [i, text])
                return {}

            if ":" in item_text:
                var parts = item_text.split(":", false, 2)
                var key = parts[0].strip_edges()
                var value = parts[1].strip_edges() if parts.size() > 1 else ""
                print("🗂️  Interpreting as dict: key = %s, value = %s" % [key, value])

                if value == "":
                    print("↪️  Opening nested block under key '%s'" % key)
                    var sub = _parse_structured(lines, current_indent, i + 1)
                    result.append({key: sub})
                    i = _advance_to_same_indent(lines, current_indent, i)
                else:
                    var item_lines = [ { "indent": indent, "text": item_text } ]

                    # Collect all lines that belong to this list item
                    var j = i + 1
                    while j < lines.size() and lines[j]["indent"] >= indent:
                        item_lines.append(lines[j])
                        j += 1

                    # Parse the whole list item as a dict
                    var parsed_item = _parse_structured(item_lines, indent, 0)
                    result.append(parsed_item)

                    i = j - 1  # move to end of this block

            else:
                print("📦 List scalar: ", item_text)
                result.append(_parse_value(item_text))

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
                var sub = _parse_structured(lines, current_indent, i + 1)
                result[key] = sub
                i = _advance_to_same_indent(lines, current_indent, i)
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
