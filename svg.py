import os
import json
import requests
import concurrent.futures
import time

headers = {
    'x-nextjs-data': '1',
}
images = []


def download_collection(url, collection_path):
    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        data = json.loads(response.text)
        collections = data['pageProps']['results']['collections']
        with open(collection_path, 'w', encoding='utf-8') as outfile:
            json.dump(collections, outfile)
    except requests.exceptions.RequestException as e:
        print(f"Error downloading collection from {url}: {e}")


def download_icon(collection, icons_path, svg_path):
    try:
        total_items = collection['count']
        total_items = int(total_items)
        per_collection_page = 50
        total_collection_requests = total_items / per_collection_page

        # Move directory creation outside the inner loop
        if not os.path.exists(icons_path + collection['slug']):
            os.makedirs(icons_path + collection['slug'])

        if not os.path.exists(svg_path + collection['slug']):
            os.makedirs(svg_path + collection['slug'])

        for j in range(int(total_collection_requests)):
            collection_url = 'https://www.svgrepo.com/_next/data/9UdWXZJ2dR-D_IkpQGEy7/collection/' + \
                collection['slug']+'/'+str(j + 1)+'.json'
            print(collection_url)
            try:
                collection_response = requests.get(
                    collection_url, headers=headers)
                collection_response.raise_for_status()
                collection_data = json.loads(collection_response.text)
                items = collection_data['pageProps']['results']['icons']

                with open(icons_path + collection['slug'] + '/' + str(j + 1) + '.json', 'w', encoding='utf-8') as outfile:
                    json.dump(items, outfile)

                for item in items:
                    iconid = item['id']
                    iconslug = item['slug']
                    iconurl = 'https://www.svgrepo.com/show/' + \
                        str(iconid)+'/'+iconslug+'.svg'
                    print(iconurl)
                    try:
                        icon_response = requests.get(
                            iconurl, headers=headers)
                        icon_response.raise_for_status()
                        with open(svg_path + collection['slug'] + '/' + str(iconid) + '__' + iconslug + '.svg', 'wb') as f:
                            f.write(icon_response.content)
                    except requests.exceptions.RequestException as icon_error:
                        print(f"Error downloading icon from {iconurl}: {icon_error}")
            except requests.exceptions.RequestException as collection_error:
                print(f"Error downloading collection from {collection_url}: {collection_error}")
    except ValueError as value_error:
        print(f"Error processing collection: {value_error}")


def main():
    total_collections = 1542
    per_page = 12
    total_requests = total_collections / per_page
    collection_path = os.getcwd() + '/collections/'
    icons_path = os.getcwd() + '/icons/'
    svg_path = os.getcwd() + '/svg/'
    if not os.path.exists(collection_path):
        os.makedirs(collection_path)
    if not os.path.exists(icons_path):
        os.makedirs(icons_path)
    if not os.path.exists(svg_path):
        os.makedirs(svg_path)

    with concurrent.futures.ThreadPoolExecutor() as executor:
        futures = []
        for i in range(int(total_requests)):
            url = 'https://www.svgrepo.com/_next/data/9UdWXZJ2dR-D_IkpQGEy7/collections/all/' + \
                str(i + 1) + '.json'
            print(url)
            collection_path_threaded = collection_path + str(i + 1) + '.json'
            futures.append(executor.submit(download_collection, url, collection_path_threaded))

        concurrent.futures.wait(futures)

        for future in futures:
            if future.exception():
                print(f"Error: {future.exception()}")

    with concurrent.futures.ThreadPoolExecutor() as executor:
        futures = []
        for i in range(int(total_requests)):
            with open(collection_path + str(i + 1) + '.json', 'r', encoding='utf-8') as infile:
                collections = json.load(infile)
                for collection in collections:
                    icons_path_threaded = icons_path + collection['slug'] + '/'
                    svg_path_threaded = svg_path + collection['slug'] + '/'
                    futures.append(executor.submit(download_icon, collection, icons_path_threaded, svg_path_threaded))

        concurrent.futures.wait(futures)

        for future in futures:
            if future.exception():
                print(f"Error: {future.exception()}")


if __name__ == "__main__":
    start_time = time.time()
    main()
    print(f"Execution time: {time.time() - start_time} seconds")
