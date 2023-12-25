import os
import json
import requests

headers = {
    'x-nextjs-data': '1',
}
images = []


def main():
    totalCollections = 1542
    perPage = 12
    totalRequests = totalCollections / perPage
    collectionPath = os.getcwd() + '/collections/'
    iconsPath = os.getcwd() + '/icons/'
    svgPath = os.getcwd() + '/svg/'
    if not os.path.exists(collectionPath):
        os.makedirs(collectionPath)
    if not os.path.exists(iconsPath):
        os.makedirs(iconsPath)
    if not os.path.exists(svgPath):
        os.makedirs(svgPath)
    i = 0
    while True:
        url = 'https://www.svgrepo.com/_next/data/9UdWXZJ2dR-D_IkpQGEy7/collections/all/' + \
            str(i + 1) + '.json'
        print(url)
        response = requests.get(url, headers=headers)
        data = json.loads(response.text)
        collections = data['pageProps']['results']['collections']
        if (len(collections) == 0):
            break
        with open(collectionPath + str(i + 1) + '.json', 'w', encoding='utf-8') as outfile:
            json.dump(collections, outfile)
        i = i + 1
if __name__ == "__main__":
    main()
