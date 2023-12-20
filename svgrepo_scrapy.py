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
    for i in range(int(totalRequests)):
        url = 'https://www.svgrepo.com/_next/data/9UdWXZJ2dR-D_IkpQGEy7/collections/all/' + \
            str(i + 1) + '.json'
        print(url)
        response = requests.get(url, headers=headers)
        data = json.loads(response.text)
        collections = data['pageProps']['results']['collections']
        with open(collectionPath + str(i + 1) + '.json', 'w', encoding='utf-8') as outfile:
            json.dump(collections, outfile)

        for collection in collections:
            totalItems = collection['count']
            totalItems = int(totalItems)
            perCollectionPage = 50
            totalCollectionRequests = totalItems / perCollectionPage
            for j in range(int(totalCollectionRequests)):
                collectionUrl = 'https://www.svgrepo.com/_next/data/9UdWXZJ2dR-D_IkpQGEy7/collection/' + \
                    collection['slug']+'/'+str(j + 1)+'.json'
                print(collectionUrl)
                collectionResponse = requests.get(
                    collectionUrl, headers=headers)
                collectionData = json.loads(collectionResponse.text)
                items = collectionData['pageProps']['results']['icons']
                if not os.path.exists(iconsPath + collection['slug']):
                    os.makedirs(iconsPath + collection['slug'])

                if not os.path.exists(svgPath + collection['slug']):
                    os.makedirs(svgPath + collection['slug'])

                with open(iconsPath + collection['slug'] + '/' + str(j + 1) + '.json', 'w', encoding='utf-8') as outfile:
                    json.dump(items, outfile)

                for item in items:
                    iconid = item['id']
                    iconslug = item['slug']
                    iconurl = 'https://www.svgrepo.com/show/' + \
                        str(iconid)+'/'+iconslug+'.svg'
                    print(iconurl)
                    iconResponse = requests.get(iconurl, headers=headers)
                    with open(svgPath + collection['slug'] + '/' + str(iconid) + '__' + iconslug + '.svg', 'wb') as f:
                        f.write(iconResponse.content)


if __name__ == "__main__":
    main()
