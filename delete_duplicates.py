import json
import os

def deduplicate_json_rules(input_file_path, output_file_path=None):
    """
    Reads a JSON file containing a list of rule objects,
    deduplicates them based on the 'rule_id' field, and
    writes the unique rules to a new JSON file.

    Args:
        input_file_path (str): The path to the input JSON file.
        output_file_path (str, optional): The path to the output JSON file.
                                          If None, it will create 'input_file_deduplicated.json'
                                          in the same directory as the input file.
    """
    if not os.path.exists(input_file_path):
        print(f"Error: Input file not found at {input_file_path}")
        return

    print(f"Reading from {input_file_path}...")

    try:
        with open(input_file_path, 'r', encoding='utf-8') as f:
            json_data = json.load(f)
    except json.JSONDecodeError as e:
        print(f"Error decoding JSON from {input_file_path}: {e}")
        return
    except Exception as e:
        print(f"An unexpected error occurred while reading the file: {e}")
        return

    if not isinstance(json_data, list):
        print(f"Error: Expected JSON data to be a list, but got {type(json_data)}")
        return

    unique_rules = []
    seen_rule_ids = set() # Using a set for efficient lookup

    for rule in json_data:
        rule_id = rule.get('rule_id')

        if rule_id is None:
            print(f"Warning: Encountered a rule without a 'rule_id'. Skipping: {rule}")
            continue

        if rule_id not in seen_rule_ids:
            unique_rules.append(rule)
            seen_rule_ids.add(rule_id)
        else:
            print(f"Skipping duplicate rule_id: {rule_id}")

    if output_file_path is None:
        # Construct a default output file name in the same directory
        base, ext = os.path.splitext(input_file_path)
        output_file_path = f"{base}_deduplicated{ext}"

    try:
        with open(output_file_path, 'w', encoding='utf-8') as f:
            json.dump(unique_rules, f, indent=2) # indent=2 for pretty printing
    except Exception as e:
        print(f"An error occurred while writing the output file: {e}")
        return

    print("Deduplication complete.")
    print(f"Total rules in original file: {len(json_data)}")
    print(f"Total unique rules written: {len(unique_rules)}")
    print(f"Total duplicate rules skipped: {len(json_data) - len(unique_rules)}")
    print(f"Deduplicated data written to: {output_file_path}")

if __name__ == "__main__":
    # --- Configuration ---
    # Assuming the JSON file is in the same directory as this script.
    # Just provide the filename directly.
    input_json_file = 'flattened_golf_rules.json'

    # The deduplicated file will be saved in the same directory with '_deduplicated' suffix.
    # For example, if input is 'rules.json', output will be 'rules_deduplicated.json'.
    output_json_file = None 

    # --- Run the deduplication ---
    deduplicate_json_rules(input_json_file, output_json_file)