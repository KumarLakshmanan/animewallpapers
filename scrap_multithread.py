import os
import json
import requests
from concurrent.futures import ThreadPoolExecutor

headers = {
    'x-nextjs-data': '1',
}
images = []


def process_collection(collection):
    totalItems = collection['count']
    totalItems = int(totalItems)
    perCollectionPage = 50
    totalCollectionRequests = totalItems / perCollectionPage


    if not os.path.exists(iconsPath + collection['slug']):
        os.makedirs(iconsPath + collection['slug'])

    if not os.path.exists(svgPath + collection['slug']):
        os.makedirs(svgPath + collection['slug'])

    for j in range(int(totalCollectionRequests)):
        requestFilePath = iconsPath + collection['slug'] + '/' + str(j + 1) + '.json'
        items = []
        if not os.path.exists(requestFilePath):
            collectionUrl = 'https://www.svgrepo.com/_next/data/9UdWXZJ2dR-D_IkpQGEy7/collection/' + \
                collection['slug']+'/'+str(j + 1)+'.json'
            collectionResponse = requests.get(collectionUrl, headers=headers)
            collectionData = json.loads(collectionResponse.text)
            items = collectionData['pageProps']['items']
            with open(requestFilePath, 'w', encoding='utf-8') as outfile:
                json.dump(items, outfile)
        else:
            with open(requestFilePath, 'r', encoding='utf-8') as infile:
                items = json.load(infile)

        for item in items:
            iconid = item['id']
            iconslug = item['slug']
            svgFilePath = svgPath + collection['slug'] + '/' + str(iconid) + '__' + iconslug + '.svg'
            if os.path.exists(svgFilePath):
                pass
            else:
                iconurl = 'https://www.svgrepo.com/show/' + \
                    str(iconid)+'/'+iconslug+'.svg'
                print(iconurl)
                iconResponse = requests.get(iconurl, headers=headers)
                with open(svgPath + collection['slug'] + '/' + str(iconid) + '__' + iconslug + '.svg', 'wb') as f:
                    f.write(iconResponse.content)


def process_folder(folder):
    with open(collectionPath + folder, 'r', encoding='utf-8') as infile:
        collections = json.load(infile)
        with ThreadPoolExecutor() as executor:
            executor.map(process_collection, collections)


def main():
    global collectionPath, iconsPath, svgPath
    collectionPath = os.getcwd() + '/collections/'
    iconsPath = os.getcwd() + '/icons/'
    svgPath = os.getcwd() + '/svg/'
    if not os.path.exists(iconsPath):
        os.makedirs(iconsPath)
    if not os.path.exists(svgPath):
        os.makedirs(svgPath)
    folders = os.listdir(collectionPath)
    i = len(folders)

    with ThreadPoolExecutor() as executor:
        executor.map(process_folder, folders)


if __name__ == "__main__":
    main()
