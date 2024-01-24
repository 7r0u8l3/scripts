import requests
from bs4 import BeautifulSoup
import os

def extract_css_from_website(url):
    try:
        # Create a directory to store the CSS files
        if not os.path.exists('css_files'):
            os.makedirs('css_files')

        # Fetch the HTML content of the webpage
        response = requests.get(url)
        soup = BeautifulSoup(response.content, 'html.parser')

        # Extracting all CSS file links
        css_links = [link["href"] for link in soup.find_all("link", rel="stylesheet") if "href" in link.attrs]

        for index, link in enumerate(css_links):
            # Handling relative URLs
            if not link.startswith('http'):
                link = url + link

            # Fetching CSS content
            css_response = requests.get(link)
            css_content = css_response.text

            # Saving CSS content to a file
            with open(f'css_files/css_file_{index}.css', 'w') as file:
                file.write(css_content)

        print(f"Extracted {len(css_links)} CSS files.")
    except Exception as e:
        print(f"An error occurred: {e}")

# Example usage
website_url = "https://www.revolt.com/"  # Replace with the URL you want to extract CSS from
extract_css_from_website(website_url)
