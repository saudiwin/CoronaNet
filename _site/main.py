from bs4 import BeautifulSoup
import requests
import json

from random import randint
from time import sleep


def json_converter(data):
    return json.dumps(data)


class Scraper:

    def __init__(self, first_page_url, results_number, second_page_url=''):
        self.first_page_url = first_page_url
        self.second_page_url = second_page_url
        self.results_number = results_number

    def nextPageUrlFormer(self):
        return self.second_page_url.split('start=10')

    def pageUrlsFormer(self):
        page_urls = []
        next_page = self.nextPageUrlFormer()
        i = 10
        page_urls.append(self.first_page_url)
        while i < self.results_number:
            next_page_url = \
                next_page[0] + \
                'start=' + \
                str(i) + \
                next_page[1]
            page_urls.append(next_page_url)
            i += 10
        return page_urls

    def scrape(self):

        data_dict = {}
        counter = 0

        for url in self.pageUrlsFormer():

            page_to_scrape = requests.get(url)

            soup = BeautifulSoup(page_to_scrape.text, 'html.parser')

            titles = soup.findAll('h3', attrs={'class': 'gs_rt'})
            descriptions = soup.findAll('div', attrs={'class': 'gs_rs'})

            for title, description in zip(titles, descriptions):
                for anchor in title.findAll('a'):
                    data_dict[counter] = {
                        "title": title.text,
                        "link": anchor.get('href'),
                        "description": description.text
                    }
                    counter += 1

            sleep(randint(10, 30))

        with open('view/articles.json', 'a') as file:
            file.write(json_converter(data_dict))


scholar_scraper = Scraper('https://scholar.google.com/scholar?cites=10743304333126100346&as_sdt=2005&sciodt=0,5&hl=en',
                          420,
                          'https://scholar.google.com/scholar?start=10&hl=en&as_sdt=2005&sciodt=0,5&cites=10743304333126100346&scipsc=')
scholar_scraper.scrape()