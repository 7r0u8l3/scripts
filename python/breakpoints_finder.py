import requests
from bs4 import BeautifulSoup
import re

def find_css_breakpoints(url):
    try:
        # Fetching the HTML content of the webpage
        response = requests.get(url)
        soup = BeautifulSoup(response.content, 'html.parser')

        # Extracting all CSS file links
        css_links = [link["href"] for link in soup.find_all("link", rel="stylesheet") if "href" in link.attrs]

        breakpoints = set()

        # Regex pattern to find breakpoints in CSS
        breakpoint_pattern = re.compile(r'@media.*?(\d+px)')

        for link in css_links:
            # Handling relative URLs
            if not link.startswith('http'):
                link = url + link

            # Fetching CSS content
            css_response = requests.get(link)
            css_content = css_response.text

            # Finding all breakpoints
            found_breakpoints = breakpoint_pattern.findall(css_content)
            breakpoints.update(found_breakpoints)

        return sorted(list(breakpoints))
    except Exception as e:
        return str(e)

# Example usage
website_url = "https://www.revolt.com/"  # Replace with the URL you want to analyze
css_breakpoints = find_css_breakpoints(website_url)
print(css_breakpoints)

