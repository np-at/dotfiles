#!/usr/bin/env python3

# selenium 4
# from selenium.webdriver.chrome.service import Service as ChromeService
# from selenium.webdriver.chrome.options import Options as ChromeOptions
import os

from webdriver_manager.chrome import ChromeDriverManager
from webdriver_manager.core.utils import ChromeType

# from selenium.webdriver import Chrome


def link(src, dst):
    try:
        os.symlink(src, dst)
    except FileExistsError:
        pass


executable_path = ChromeDriverManager().install()
link(executable_path, "/usr/local/bin/chromedriver")

executable_path = ChromeDriverManager(chrome_type=ChromeType.CHROMIUM).install()
link(executable_path, "/usr/local/bin/chromiumdriver")


from webdriver_manager.firefox import GeckoDriverManager

executable_path = GeckoDriverManager().install()
link(executable_path, "/usr/local/bin/geckodriver")

# service = ChromeService(executable_path=executable_path)
# driver = Chrome(service=service)
# print(executable_path)
# print(driver.capabilities)
