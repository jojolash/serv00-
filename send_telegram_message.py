import requests
import os

def send_telegram_message(message):
    url = f'https://api.telegram.org/bot{os.getenv("TELEGRAM_BOT_TOKEN")}/sendMessage'
    payload = {
        'chat_id': os.getenv('TELEGRAM_CHAT_ID'),
        'text': message,
        'parse_mode': 'Markdown'
    }
    headers = {'Content-Type': 'application/json'}
    response = requests.post(url, json=payload, headers=headers)
    if response.status_code != 200:
        raise ValueError(f'Error: {response.status_code} {response.text}')

if __name__ == '__main__':
    with open('ssh_output.txt', 'r') as file:
        message = file.read()
    send_telegram_message(message)
