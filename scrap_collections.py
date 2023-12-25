import os
import json
import requests

headers = {
    'x-nextjs-data': '1',
}
images = []


def main():
    collectionPath = os.getcwd() + '/collections/'
    iconsPath = os.getcwd() + '/icons/'
    svgPath = os.getcwd() + '/svg/'
    if not os.path.exists(iconsPath):
        os.makedirs(iconsPath)
    if not os.path.exists(svgPath):
        os.makedirs(svgPath)
    folders = os.listdir(collectionPath)
    i = len(folders)
    for folder in folders:
        with open(collectionPath + folder, 'r', encoding='utf-8') as infile:
            collections = json.load(infile)
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
                    requestFilePath = iconsPath + collection['slug'] + '/' + str(j + 1) + '.json'
                    if os.path.exists(requestFilePath):
                        pass
                    else:
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
