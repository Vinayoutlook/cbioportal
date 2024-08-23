import time

import boto3
from selenium.webdriver.common.by import By
from aws_synthetics.selenium import synthetics_webdriver as syn_webdriver
from aws_synthetics.common import synthetics_logger as logger
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
TIMEOUT = 60  # Seconds
SLEEPTIME = 10  # Seconds

def get_url():
    account_name_val = get_secrets("account_name")
    if account_name_val == "dpp":
        account_val = "data"
    else:
        account_val = "npdata"
    return f"https://ecbio.{account_val}.guardanthealth.com/"


def get_secrets(secret_name):
    secret_value = ""
    client = boto3.client('secretsmanager')
    try:
        secret_value = client.get_secret_value(SecretId=secret_name)['SecretString']
    except:
        print("An exception occurred")
    finally:
        return secret_value


def ecbio_sanity():
    username_ele = (By.XPATH,"//input[@name='identifier']")
    password_ele = (By.XPATH,"//input[@name='credentials.passcode']")
    login_ele = (By.XPATH,"//input[@value='Sign in']")

    # Get the URL based on the account_name
    url = get_url()

    # Set screenshot option
    takeScreenshot = True

    browser = syn_webdriver.Chrome()
    browser.implicitly_wait(TIMEOUT)
    browser.get(url)

    # Enter username and password
    WebDriverWait(browser, TIMEOUT).until(EC.visibility_of_element_located(username_ele)).send_keys(get_secrets("deployment_sa_user"))
    WebDriverWait(browser, TIMEOUT).until(EC.visibility_of_element_located(password_ele)).send_keys(get_secrets("deployment_sa_password"))
    WebDriverWait(browser, TIMEOUT).until(EC.visibility_of_element_located(login_ele)).click()
    time.sleep(SLEEPTIME)

    response_code = syn_webdriver.get_http_response(url)
    if not response_code or response_code < 200 or response_code > 299:
        raise Exception("Failed to load page!")

    logger.info("Canary successfully executed.")

    if takeScreenshot:
        browser.save_screenshot("loaded.png")


def handler(event, context):
    # user defined log statements using synthetics_logger
    logger.info("Selenium Python heartbeat canary.")
    return ecbio_sanity()
