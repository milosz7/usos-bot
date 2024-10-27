import bs4
import requests
from langchain_community.document_loaders import WebBaseLoader
from langchain_core.documents.base import Document
from langchain.document_loaders import OnlinePDFLoader
import re
from tqdm import tqdm


class USOSDataLoader:
    def __init__(self):
        self.base_url = "https://usosownia.uj.edu.pl"
        self.usosweb_url = "https://usosownia.uj.edu.pl/usosweb"
        self.usos_url = "https://usosownia.uj.edu.pl/usos"

    def _fetch_links(self, url, urls_list, depth=0):
        min_depth = 0
        if depth > min_depth:
            urls_list.append(url)
        only_links = bs4.SoupStrainer(class_="link-box__wrapper")
        response = requests.get(url)
        if response.status_code == 200:
            raw_data = response.text
            link_boxes = bs4.BeautifulSoup(raw_data, parse_only=only_links, features="lxml")
            found_paths = [link.get("href") for link in link_boxes.find_all("a")]
            urls = [f"{self.base_url}{path}" for path in found_paths]
            for link in urls:
                self._fetch_links(link, urls_list, depth + 1)

        return urls_list

    def _find_pdf_links(self, urls):
        pdf_links = []

        for url in tqdm(urls, desc="Fetching pdf links..."):
            only_pdfs = bs4.SoupStrainer(class_="pdf")

            response = requests.get(url)
            if response.status_code == 200:
                raw_data = response.text
                link_boxes = bs4.BeautifulSoup(raw_data, parse_only=only_pdfs, features="lxml")
                link_boxes = [link for link in link_boxes if not isinstance(link, bs4.Doctype)]

                found_paths = [
                    self.base_url + link.get("href") if link.get("href").startswith("/documents") else link.get("href") for
                    link
                    in link_boxes]

                for path in found_paths:
                    response = requests.get(path)
                    # if we didn't reach our path after get we don't have permissions
                    if response.url == path:
                        pdf_links.append(path)

        return pdf_links

    @staticmethod
    def _load_web_data(urls: list[str]) -> list[Document]:
        print("Loading web data...")
        loader = WebBaseLoader(
            web_paths=urls,
            bs_kwargs=dict(
                parse_only=bs4.SoupStrainer("article")
            )
        )

        return loader.load()

    @staticmethod
    def _load_pdf_data(urls: list[str]) -> list[Document]:
        loaded_docs = []
        for url in tqdm(urls, desc="Loading pdf data..."):
            loader = OnlinePDFLoader(url)
            docs = loader.load()
            for doc in docs:
                doc.metadata["source"] = url
            loaded_docs += docs

        return loaded_docs

    @staticmethod
    def _cleanup_text(text):
        text = text.replace("\n", " ")
        text = text.replace("\t", " ")
        text = text.replace("\xa0", " ")
        text = re.sub(r"\s+", " ", text)
        return text

    def get_documents(self) -> list[Document]:
        print("Fetching links...")
        urls = self._fetch_links(self.usos_url, [])
        urls += self._fetch_links(self.usosweb_url, [])
        pdf_links = self._find_pdf_links(urls)

        documents = self._load_web_data(urls)
        documents += self._load_pdf_data(pdf_links)

        for doc in tqdm(documents, desc="Preprocessing documents..."):
            doc.page_content = self._cleanup_text(doc.page_content)

        return documents
