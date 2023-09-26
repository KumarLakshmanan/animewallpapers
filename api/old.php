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
    $serverKey = 'AAAADy37Dmo:APA91bHE0xgJRAfyQnEWYWe-IGDt3wP7SLKZ5D9c_MgnX6kM5sVuQnp1CSGPC6za1ltO0L0vTbxztIXcTpAIDWF6UzrePIof5yzb_vsmW2VXLY0BfERV0wYzz_QJuu9fx0Prm6pECXLW';
    $url = 'https://fcm.googleapis.com/fcm/send';
    $fields = array(
        'registration_ids' => $id,
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
    curl_close($ch);
    return $result;
}

if (isset($_REQUEST["mode"])) {
    $mode = $_REQUEST["mode"];
    if ($mode == 'adminlogin') {
        if (isset($_REQUEST["email"]) && isset($_REQUEST["password"])) {
            try {
                $email = trim(htmlspecialchars($_REQUEST["email"]));
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
                        "email" => $result[0]["email"],
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
                    $_SESSION['email'] = $result[0]["email"];
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
    } else if ($mode == "addcourse") {
        if (isset($_REQUEST["name"]) && isset($_REQUEST["content"]) && isset($_REQUEST["commands"]) && isset($_REQUEST["images"])) {
            if (isset($_SESSION['id']) && isset($_SESSION['email'])) {
                $authId = $_SESSION['token'];
                $username = $_SESSION['email'];
                $fullname = $_SESSION['fullname'];
                try {
                    $userAuth  = validateSessionToken($conn, $authId, $username);
                    if ($userAuth) {
                        $name = $_REQUEST["name"];
                        $content = $_REQUEST["content"];
                        $images = $_REQUEST["images"];
                        $commands = $_REQUEST["commands"];
                        $name = htmlspecialchars($name);
                        $content = htmlspecialchars($content);
                        $commands = htmlspecialchars($commands);
                        $id = time() . "_" . substr(uniqid(), 0, 10);
                        $status = "public";
                        $downloads = 0;
                        $created_at = date("Y-m-d H:i:s");
                        $sql = "INSERT INTO course (status, title,  content, created_at, updated_at, images, commands) VALUES (:status, :title, :content, :created_at, :updated_at, :images, :commands)";
                        $stmt = $conn->prepare($sql);
                        $stmt->bindParam(":status", $status);
                        $stmt->bindParam(":title", $name);
                        $stmt->bindParam(":content", $content);
                        $stmt->bindParam(":created_at", $created_at);
                        $stmt->bindParam(":updated_at", $created_at);
                        $stmt->bindParam(":images", $images);
                        $stmt->bindParam(":commands", $commands);
                        $stmt->execute();
                        $json["error"] = array("code" => "#200", "description" => "Success.");
                        $id = $conn->lastInsertId();
                    } else {
                        $json["error"] = array("code" => "#401", "description" => "Unauthorized.");
                    }
                } catch (Exception $e) {
                    $json["error"] = array("code" => "#500", "description" => $e->getMessage());
                }
            } else {
                $json["error"] = array("code" => "#600", "description" => "Session expired.");
            }
        } else {
            $json["error"] = array("code" => "#400", "description" => "Name, category and content are required.");
        }
    } else if ($mode == "editcourse") {
        if (isset($_REQUEST["name"]) && isset($_REQUEST["content"]) && isset($_REQUEST["commands"]) && isset($_REQUEST["images"]) && isset($_REQUEST["courseid"])) {
            try {
                $name = $_REQUEST["name"];
                $content = $_REQUEST["content"];
                $images = $_REQUEST["images"];
                $id = $_REQUEST["courseid"];
                $commands = $_REQUEST["commands"];
                $name = htmlspecialchars($name);
                $content = htmlspecialchars($content);
                $commands = htmlspecialchars($commands);
                $courseid = trim($id);
                $id = time() . "_" . substr(uniqid(), 0, 10);
                $status = "public";
                $downloads = 0;
                $created_at = date("Y-m-d H:i:s");
                $sql = "UPDATE course SET status = :status, title = :title,  content = :content, updated_at = :updated_at, images = :images, commands = :commands WHERE id = :id";
                $stmt = $conn->prepare($sql);
                $stmt->bindParam(":status", $status);
                $stmt->bindParam(":title", $name);
                $stmt->bindParam(":content", $content);
                $stmt->bindParam(":updated_at", $created_at);
                $stmt->bindParam(":images", $images);
                $stmt->bindParam(":commands", $commands);
                $stmt->bindParam(":id", $courseid);
                $stmt->execute();
                $json["error"] = array("code" => "#200", "description" => "Success.");
                $id = $conn->lastInsertId();
            } catch (\Throwable $th) {
                $json["error"] = array("code" => "#500", "description" => $th->getMessage());
            }
        } else {
            $json["error"] = array("code" => "#400", "description" => "Name, category and content are required.");
        }
    } else if ($mode == "deletecourse") {
        $courseid = $_REQUEST["courseid"];
        $sql = "UPDATE course SET status = :status1 WHERE id = :id";
        $stmt = $conn->prepare($sql);
        $status = "deleted";
        $stmt->bindParam(":status1", $status);
        $stmt->bindParam(":id", $courseid);
        $stmt->execute();
        $json["error"] = array("code" => "#200", "description" => "Success.");
        $regids = array();
    } else if ($mode == "getcourses") {
        if (isset($_REQUEST['page'])) {
            $page = $_REQUEST['page'];
        } else {
            $page = 1;
        }
        $json["error"] = array("code" => "#200", "description" => "Success.");
        $sql = "SELECT * FROM course WHERE status='public' ORDER BY id DESC LIMIT :from, :to";
        $stmt = $conn->prepare($sql);
        $from = ($page - 1) * 10;
        $to = $page * 10;
        $stmt->bindParam(":from", $from);
        $stmt->bindParam(":to", $to);
        $stmt->execute();
        $result = $stmt->fetchAll();
        $json["data"] = array();
        foreach ($result as $row) {
            $images = $row['images'];
            if (strpos($images, ',') == true) {
                $images = explode(",", $images);
            } else {
                $images = array(
                    $images
                );
            }
            $json["data"][] = array(
                "id" => $row["id"],
                "title" => $row["title"],
                "images" => $images,
                "views" => $row["views"],
                "created_at" => strtotime($row["created_at"]) * 1000,
            );
        }
    } else if ($mode == "getsinglecourse") {
        if (isset($_REQUEST["courseid"])) {
            $json["error"] = array("code" => "#200", "description" => "Success.");
            $courseid = $_REQUEST["courseid"];
            $sql = "SELECT * FROM course WHERE id=:id";
            $stmt = $conn->prepare($sql);
            $stmt->bindParam(":id", $courseid);
            $stmt->execute();
            $result = $stmt->fetchAll();
            $json["data"] = array();
            // increase the views
            $sql = "UPDATE course SET views = views + 1 WHERE id = :id";
            foreach ($result as $row) {
                $images = $row['images'];
                if (strpos($images, ',') == true) {
                    $images = explode(",", $images);
                } else {
                    $images = array(
                        $images
                    );
                }
                $commands = $row['commands'];
                $commands = explode("\r\n", $commands);
                $json["data"][] = array(
                    "id" => $row["id"],
                    "title" => $row["title"],
                    "images" => $images,
                    "content" => htmlspecialchars_decode($row["content"]),
                    "commands" => $commands,
                    "created_at" => strtotime($row["created_at"]) * 1000,
                );
            }
        } else {
            $json["error"] = array("code" => "#400", "description" => "Course id is required.");
        }
    } else if ($mode == "contactMessage") {
        if (isset($_REQUEST["name"]) && isset($_REQUEST["email"]) && isset($_REQUEST["message"])) {
            try {
                $name = $_REQUEST["name"];
                $email = trim($_REQUEST["email"]);
                if (isset($_SESSION["fullname"])) {
                    $name = $_SESSION["fullname"];
                }
                if (isset($_SESSION["email"])) {
                    $email = $_SESSION["email"];
                }
                $message = $_REQUEST["message"];
                $priority = $_REQUEST["priority"];
                $contactmode = $_REQUEST["contactmode"];
                $type = $_REQUEST["type"];
                $phone = $_REQUEST["phone"];
                $name = htmlspecialchars($name);
                $email = htmlspecialchars($email);
                $message = htmlspecialchars($message);
                $data  = json_decode(file_get_contents($baseDirectory . "json/contact.json"), true);
                $id = time() . "_" . substr(uniqid(), 0, 10);
                $data[$id] = array(
                    "id" => $id,
                    "name" => $name ?? "",
                    "email" => $email ?? "",
                    "message" => $message ?? "",
                    "priority" => $priority ?? "",
                    "contactmode" => $contactmode ?? "",
                    "phone" => $phone ?? "",
                    "type" => $type ?? "",
                    "created_at" => date("Y-m-d H:i:s"),
                    "status" => "new"
                );
                file_put_contents($baseDirectory . "json/contact.json", json_encode($data));
                $json["error"] = array("code" => "#200", "description" => "Success.");
            } catch (Exception $e) {
                $json["error"] = array("code" => "#500", "description" => $e->getMessage());
            }
        } else {
            $json["error"] = array("code" => "#400", "description" => "Username and password are required.");
        }
    } else if ($mode == "sendNotification") {
        if (isset($_REQUEST["title"]) && isset($_REQUEST["message"])) {
            $title = $_REQUEST["title"];
            $message = $_REQUEST["message"];
            $sql = "SELECT regid FROM users WHERE regid != ''";
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
            $regid = $_REQUEST['regid'];
            $version = "0";
            if (isset($_REQUEST['version'])) {
                $version = $_REQUEST['version'];
            }
            $file = file_get_contents('regid.json');
            $json = json_decode($file, true);
            // Check if regid already exists
            $regidExists = false;
            $regids = array_keys($json['regid']);
            for ($i = 0; $i < count($regids); $i++) {
                if ($regids[$i] == $regid) {
                    $regidExists = true;
                    break;
                }
            }
            $json['regid'][$regid] = array("version" => $version, "regid" => $regid, "timestamp" => time());
            file_put_contents('regid.json', json_encode($json, JSON_PRETTY_PRINT));
            echo "success";
        }
    } else {
        $json['error'] = array("code" => "#403", "description" => "Invalid mode.");
    }
} else {
    $json["error"] = array("code" => "#403", "description" => "Mode is required.");
}

unset($json["regid"]);
echo json_encode($json);
