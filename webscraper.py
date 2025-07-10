import requests
from bs4 import BeautifulSoup
import json
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager
import time

def fetch_html_with_selenium(url, wait_time=5):
    """
    Fetches the HTML content from the given URL using Selenium, allowing JavaScript to render.
    Args:
        url (str): The URL of the webpage to fetch.
        wait_time (int): Seconds to wait for page to load and content to render.
    Returns:
        str: The fully rendered HTML content of the webpage, or None if an error occurs.
    """
    chrome_options = Options()
    chrome_options.add_argument("--headless") # Run in headless mode (no visible browser UI)
    chrome_options.add_argument("--disable-gpu") # Recommended for headless mode
    chrome_options.add_argument("--no-sandbox") # Recommended for headless mode
    chrome_options.add_argument("--window-size=1920,1080") # Set a common window size

    # Set up the Chrome driver
    service = Service(ChromeDriverManager().install())
    driver = webdriver.Chrome(service=service, options=chrome_options)

    try:
        print(f"Fetching {url}...")
        driver.get(url)
        # Give the page some time to load all its JavaScript-rendered content
        time.sleep(wait_time)
        html_content = driver.page_source
        return html_content
    except Exception as e:
        print(f"Error fetching URL {url} with Selenium: {e}")
        return None
    finally:
        driver.quit() # Always close the browser

def parse_rules_to_json(html_doc, url): # Added url argument for context
    """
    Parses the HTML document and extracts golf rules into a structured JSON format.
    Args:
        html_doc (str): The HTML content as a string.
        url (str): The URL from which the HTML was scraped, for context in error messages.
    Returns:
        dict: A dictionary containing the parsed rules, or None if parsing fails.
    """
    if not html_doc:
        print(f"No HTML document provided for parsing from {url}")
        return None

    soup = BeautifulSoup(html_doc, 'html.parser')
    rules_data = {}

    # Extract the main rule title
    main_rule_title_tag = soup.find('h1')
    if main_rule_title_tag:
        rules_data['main_rule_title'] = main_rule_title_tag.get_text(strip=True)
    else:
        print(f"Warning: Main rule title not found for {url}")

    # Extract purpose of the rule
    purpose_section = soup.find('div', class_='rule-purpose')
    if purpose_section:
        rules_data['purpose_of_rule'] = []
        purpose_paragraphs = purpose_section.find_all('p', recursive=False)
        for p in purpose_paragraphs:
            rules_data['purpose_of_rule'].append(p.get_text(strip=True))

        purpose_list_items = purpose_section.find('ul', class_='unorderedlists')
        if purpose_list_items:
            rules_data['purpose_of_rule_points'] = [li.get_text(strip=True) for li in purpose_list_items.find_all('li')]
    else:
        print(f"Warning: Purpose section not found for {url}")


    # Extract sub-rules
    rules_data['sub_rules'] = []
    sub_rule_sections = soup.find_all('section', class_='sub-rule')

    if not sub_rule_sections:
        print(f"Warning: No 'sub-rule' sections found for {url}")


    for sub_rule_section in sub_rule_sections:
        sub_rule = {}
        sub_rule_title_tag = sub_rule_section.find('h2')
        if sub_rule_title_tag:
            sub_rule['title'] = sub_rule_title_tag.get_text(strip=True)
        else:
            print(f"Warning: Sub-rule title (h2) not found in a section for {url}")


        current_content = []
        for element in sub_rule_section.children:
            if element.name == 'p':
                current_content.append(element.get_text(strip=True))
            elif element.name == 'ul' and 'unorderedlists' in element.get('class', []):
                if 'points' not in sub_rule:
                    sub_rule['points'] = []
                sub_rule['points'].extend([li.get_text(strip=True) for li in element.find_all('li')])

        if current_content:
            sub_rule['content'] = current_content


        # Extract sub-sub-rules
        sub_rule['sub_sections'] = []
        sub_sub_rule_sections = sub_rule_section.find_all('section', class_='sub-sub-rule')
        for sub_sub_rule_section in sub_sub_rule_sections:
            sub_sub_rule = {}
            sub_sub_rule_title_tag = sub_sub_rule_section.find('h3')
            if sub_sub_rule_title_tag:
                sub_sub_rule['title'] = sub_sub_rule_title_tag.get_text(strip=True)
            else:
                print(f"Warning: Sub-sub-rule title (h3) not found in a section for {url}")


            current_sub_sub_content = []
            for element in sub_sub_rule_section.children:
                if element.name == 'p':
                    current_sub_sub_content.append(element.get_text(strip=True))
                elif element.name == 'ul' and 'unorderedlists' in element.get('class', []):
                    if 'points' not in sub_sub_rule:
                        sub_sub_rule['points'] = []
                    sub_sub_rule['points'].extend([li.get_text(strip=True) for li in element.find_all('li')])

            if current_sub_sub_content:
                sub_sub_rule['content'] = current_sub_sub_content


            # Extract sub-sub-sub-rules
            sub_sub_rule['sub_sections'] = []
            sub_sub_sub_rule_sections = sub_sub_rule_section.find_all('section', class_='sub-sub-sub-rule')
            for sub_sub_sub_rule_section in sub_sub_sub_rule_sections:
                sub_sub_sub_rule = {}
                sub_sub_sub_rule_title_tag = sub_sub_sub_rule_section.find('h4')
                if sub_sub_sub_rule_title_tag:
                    sub_sub_sub_rule['title'] = sub_sub_sub_rule_title_tag.get_text(strip=True)
                else:
                    print(f"Warning: Sub-sub-sub-rule title (h4) not found in a section for {url}")

                current_sub_sub_sub_content = []
                for element in sub_sub_sub_rule_section.children:
                    if element.name == 'p':
                        current_sub_sub_sub_content.append(element.get_text(strip=True))
                    elif element.name == 'ul' and 'unorderedlists' in element.get('class', []):
                        if 'points' not in sub_sub_sub_rule:
                            sub_sub_sub_rule['points'] = []
                        sub_sub_sub_rule['points'].extend([li.get_text(strip=True) for li in element.find_all('li')])

                if current_sub_sub_sub_content:
                    sub_sub_sub_rule['content'] = current_sub_sub_sub_content

                sub_sub_rule['sub_sections'].append(sub_sub_sub_rule)

            sub_rule['sub_sections'].append(sub_sub_rule)

        rules_data['sub_rules'].append(sub_rule)

    # Add the URL to the data for context
    rules_data['source_url'] = url
    return rules_data

def save_to_json(data, filename):
    """
    Saves the given data to a JSON file.
    Args:
        data (list or dict): The data (list of dictionaries for multiple rules) to save.
        filename (str): The name of the JSON file.
    """
    try:
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=4)
        print(f"All data successfully saved to {filename}")
    except IOError as e:
        print(f"Error saving to file {filename}: {e}")

if __name__ == "__main__":
    urls_to_scrape = [
        "https://www.usga.org/rules/rules-and-clarifications/rules-and-clarifications.html#section=rules&itemNum=4",
        "https://www.usga.org/rules/rules-and-clarifications/rules-and-clarifications.html#section=rules&itemNum=5",
        "https://www.usga.org/rules/rules-and-clarifications/rules-and-clarifications.html#section=rules&itemNum=6",
        "https://www.usga.org/rules/rules-and-clarifications/rules-and-clarifications.html#section=rules&itemNum=7",
        "https://www.usga.org/rules/rules-and-clarifications/rules-and-clarifications.html#section=rules&itemNum=8",
        "https://www.usga.org/rules/rules-and-clarifications/rules-and-clarifications.html#section=rules&itemNum=9",
        "https://www.usga.org/rules/rules-and-clarifications/rules-and-clarifications.html#section=rules&itemNum=10",
        "https://www.usga.org/rules/rules-and-clarifications/rules-and-clarifications.html#section=rules&itemNum=11",
        "https://www.usga.org/rules/rules-and-clarifications/rules-and-clarifications.html#section=rules&itemNum=12",
        "https://www.usga.org/rules/rules-and-clarifications/rules-and-clarifications.html#section=rules&itemNum=13",
        "https://www.usga.org/rules/rules-and-clarifications/rules-and-clarifications.html#section=rules&itemNum=14",
        "https://www.usga.org/rules/rules-and-clarifications/rules-and-clarifications.html#section=rules&itemNum=15",
        "https://www.usga.org/rules/rules-and-clarifications/rules-and-clarifications.html#section=rules&itemNum=16",
        "https://www.usga.org/rules/rules-and-clarifications/rules-and-clarifications.html#section=rules&itemNum=17",
        "https://www.usga.org/rules/rules-and-clarifications/rules-and-clarifications.html#section=rules&itemNum=18",
        "https://www.usga.org/rules/rules-and-clarifications/rules-and-clarifications.html#section=rules&itemNum=19",
        "https://www.usga.org/rules/rules-and-clarifications/rules-and-clarifications.html#section=rules&itemNum=20",
        "https://www.usga.org/rules/rules-and-clarifications/rules-and-clarifications.html#section=rules&itemNum=21",
        "https://www.usga.org/rules/rules-and-clarifications/rules-and-clarifications.html#section=rules&itemNum=22",
        "https://www.usga.org/rules/rules-and-clarifications/rules-and-clarifications.html#section=rules&itemNum=23",
        "https://www.usga.org/rules/rules-and-clarifications/rules-and-clarifications.html#section=rules&itemNum=24",
        "https://www.usga.org/rules/rules-and-clarifications/rules-and-clarifications.html#section=rules&itemNum=25",
        "https://www.usga.org/rules/rules-and-clarifications/rules-and-clarifications.html#section=rules&itemNum=26",
        "https://www.usga.org/rules/rules-and-clarifications/rules-and-clarifications.html#section=rules&itemNum=27",
        "https://www.usga.org/rules/rules-and-clarifications/rules-and-clarifications.html#section=rules&itemNum=28"
    ] 

    all_parsed_data = [] # This list will hold data for all rules

    for url in urls_to_scrape:
        html_content = fetch_html_with_selenium(url, wait_time=3)

        if html_content:
            parsed_rule = parse_rules_to_json(html_content, url)
            if parsed_rule:
                all_parsed_data.append(parsed_rule)
                print(f"Successfully parsed data from {url}")
            else:
                print(f"Skipping {url} due to parsing failure.")
        else:
            print(f"Skipping {url} due to HTML fetch failure.")

    if all_parsed_data:
        save_to_json(all_parsed_data, "golf_rules_all.json")
    else:
        print("No data was successfully parsed from any of the URLs.")