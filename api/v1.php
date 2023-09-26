<?php

session_start();
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
ini_set('log_errors', true);
ini_set('error_log', './php-error.log');
include("./config.php");

$keyId = 'rzp_live_PnH6hXuq0ds6JA';
$keySecret = '1uuH5tmj6QJg4L8dVEB4B72i';

$displayCurrency = 'INR';


$db = new Connection();
$conn = $db->getConnection();
$json["data"] = [];
$json["error"] = array("code" => "#200", "description" => "Success.");

error_reporting(E_ALL ^ E_NOTICE);
date_default_timezone_set('Asia/Calcutta');

$emailRegex  =  '/^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/';
$phoneRegex  =  '/^[0-9]{10}$/';
$nameRegex   =  '/^[a-zA-Z ]{2,30}$/';


function sendGCM($title, $message, $id)
{
    $id = array_filter($id);
    $id = array_unique($id);
    $count = count($id);

    $i = 0;
    $gcmresult = array();
    while ($i < $count) {
        $id1 = array_slice($id, $i, 1000);
        $i = $i + 1000;
        $serverKey = 'AAAA7_nbMvU:APA91bGvFt5Si8RcKPCzrrYcCJRwjS1DBjNF960qka9TsK5NPyrdBavpCeYJP-UO1LD4WYTapVjVCasANp-ZN8UHQlsxzaBv1qjXnrvtZgcviCURtp34XsmkBJk8o8xlDASNf-ybs7nt';
        $url = 'https://fcm.googleapis.com/fcm/send';
        $fields = array(
            'registration_ids' => $id1,
            'data' => array(
                "title" => $title,
                "message" => $message,
            )
        );
        $fields = json_encode($fields);
        $headers = array(
            'Authorization: key=' . $serverKey,
            'Content-Type: application/json'
        );
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $fields);
        $result = curl_exec($ch);
        $gcmresult[] = $result;
        curl_close($ch);
    }
    return $gcmresult;
}

if (isset($_REQUEST["mode"])) {
    $mode = $_REQUEST["mode"];
    if ($mode == 'adminlogin') {
        if (isset($_REQUEST["username"]) && isset($_REQUEST["password"])) {
            try {
                $email = trim(htmlspecialchars($_REQUEST["username"]));
                $password = trim(htmlspecialchars($_REQUEST["password"]));
                $regid = trim(htmlspecialchars($_REQUEST["regid"] ?? ""));
                if (trim($email) == "" || trim($password) == "") {
                    $json["error"] = array("code" => "#400", "description" => "Please enter email and password.");
                    echo json_encode($json);
                    exit;
                }
                if (strlen($password) < 5) {
                    $json["error"] = array("code" => "#400", "description" => "Password must be at least 5 characters.");
                    echo json_encode($json);
                    exit;
                }
                $sql = "SELECT * FROM users WHERE (email = :email OR username = :username) AND password = :password AND role = 'admin'";
                $stmt = $conn->prepare($sql);
                $stmt->bindParam(":email", $email);
                $stmt->bindParam(":username", $email);
                $stmt->bindParam(":password", $password);
                $stmt->execute();
                $result = $stmt->fetchAll();
                if (count($result) > 0) {
                    $id = $result[0]["id"];
                    $sql = "UPDATE users SET regid = :regid WHERE id = :id";
                    $stmt = $conn->prepare($sql);
                    $stmt->bindParam(":regid", $regid);
                    $stmt->bindParam(":id", $id);
                    $stmt->execute();
                    $token = getSessionToken($conn, $result[0]['email'], $id);
                    $json["error"] = array("code" => "#200", "description" => "Success.");
                    $json["data"] = array(
                        "token" => $token,
                        "id" => $id,
                        "username" => $result[0]["username"],
                        "photo" => $result[0]["photo"],
                        "name" => $result[0]["fullname"],
                        "username" => $result[0]["username"],
                        "role" => $result[0]["role"],
                        "pro" => $result[0]["pro"],
                        "about" => $result[0]["about"],
                        "website" => $result[0]["website"],
                        "country" => $result[0]["country"],
                        "skills" => explode(",", $result[0]["skills"] ?? ""),
                        "created_at" => strtotime($result[0]["created_at"]) * 1000,
                    );
                    for ($k = 0; $k < count($json['data']['skills']); $k++) {
                        if ($json['data']['skills'][$k] == "") {
                            unset($json['data']['skills'][$k]);
                        }
                    }
                    $_SESSION['id'] = $id;
                    $_SESSION['email'] = $result[0]["email"];
                    $_SESSION['fullname'] = $result[0]["fullname"];
                    $_SESSION['username'] = $result[0]["username"];
                    $_SESSION['role'] = $result[0]["role"];
                    $_SESSION['token'] = $token;
                    $json["error"] = array("code" => "#200", "description" => "Success.");
                } else {
                    $json["error"] = array("code" => "#400", "description" => "Invalid email or password.");
                }
            } catch (Exception $e) {
                $json["error"] = array("code" => "#500", "description" => $e->getMessage());
            }
        } else {
            $json["error"] = array("code" => "#400", "description" => "email and password are required.");
        }
    } else if ($mode == 'addbooks') {
        if (
            isset($_REQUEST['bookname']) &&
            isset($_REQUEST['category']) &&
            isset($_REQUEST['category2']) &&
            isset($_REQUEST['subcategory'])
        ) {
            try {
                $bookname = trim(htmlspecialchars($_REQUEST["bookname"]));
                $category = trim(htmlspecialchars($_REQUEST["category"]));
                $category2 = trim(htmlspecialchars($_REQUEST["category2"]));
                $subcategory = trim(htmlspecialchars($_REQUEST["subcategory"]));

                $bookid = trim(htmlspecialchars($_REQUEST["bookid"] ?? ""));
                if (trim($bookname) == "" || trim($category) == "" || trim($subcategory) == "") {
                    $json["error"] = array("code" => "#400", "description" => "Please fill all the fields.");
                } else {
                    $imagePath1 = "";
                    $imagePath2 = "";
                    $uploadOk = 1;
                    $imgid = time();
                    $target_dir = $uploadsDirectory . "images/";
                    if (!file_exists($target_dir)) {
                        mkdir($target_dir, 0777, true);
                    }
                    if (isset($_FILES['image1'])) {
                        $image1name = $imgid . "_1.jpg";
                        $target_file = $target_dir . $image1name;
                        $uploadOk = 1;
                        $imageFileType = strtolower(pathinfo($target_file, PATHINFO_EXTENSION));
                        // Check if image file is a actual image or fake image
                        // $check = getimagesize($_FILES["image1"]["tmp_name"]);
                        // if ($check !== false) {
                        //     $json["error"] = array("code" => "#400", "description" => "File is not an image.");
                        //     $uploadOk = 0;
                        // }
                        if ($_FILES["image1"]["size"] > 50000000) {
                            $json["error"] = array("code" => "#400", "description" => "Sorry, your file is too large.");
                            $uploadOk = 0;
                        }
                        if (
                            $imageFileType != "jpg" && $imageFileType != "png" && $imageFileType != "jpeg"
                        ) {
                            $json["error"] = array("code" => "#400", "description" => "Sorry, only JPG, JPEG, PNG & GIF files are allowed.");
                            $uploadOk = 0;
                        }
                        // Check if $uploadOk is set to 0 by an error
                        if ($uploadOk != 0) {
                            if (move_uploaded_file($_FILES["image1"]["tmp_name"], $target_file)) {
                                $imagePath1 = $image1name;
                                $json["error"] = array("code" => "#200", "description" => "The file " . htmlspecialchars(basename($_FILES["image1"]["name"])) . " has been uploaded.");
                            } else {
                                $json["error"] = array("code" => "#400", "description" => "Sorry, there was an error uploading your file.");
                            }
                        }
                    }
                    if (isset($_FILES['image2'])) {
                        $image2name = $imgid . "_2.jpg";
                        $target_file = $target_dir . $image2name;
                        $uploadOk = 1;
                        $imageFileType = strtolower(pathinfo($target_file, PATHINFO_EXTENSION));
                        if ($_FILES["image2"]["size"] > 50000000) {
                            $json["error"] = array("code" => "#400", "description" => "Sorry, your file is too large.");
                            $uploadOk = 0;
                        }
                        if (
                            $imageFileType != "jpg" && $imageFileType != "png" && $imageFileType != "jpeg"
                        ) {
                            $json["error"] = array("code" => "#400", "description" => "Sorry, only JPG, JPEG, PNG & GIF files are allowed.");
                            $uploadOk = 0;
                        }
                        // Check if $uploadOk is set to 0 by an error
                        if ($uploadOk != 0) {
                            if (move_uploaded_file($_FILES["image2"]["tmp_name"], $target_file)) {
                                $imagePath2 = $image2name;
                                $json["error"] = array("code" => "#200", "description" => "The file " . htmlspecialchars(basename($_FILES["image2"]["name"])) . " has been uploaded.");
                            } else {
                                $json["error"] = array("code" => "#400", "description" => "Sorry, there was an error uploading your file.");
                            }
                        }
                    }

                    if ($bookid == "") {
                        if ($imagePath1 != "" && $imagePath2 != "") {
                            $sql = "INSERT INTO couplewallpapers (title, category, category2, image1, image2, subcategory) VALUES (:title, :category, :category2, :image1, :image2, :subcategory)";
                            $stmt = $conn->prepare($sql);
                            $stmt->bindParam(":title", $bookname);
                            $stmt->bindParam(":category", $category);
                            $stmt->bindParam(":category2", $category2);
                            $stmt->bindParam(":image1", $imagePath1);
                            $stmt->bindParam(":image2", $imagePath2);
                            $stmt->bindParam(":subcategory", $subcategory);
                            $stmt->execute();
                            $json["error"] = array("code" => "#200", "description" => "Success.");
                        } else {
                            $json["error"] = array("code" => "#400", "description" => "Please upload both images.");
                        }
                    } else {
                        $sql = "UPDATE couplewallpapers SET title = :title, category = :category, category2 = :category2,";
                        if ($imagePath1 != "") {
                            $sql .= " image1 = :image1,";
                        }
                        if ($imagePath2 != "") {
                            $sql .= " image2 = :image2,";
                        }
                        $sql .= "subcategory = :subcategory WHERE id = :id";
                        $stmt = $conn->prepare($sql);
                        $stmt->bindParam(":title", $bookname);
                        $stmt->bindParam(":category", $category);
                        $stmt->bindParam(":category2", $category2);
                        if ($imagePath1 != "") {
                            $stmt->bindParam(":image1", $imagePath1);
                        }
                        if ($imagePath2 != "") {
                            $stmt->bindParam(":image2", $imagePath2);
                        }
                        $stmt->bindParam(":subcategory", $subcategory);
                        $stmt->bindParam(":id", $bookid);
                        $stmt->execute();
                        $json["error"] = array("code" => "#200", "description" => "Succeasss.");
                    }
                }
            } catch (Exception $e) {
                $json["error"] = array("code" => "#500", "description" => $e->getMessage());
            }
        }
    } else if ($mode == 'deletebooks') {
        $id = $_REQUEST["id"] ?? "";
        if ($id == "") {
            $json["error"] = array("code" => "#400", "description" => "Invalid request.");
        } else {
            $sql = "DELETE FROM tnscert_books2 WHERE id = :id";
            $stmt = $conn->prepare($sql);
            $stmt->bindParam(":id", $id);
            $stmt->execute();
            $json["error"] = array("code" => "#200", "description" => "Success.");
        }
    } else if ($mode == "contactMessage") {
        $datetime = date("Y-m-d H:i:s");
        try {
            $name = $_REQUEST["name"] ?? "";
            $email = $_REQUEST["email"] ?? "";
            $mobile = $_REQUEST["phone"] ?? "";
            $message = $_REQUEST["message"] ?? "";
            $name = htmlspecialchars($name);
            $mobile = htmlspecialchars($mobile);
            $email = htmlspecialchars($email);
            $message = htmlspecialchars($message);

            $sql = "INSERT INTO messages (name, email, phone, message,  created_at) VALUES (:name, :email, :phone, :message, :created_at)";
            $stmt = $conn->prepare($sql);
            $stmt->bindParam(":name", $name);
            $stmt->bindParam(":email", $email);
            $stmt->bindParam(":phone", $mobile);
            $stmt->bindParam(":message", $message);
            $stmt->bindParam(":created_at", $datetime);
            $stmt->execute();

            $json["error"] = array("code" => "#200", "description" => "Success.");
        } catch (Exception $e) {
            $json["error"] = array("code" => "#500", "description" => $e->getMessage());
        }
    } else if ($mode == "closeMessage") {
        $id = $_REQUEST["id"] ?? "";
        if ($id == "") {
            $json["error"] = array("code" => "#400", "description" => "Invalid request.");
        } else {
            $sql = "UPDATE messages SET status = 'closed' WHERE id = :id";
            $stmt = $conn->prepare($sql);
            $stmt->bindParam(":id", $id);
            $stmt->execute();
            $json["error"] = array("code" => "#200", "description" => "Success.");
        }
    } else if ($mode == "openMessage") {
        $id = $_REQUEST["id"] ?? "";
        if ($id == "") {
            $json["error"] = array("code" => "#400", "description" => "Invalid request.");
        } else {
            $sql = "UPDATE messages SET status = 'opened' WHERE id = :id";
            $stmt = $conn->prepare($sql);
            $stmt->bindParam(":id", $id);
            $stmt->execute();
            $json["error"] = array("code" => "#200", "description" => "Success.");
        }
    } else if ($mode == "deleteMessage") {
        $id = $_REQUEST["id"] ?? "";
        if ($id == "") {
            $json["error"] = array("code" => "#400", "description" => "Invalid request.");
        } else {
            $sql = "DELETE FROM messages WHERE id = :id";
            $stmt = $conn->prepare($sql);
            $stmt->bindParam(":id", $id);
            $stmt->execute();
            $json["error"] = array("code" => "#200", "description" => "Success.");
        }
    } else if ($mode == "sendNotification") {
        if (isset($_REQUEST["title"]) && isset($_REQUEST["message"])) {
            $title = $_REQUEST["title"];
            $message = $_REQUEST["message"];
            $sql = "SELECT regid FROM regid WHERE regid != ''";
            $stmt = $conn->prepare($sql);
            $stmt->execute();
            $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
            foreach ($result as $row) {
                $regids[] = $row["regid"];
            }
            sendGCM($title, $message, $regids);
        } else {
            $json["error"] = array("code" => "#400", "description" => "Name, category and content are required.");
        }
    } else if ($mode == "saveregid") {
        if (isset($_REQUEST['regid'])) {
            $sql = "SELECT * FROM regid WHERE regid = :regid";
            $stmt = $conn->prepare($sql);
            $stmt->bindParam(":regid", $_REQUEST['regid']);
            $stmt->execute();
            $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
            if (count($result) == 0) {
                $sql = "INSERT INTO regid (regid) VALUES (:regid)";
                $stmt = $conn->prepare($sql);
                $stmt->bindParam(":regid", $_REQUEST['regid']);
                $stmt->execute();
            }
        } else {
            echo "error";
        }
    } else if ($mode == "getAllCategories") {
        $sql = "SELECT COUNT(*) AS count, category, image1, image2 FROM couplewallpapers GROUP BY category";
        $stmt = $conn->prepare($sql);
        $stmt->execute();
        $result = $stmt->fetchAll();
        $json["error"] = array("code" => "#200", "description" => "Success.");
        for ($i = 0; $i < count($result); $i++) {
            $fileName = $baseDirectory . "img/" . $result[$i]['category'] . ".png";
            if (file_exists($fileName)) {
                $result[$i]['image'] = $webAddress . "img/" . $result[$i]['category'] . ".png";
            } else {
                $sql = "SELECT * FROM couplewallpapers WHERE category = :categoryid ORDER BY RAND() LIMIT 1";
                $stmt = $conn->prepare($sql);
                $stmt->bindParam(":categoryid", $result[$i]['category']);
                $stmt->execute();
                $result2 = $stmt->fetchAll();
                $result[$i]['image1'] = $result2[0]['image1'];
                $result[$i]['image2'] = $result2[0]['image2'];
            }
        }
        $json["data"] = $result;
    } else if ($mode == "getAllImages") {
        $category = $_REQUEST['category'] ?? "";
        $subcategory = $_REQUEST['subcategory'] ?? "";
        $pageNo = (int)trim(htmlspecialchars($_REQUEST['pageNo'] ?? "1"));
        $limit = (int)trim(htmlspecialchars($_REQUEST['limit'] ?? "10"));
        $offset = ($pageNo - 1) * $limit;

        if ($category == "random" || $category == "") {
            $sql = "SELECT id, image, thumb, views, category, subcategory as status  FROM couplewallpapers ORDER BY RAND() LIMIT :limit OFFSET :offset";
            $stmt = $conn->prepare($sql);
            $stmt->bindParam(":limit", $limit, PDO::PARAM_INT);
            $stmt->bindParam(":offset", $offset, PDO::PARAM_INT);
        } else if ($subcategory != "") {
            $sql = "SELECT id, image, thumb, views, category, subcategory as status  FROM couplewallpapers WHERE category = :categoryid AND subcategory = 'premium'  ORDER BY RAND() LIMIT :limit OFFSET :offset";
            $stmt = $conn->prepare($sql);
            $stmt->bindParam(":limit", $limit, PDO::PARAM_INT);
            $stmt->bindParam(":offset", $offset, PDO::PARAM_INT);
            $stmt->bindParam(":categoryid", $category);
        } else if ($category != "") {
            $sql = "SELECT id, image, thumb, views, category, subcategory as status  FROM couplewallpapers WHERE category = :categoryid ORDER BY RAND() LIMIT :limit OFFSET :offset";
            $stmt = $conn->prepare($sql);
            $stmt->bindParam(":limit", $limit, PDO::PARAM_INT);
            $stmt->bindParam(":offset", $offset, PDO::PARAM_INT);
            $stmt->bindParam(":categoryid", $category);
        } else {
            $sql = "SELECT id, image, thumb, views, category, subcategory as status  FROM couplewallpapers ORDER BY RAND() LIMIT :limit OFFSET :offset";
            $stmt = $conn->prepare($sql);
            $stmt->bindParam(":limit", $limit, PDO::PARAM_INT);
            $stmt->bindParam(":offset", $offset, PDO::PARAM_INT);
        }
        $stmt->execute();
        $result = $stmt->fetchAll();
        $json["data"] = $result;
        for ($i = 0; $i < count($result); $i++) {
            $id = $result[$i]['id'];
            $sql = "UPDATE couplewallpapers SET views = views + 1 WHERE id = :id";
            $stmt = $conn->prepare($sql);
            $stmt->bindParam(":id", $id);
            $stmt->execute();
        }
    } else if ($mode == "vote") {
        $id =  $_REQUEST['id'];
        $sql = "UPDATE couplewallpapers SET votes = votes + 1 WHERE id = :id";
        $stmt = $conn->prepare($sql);
        $stmt->bindParam(":id", $id);
        $stmt->execute();
        $json["error"] = array("code" => "#200", "description" => "Success.");
    } else {
        $json['error'] = array("code" => "#403", "description" => "Invalid mode.");
    }
} else {
    $json["error"] = array("code" => "#403", "description" => "Mode is required.");
}

unset($json["regid"]);
echo json_encode($json);
