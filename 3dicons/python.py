import os
import mysql.connector


def mainFunction():

    mydb = mysql.connector.connect(
        host="217.21.85.149",
        user="u707479837_svgrepo",
        password="Uf9g!&0wP",
        database="u707479837_svgrepo"
    )

    cursor = mydb.cursor()
    mydb.commit()

    imagesPath = os.path.join(os.getcwd(), 'resized')
    print(imagesPath)
    listImages = os.listdir(imagesPath)
    print(listImages)
    for singleimage in listImages:
        print(singleimage)
        files = os.listdir(os.path.join(imagesPath, singleimage))
        allvariants = ",".join(files)
        print(allvariants)
        name = singleimage.replace('-', ' ').title()
        cursor.execute(
            'INSERT INTO images (name, path, variants) VALUES (%s, %s, %s)', (name, singleimage, allvariants))
        mydb.commit()
        imageId = cursor.lastrowid
        for file in files:
            cursor.execute(
                'INSERT INTO variants (image_id, name) VALUES (%s, %s)', (imageId, file))
            mydb.commit()
    mydb.close()


if __name__ == '__main__':
    mainFunction()
