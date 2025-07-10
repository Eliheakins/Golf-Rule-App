import json
import re

with open("golf_rules_all.json", "r") as f:
    json_data_str = f.read()

golf_rules = json.loads(json_data_str)

extracted_rules = []

def extract_prefix(title):
    # Try to extract "X" from "Rule X - ..."
    match = re.match(r"Rule (\d+)", title)
    if match:
        return match.group(1)
    # Try to extract "X.Y" or just "Y" from "X.YTitle"
    match = re.match(r"\d+\.(\d+)", title)
    if match:
        return match.group(1)
    # Try to extract "a" from "a. Title"
    match = re.match(r"([a-z])\.", title)
    if match:
        return match.group(1)
    # Try to extract "1" from "(1)Title"
    match = re.match(r"\((\d+)\)", title)
    if match:
        return match.group(1)
    return None

def traverse_rules(rules_list, current_id_prefix="", base_url=""):
    for item in rules_list:
        rule_id_part = None
        rule_title_text = None
        rule_content_text = ""

        # Determine the current title field and extract rule_id part
        if "main_rule_title" in item:
            rule_title_text = item["main_rule_title"]
            match = re.match(r"Rule (\d+)", rule_title_text)
            if match:
                rule_id_part = match.group(1)
            # Combine purpose_of_rule and purpose_of_rule_points for main rule text
            if "purpose_of_rule" in item:
                rule_content_text += " ".join(item["purpose_of_rule"]) + "\n"
            if "purpose_of_rule_points" in item:
                rule_content_text += " ".join(item["purpose_of_rule_points"]) + "\n"
            official_url = item.get("source_url", base_url) # Use main rule's source_url
        elif "title" in item:
            rule_title_text = item["title"]
            rule_id_part = extract_prefix(rule_title_text)
            official_url = base_url # Sub-rules inherit parent's URL if not explicitly defined

        # Construct current rule_id
        current_full_id = f"{current_id_prefix}_{rule_id_part}" if current_id_prefix and rule_id_part else rule_id_part if rule_id_part else current_id_prefix

        # Combine content and points for rule_text
        if "content" in item:
            rule_content_text += " ".join(item["content"]) + "\n"
        if "points" in item:
            rule_content_text += " ".join(item["points"]) + "\n"

        # Only add to extracted_rules if we successfully derived a rule_id and there's content/title
        if current_full_id and rule_title_text and rule_content_text.strip():
            extracted_rules.append({
                "rule_id": current_full_id.strip("_"), # Remove leading/trailing underscores
                "rule_title": rule_title_text.strip(),
                "rule_text": rule_content_text.strip(),
                "official_url": official_url
            })

        # Recursively call for sub_rules or sub_sections
        if "sub_rules" in item:
            traverse_rules(item["sub_rules"], current_full_id, official_url)
        if "sub_sections" in item:
            traverse_rules(item["sub_sections"], current_full_id, official_url)

# Start traversing the rules from the top level
traverse_rules(golf_rules)

# Output the extracted rules as JSON
output_json = json.dumps(extracted_rules, indent=2) 

#save the output to a file
with open("flattened_golf_rules.json", "w") as f:
    f.write(output_json)    