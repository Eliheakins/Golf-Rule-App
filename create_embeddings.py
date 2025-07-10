from sentence_transformers import SentenceTransformer
import json

#load json data from flatttened_and_attach_ruleid.py
with open("flattened_golf_rules.json", "r") as f:
    json_data_str = f.read()    

golf_rules = json.loads(json_data_str)

#extract the rule text from the golf_rules
extracted_rules = []
for rule in golf_rules:
    rule_text = rule.get("rule_text", "")
    if rule_text:
        extracted_rules.append(rule_text)

model = SentenceTransformer('sentence-transformers/all-MiniLM-L6-v2')
embeddings = model.encode(extracted_rules, convert_to_tensor=True)

# Save the embeddings to a file along with the associate rule IDs
with open("golf_rule_embeddings.json", "w") as f:
    json.dump({
        "rule_ids": [rule["rule_id"] for rule in golf_rules],
        "embeddings": embeddings.tolist()
    }, f, indent=2)

