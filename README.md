Golf Rule Sections App
Project Overview
This is a Ruby on Rails application designed to manage and display golf rule sections in a hierarchical, interactive format. It enables the organization of rules with parent-child relationships, making it easy to navigate complex rule structures. 
Additionally, this application allows for searching of rules us embeddings generated from queries. This allows for an organic way to search for rules.

Features
Hierarchical Rule Display: Organize golf rules with parent and sub-rule sections.

Collapsible UI: Rule sections can be expanded and collapsed to reveal sub-sections and detailed content, powered by Stimulus.js.

Data Import: Includes Rake tasks for importing initial rule data.

Embeddings Generation: Contains Rake tasks for generating vector embeddings of rule content, providing a foundation for semantic search, recommendation, or similarity analysis features.

Technologies Used
Ruby on Rails

Stimulus.js

Tailwind CSS

PostgreSQL

HuggingFace Dedicated Endpoints for hosting of minilm-l6-v2

Upcoming (Potentially):
Language model trained on previous USGA rulings to give an interpretation of the rules. 
