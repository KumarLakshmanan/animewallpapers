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


$json["data"] = [];
$json["error"] = array("code" => "#200", "description" => "Success.");

error_reporting(E_ALL ^ E_NOTICE);
date_default_timezone_set('Asia/Calcutta');

$emailRegex  =  '/^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/';
$phoneRegex  =  '/^[0-9]{10}$/';
$nameRegex   =  '/^[a-zA-Z ]{2,30}$/';


$datetime = date("Y-m-d H:i:s");
if (isset($_REQUEST["mode"])) {
    $mode = $_REQUEST["mode"];
    if ($mode == 'login') {
        if (isset($_REQUEST["phone"])) {
            try {
                $phone = trim(htmlspecialchars($_REQUEST["phone"]));
                if (trim($phone) == "") {
                    $json["error"] = array("code" => "#400", "description" => "Please enter email and password.");
                    echo json_encode($json);
                    exit;
                }
                if (!preg_match($phoneRegex, $phone)) {
                    $json["error"] = array("code" => "#400", "description" => "Please enter valid phone number.");
                    echo json_encode($json);
                    exit;
                }
                $sql = "SELECT * FROM users WHERE (phone = :phone)";
                $stmt = $pdoConn->prepare($sql);
                $stmt->bindParam(":phone", $phone);
                $stmt->execute();
                $result = $stmt->fetchAll();
                if (count($result) > 0) {
                    $id = $result[0]["id"];
                    $sql = "UPDATE users SET regid = :regid WHERE id = :id";
                    $stmt = $pdoConn->prepare($sql);
                    $stmt->bindParam(":regid", $regid);
                    $stmt->bindParam(":id", $id);
                    $stmt->execute();
                    $token = getSessionToken($pdoConn, $result[0]['email'], $id);
                    $json["error"] = array("code" => "#200", "description" => "Success.");
                    $json["data"] = $result[0];
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
    } else if ($mode == 'adminlogin') {
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
                $sql = "SELECT * FROM admins WHERE (email = :email AND password = :password) AND (role = 'admin' OR role = 'subadmin')";
                $stmt = $pdoConn->prepare($sql);
                $stmt->bindParam(":email", $email);
                $stmt->bindParam(":password", $password);
                $stmt->execute();
                $result = $stmt->fetchAll();
                if (count($result) > 0) {
                    $id = $result[0]["id"];
                    $token = getSessionToken($pdoConn, $result[0]['email'], $id);
                    $json["error"] = array("code" => "#200", "description" => "Success.");
                    $json["data"] = array(
                        "token" => $token,
                        "id" => $id,
                        "fullname" => $result[0]["fullname"],
                        "email" => $result[0]["email"],
                        "role" => $result[0]["role"],
                    );
                    $_SESSION['id'] = $id;
                    $_SESSION['email'] = $result[0]["email"];
                    $_SESSION['fullname'] = $result[0]["fullname"];
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
    } else if ($mode == 'register') {
        if (isset($_REQUEST["email"]) && isset($_REQUEST["password"]) && isset($_REQUEST["fullname"])) {
            try {
                $email = trim(htmlspecialchars($_REQUEST["email"]));
                $password = trim(htmlspecialchars($_REQUEST["password"]));
                $fullname = trim(htmlspecialchars($_REQUEST["fullname"]));
                $regid = trim(htmlspecialchars($_REQUEST["regid"] ?? ""));
                if (trim($email) == "" || trim($password) == "" || trim($fullname) == "") {
                    $json["error"] = array("code" => "#400", "description" => "Please fill all fields.");
                    echo json_encode($json);
                    exit;
                }
                if (!preg_match($emailRegex, $email)) {
                    $json["error"] = array("code" => "#400", "description" => "Invalid email.");
                    echo json_encode($json);
                    exit;
                }
                if (strlen($password) < 6) {
                    $json["error"] = array("code" => "#400", "description" => "Password must be at least 6 characters.");
                    echo json_encode($json);
                    exit;
                }
                if (!preg_match($nameRegex, $fullname)) {
                    $json["error"] = array("code" => "#400", "description" => "Invalid name.");
                    echo json_encode($json);
                    exit;
                }
                $username = explode("@", $email)[0] . "_" . rand(0, 9999);
                $role = "user";
                $created_at = date("Y-m-d H:i:s");
                $updated_at = date("Y-m-d H:i:s");
                $sql = "SELECT * FROM users WHERE email = :email";
                $stmt = $pdoConn->prepare($sql);
                $stmt->bindParam(":email", $email);
                $stmt->execute();
                $result = $stmt->fetchAll();
                if (count($result) == 0) {
                    $sql = "INSERT INTO users (email, password, fullname, username, role,created_at,updated_at,regid) VALUES (:email, :password, :fullname, :username, :role, :created_at, :updated_at, :regid)";
                    $stmt = $pdoConn->prepare($sql);
                    $stmt->bindParam(":email", $email);
                    $stmt->bindParam(":password", $password);
                    $stmt->bindParam(":fullname", $fullname);
                    $stmt->bindParam(":username", $username);
                    $stmt->bindParam(":role", $role);
                    $stmt->bindParam(":created_at", $created_at);
                    $stmt->bindParam(":updated_at", $updated_at);
                    $stmt->bindParam(":regid", $regid);
                    $stmt->execute();
                    $id = $pdoConn->lastInsertId();
                    $token = getSessionToken($pdoConn, $email, $id);
                    $_SESSION['id'] = $id;
                    $_SESSION['email'] = $email;
                    $_SESSION['fullname'] = $fullname;
                    $_SESSION['username'] = $username;
                    $_SESSION['email'] = $email;
                    $_SESSION['role'] = $role;
                    $_SESSION['token'] = $token;
                    $json["data"] = array(
                        "token" => $token,
                        "id" => $id,
                        "photo" => "",
                        "name" => $fullname,
                        "email" => $email,
                        "role" => $role,
                        "pro" => "0",
                        "about" => "",
                        "website" => "",
                        "country" => "",
                        "skills" => [],
                        "created_at" => strtotime($created_at) * 1000,
                    );
                    $json["error"] = array("code" => "#200", "description" => "Register success.");
                } else {
                    $json["error"] = array("code" => "#400", "description" => "Email already exists.");
                }
            } catch (Exception $e) {
                $json["error"] = array("code" => "#500", "description" => $e->getMessage());
            }
        } else {
            $json["error"] = array("code" => "#400", "description" => "email and password are required.");
        }
    } else if ($mode == 'refresh') {
        if (isset($_REQUEST['token']) && isset($_REQUEST['email'])) {
            $token = trim(htmlspecialchars($_REQUEST['token']));
            $email  = trim(htmlspecialchars($_REQUEST['email']));
            try {
                $regid = trim(htmlspecialchars($_REQUEST["regid"] ?? ""));
                $userAuth  = validateSessionToken($pdoConn, $token, $email);
                if ($userAuth) {
                    $username  = $userAuth['username'];
                    $json["error"] = array("code" => "#200", "description" => "Success.");
                    $sql = "UPDATE users SET regid = :regid WHERE id = :id";
                    $stmt = $pdoConn->prepare($sql);
                    $stmt->bindParam(":regid", $regid);
                    $stmt->bindParam(":id", $userAuth["id"]);
                    $stmt->execute();

                    $sql = "SELECT * FROM users WHERE email = :email";
                    $stmt = $pdoConn->prepare($sql);
                    $stmt->bindParam(":email", $email);
                    $stmt->execute();
                    $result = $stmt->fetch(PDO::FETCH_ASSOC);
                    $json["data"] = array(
                        "token" => $token,
                        "id" => $result["id"],
                        "photo" => $result["photo"],
                        "name" => $result["fullname"],
                        "email" => $result["email"],
                        "role" => $result["role"],
                        "pro" => $result["pro"],
                        "about" => $result["about"],
                        "website" => $result["website"],
                        "country" => $result["country"],
                        "skills" => explode(",", $result["skills"] ?? ""),
                        "created_at" => strtotime($result["created_at"]) * 1000,
                    );
                    for ($k = 0; $k < count($json['data']['skills']); $k++) {
                        if ($json['data']['skills'][$k] == "") {
                            unset($json['data']['skills'][$k]);
                        }
                    }
                    $_SESSION['id'] = $result['id'];
                    $_SESSION['email'] = $result["email"];
                    $_SESSION['fullname'] = $result["fullname"];
                    $_SESSION['email'] = $result["email"];
                    $_SESSION['role'] = $result["role"];
                    $_SESSION['token'] = $token;
                    $json["error"] = array("code" => "#200", "description" => "Success.");
                } else {
                    $sql = "SELECT * FROM users WHERE email = :email";
                    $stmt = $pdoConn->prepare($sql);
                    $stmt->bindParam(":email", $email);
                    $stmt->execute();
                    $result = $stmt->fetchAll();
                    if (count($result) != 0) {
                        $token = getSessionToken($pdoConn, $email, $result[0]["id"]);
                        $_SESSION['id'] = $result[0]['id'];
                        $_SESSION['email'] = $result[0]["email"];
                        $_SESSION['fullname'] = $result[0]["fullname"];
                        $_SESSION['email'] = $result[0]["email"];
                        $_SESSION['role'] = $result[0]["role"];
                        $_SESSION['token'] = $token;
                        $json["data"] = array(
                            "token" => $token,
                            "id" => $result[0]["id"],
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
                        $json["error"] = array("code" => "#200", "description" => "Success.");
                    } else {
                        $json["error"] = array("code" => "#400", "description" => "Invalid token.");
                    }
                }
            } catch (Exception $e) {
                $json["error"] = array("code" => "#500", "description" => $e->getMessage());
            }
        } else {
            $json["error"] = array("code" => "#401", "description" => "Invalid token.");
        }
    } else if ($mode == 'addlink') {
        if (isset($_REQUEST['linkname']) && isset($_REQUEST['linkurl'])) {
            $linkname = trim(htmlspecialchars($_REQUEST['linkname']));
            $linkurl  = trim(htmlspecialchars($_REQUEST['linkurl']));
            $token = trim(htmlspecialchars($_SESSION['token']));
            $email  = trim(htmlspecialchars($_SESSION['email']));
            try {
                $userAuth  = validateSessionToken($pdoConn, $token, $email);
                if ($userAuth) {
                    $username  = $userAuth['username'];
                    $sql = "INSERT INTO links (name, url,created_date) VALUES (:linkname, :linkurl, NOW())";
                    $stmt = $pdoConn->prepare($sql);
                    $stmt->bindParam(":linkname", $linkname);
                    $stmt->bindParam(":linkurl", $linkurl);
                    $stmt->execute();
                    // $sql = "SELECT regid FROM regid";
                    // $stmt = $pdoConn->prepare($sql);
                    // $stmt->execute();
                    // $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
                    // $active = array();
                    // foreach ($result as $row) {
                    //     $active[] = $row["regid"];
                    // }
                    // sendGCM(
                    //     "New Links Added",
                    //     $linkname,
                    //     $active
                    // );
                    $json["error"] = array("code" => "#200", "description" => "Success.");
                } else {
                    $json["error"] = array("code" => "#400", "description" => "Invalid token.");
                }
            } catch (Exception $e) {
                $json["error"] = array("code" => "#500", "description" => $e->getMessage());
            }
        } else {
            $json["error"] = array("code" => "#400", "description" => "Invalid request.");
        }
    } else if ($mode == 'getlink') {
        $sql = "SELECT * FROM links";
        $stmt = $pdoConn->prepare($sql);
        $stmt->execute();
        $result = $stmt->fetchAll();
        $json["data"] = array();
        for ($i = 0; $i < count($result); $i++) {
            $json["data"][] = array(
                "id" => $result[$i]["id"],
                "name" => $result[$i]["name"],
                "url" => $result[$i]["url"],
                "created_date" => strtotime($result[$i]["created_date"]) * 1000,
            );
        }
        $json["error"] = array("code" => "#200", "description" => "Success.");
    } else if ($mode == 'deletelink') {
        $sql = "DELETE FROM links WHERE id = :id";
        $stmt = $pdoConn->prepare($sql);
        $stmt->bindParam(":id", $_REQUEST['linkid']);
        $stmt->execute();
        $json["error"] = array("code" => "#200", "description" => "Success.");
    } else if ($mode == 'addannouncement') {
        if (isset($_REQUEST['title']) && isset($_REQUEST['description']) && isset($_REQUEST['link']) && isset($_REQUEST['images'])) {
            $title = trim(htmlspecialchars($_REQUEST['title']));
            $description  = trim(htmlspecialchars($_REQUEST['description']));
            $link  = trim(htmlspecialchars($_REQUEST['link']));
            $token = trim(htmlspecialchars($_SESSION['token']));
            $email  = trim(htmlspecialchars($_SESSION['email']));
            $images = trim(htmlspecialchars($_REQUEST['images']));
            $pdfPath = "";
            $uploadOk = 1;
            try {
                $userAuth  = validateSessionToken($pdoConn, $token, $email);

                if (isset($_FILES['pdf'])) {
                    $target_dir = $uploadsDirectory . "pdf/";
                    $pdfname = uniqid() . ".pdf";
                    $target_file = $target_dir . $pdfname;
                    $uploadOk = 1;
                    $imageFileType = strtolower(pathinfo($target_file, PATHINFO_EXTENSION));
                    // Check if image file is a actual image or fake image
                    $check = getimagesize($_FILES["pdf"]["tmp_name"]);
                    if ($check !== false) {
                        $json["error"] = array("code" => "#400", "description" => "File is not a pdf.");
                        $uploadOk = 0;
                    }
                    if ($_FILES["pdf"]["size"] > 50000000) {
                        $json["error"] = array("code" => "#400", "description" => "Sorry, your file is too large.");
                        $uploadOk = 0;
                    }
                    if (
                        $imageFileType != "pdf"
                    ) {
                        $json["error"] = array("code" => "#400", "description" => "Sorry, only PDF files are allowed.");
                        $uploadOk = 0;
                    }
                    // Check if $uploadOk is set to 0 by an error
                    if ($uploadOk != 0) {
                        if (move_uploaded_file($_FILES["pdf"]["tmp_name"], $target_file)) {
                            $pdfPath = $pdfname;
                            $json["error"] = array("code" => "#200", "description" => "The file " . htmlspecialchars(basename($_FILES["pdf"]["name"])) . " has been uploaded.");
                        } else {
                            $json["error"] = array("code" => "#400", "description" => "Sorry, there was an error uploading your file.");
                        }
                    }
                }
                if ($userAuth) {
                    if ($uploadOk == 1) {
                        $username  = $userAuth['username'];
                        $sql = "INSERT INTO announcements (name, url, description, pdf,image, created_date) VALUES (:name, :url, :description, :pdf, :image, NOW())";
                        $stmt = $pdoConn->prepare($sql);
                        $stmt->bindParam(":name", $title);
                        $stmt->bindParam(":url", $link);
                        $stmt->bindParam(":description", $description);
                        $stmt->bindParam(":pdf", $pdfPath);
                        $stmt->bindParam(":image", $images);
                        $stmt->execute();
                        $json["error"] = array("code" => "#200", "description" => "Success.");
                    } else {
                        $json["error"] = array("code" => "#400", "description" => "PDF is not uploaded");
                    }
                } else {
                    $json["error"] = array("code" => "#400", "description" => "Invalid token.");
                }
            } catch (Exception $e) {
                $json["error"] = array("code" => "#500", "description" => $e->getMessage());
            }
        } else {
            $json["error"] = array("code" => "#400", "description" => "Invalid request 1.");
        }
    } else if ($mode == 'editannouncement') {
        if (isset($_REQUEST['announcementid']) && isset($_REQUEST['title']) && isset($_REQUEST['description']) && isset($_REQUEST['link']) && isset($_REQUEST['images'])) {
            $id = trim(htmlspecialchars($_REQUEST['announcementid']));
            $title = trim(htmlspecialchars($_REQUEST['title']));
            $description  = trim(htmlspecialchars($_REQUEST['description']));
            $link  = trim(htmlspecialchars($_REQUEST['link']));
            $token = trim(htmlspecialchars($_SESSION['token']));
            $email  = trim(htmlspecialchars($_SESSION['email']));
            $images = trim(htmlspecialchars($_REQUEST['images']));
            $pdfPath = "";
            $uploadOk = 1;
            try {
                $userAuth  = validateSessionToken($pdoConn, $token, $email);
                if (isset($_FILES['pdf'])) {
                    $target_dir = $uploadsDirectory . "pdf/";
                    $pdfname = uniqid() . ".pdf";
                    $target_file = $target_dir . $pdfname;
                    $uploadOk = 1;
                    $imageFileType = strtolower(pathinfo($target_file, PATHINFO_EXTENSION));
                    // Check if image file is a actual image or fake image
                    $check = getimagesize($_FILES["pdf"]["tmp_name"]);
                    if ($check !== false) {
                        $json["error"] = array("code" => "#400", "description" => "File is not a pdf.");
                        $uploadOk = 0;
                    }
                    if ($_FILES["pdf"]["size"] > 50000000) {
                        $json["error"] = array("code" => "#400", "description" => "Sorry, your file is too large.");
                        $uploadOk = 0;
                    }
                    if (
                        $imageFileType != "pdf"
                    ) {
                        $json["error"] = array("code" => "#400", "description" => "Sorry, only PDF files are allowed.");
                        $uploadOk = 0;
                    }
                    // Check if $uploadOk is set to 0 by an error
                    if ($uploadOk != 0) {
                        if (move_uploaded_file($_FILES["pdf"]["tmp_name"], $target_file)) {
                            $pdfPath = $pdfname;
                            $json["error"] = array("code" => "#200", "description" => "The file " . htmlspecialchars(basename($_FILES["pdf"]["name"])) . " has been uploaded.");
                        } else {
                            $json["error"] = array("code" => "#400", "description" => "Sorry, there was an error uploading your file.");
                        }
                    }
                }
                if ($userAuth) {
                    if ($uploadOk == 1) {
                        $username  = $userAuth['username'];
                        $sql = "UPDATE announcements SET name = :name, url = :url, description = :description, image = :image,";
                        if ($pdfPath != "") {
                            $sql .= " pdf = :pdf,";
                        }
                        $sql .= " updated_date = NOW() WHERE id = :id";
                        $stmt = $pdoConn->prepare($sql);
                        $stmt->bindParam(":name", $title);
                        $stmt->bindParam(":url", $link);
                        $stmt->bindParam(":description", $description);
                        $stmt->bindParam(":image", $images);
                        if ($pdfPath != "") {
                            $stmt->bindParam(":pdf", $pdfPath);
                        }
                        $stmt->bindParam(":id", $id);
                        $stmt->execute();
                        $json["error"] = array("code" => "#200", "description" => "Success.");
                    } else {
                        $json["error"] = array("code" => "#400", "description" => "PDF is not uploaded");
                    }
                } else {
                    $json["error"] = array("code" => "#400", "description" => "Invalid token.");
                }
            } catch (Exception $e) {
                $json["error"] = array("code" => "#500", "description" => $e->getMessage());
            }
        } else {
            $json["error"] = array("code" => "#400", "description" => "Invalid request 1.");
        }
    } else if ($mode == 'deleteannouncement') {
        if (isset($_REQUEST['announcementid'])) {
            $id = trim(htmlspecialchars($_REQUEST['announcementid']));
            $token = trim(htmlspecialchars($_SESSION['token']));
            $email  = trim(htmlspecialchars($_SESSION['email']));
            try {
                $userAuth  = validateSessionToken($pdoConn, $token, $email);
                if ($userAuth) {
                    $sql = "DELETE FROM announcements WHERE id = :id";
                    $stmt = $pdoConn->prepare($sql);
                    $stmt->bindParam(":id", $id);
                    $stmt->execute();
                    $json["error"] = array("code" => "#200", "description" => "Success.");
                } else {
                    $json["error"] = array("code" => "#400", "description" => "Invalid token.");
                }
            } catch (Exception $e) {
                $json["error"] = array("code" => "#500", "description" => $e->getMessage());
            }
        } else {
            $json["error"] = array("code" => "#400", "description" => "Invalid request.");
        }
    } else if ($mode == 'addevent') {
        if (
            isset($_REQUEST['title']) &&
            isset($_REQUEST['youtube']) &&
            isset($_REQUEST['description']) &&
            isset($_REQUEST['images']) &&
            isset($_REQUEST['sdate']) &&
            isset($_REQUEST['edate']) &&
            isset($_REQUEST['stime']) &&
            isset($_REQUEST['etime']) &&
            isset($_REQUEST['venue']) &&
            isset($_REQUEST['department']) &&
            isset($_REQUEST['departmentname'])
        ) {
            $title = trim(htmlspecialchars($_REQUEST['title']));
            $description  = trim(htmlspecialchars($_REQUEST['description']));
            $youtube = trim(htmlspecialchars($_REQUEST['youtube']));
            $images = trim(htmlspecialchars($_REQUEST['images']));
            $sdate = trim(htmlspecialchars($_REQUEST['sdate']));
            $edate = trim(htmlspecialchars($_REQUEST['edate']));
            $stime = trim(htmlspecialchars($_REQUEST['stime']));
            $etime = trim(htmlspecialchars($_REQUEST['etime']));
            $venue = trim(htmlspecialchars($_REQUEST['venue']));
            $department = trim(htmlspecialchars($_REQUEST['department']));
            $departmentname = trim(htmlspecialchars($_REQUEST['departmentname']));

            $token = trim(htmlspecialchars($_SESSION['token']));
            $email  = trim(htmlspecialchars($_SESSION['email']));

            $sdate = $sdate . " " . $stime;
            $edate = $edate . " " . $etime;
            $pdfPath = "";
            $uploadOk = 1;

            try {
                $userAuth  = validateSessionToken($pdoConn, $token, $email);
                if ($userAuth) {
                    $username  = $userAuth['username'];
                    $sql = "INSERT INTO events (name, description, youtube, image, start_datetime, end_datetime, venue, department, department_name, created_date, updated_date) VALUES (:name, :description, :youtube, :image, :sdate, :edate, :venue, :department, :departmentname, NOW(), NOW())";
                    $stmt = $pdoConn->prepare($sql);
                    $stmt->bindParam(":name", $title);
                    $stmt->bindParam(":description", $description);
                    $stmt->bindParam(":youtube", $youtube);
                    $stmt->bindParam(":image", $images);
                    $stmt->bindParam(":sdate", $sdate);
                    $stmt->bindParam(":edate", $edate);
                    $stmt->bindParam(":venue", $venue);
                    $stmt->bindParam(":department", $department);
                    $stmt->bindParam(":departmentname", $departmentname);
                    $stmt->execute();
                    $sql = "SELECT regid FROM regid";
                    $stmt = $pdoConn->prepare($sql);
                    $stmt->execute();
                    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
                    $active = array();
                    foreach ($result as $row) {
                        $active[] = $row["regid"];
                    }
                    sendGCM(
                        "New Event Added",
                        $title,
                        $active,
                        "schedule"
                    );
                    $json["error"] = array("code" => "#200", "description" => "Success.");
                } else {
                    $json["error"] = array("code" => "#400", "description" => "Invalid token.");
                }
            } catch (Exception $e) {
                $json["error"] = array("code" => "#500", "description" => $e->getMessage());
            }
        } else {
            $json["error"] = array("code" => "#400", "description" => "Invalid request 1.");
        }
    } else if ($mode == 'editevent') {
        if (
            isset($_REQUEST['title']) &&
            isset($_REQUEST['youtube']) &&
            isset($_REQUEST['description']) &&
            isset($_REQUEST['images']) &&
            isset($_REQUEST['sdate']) &&
            isset($_REQUEST['edate']) &&
            isset($_REQUEST['stime']) &&
            isset($_REQUEST['etime']) &&
            isset($_REQUEST['venue']) &&
            isset($_REQUEST['department']) &&
            isset($_REQUEST['eventid']) &&
            isset($_REQUEST['departmentname'])
        ) {
            $title = trim(htmlspecialchars($_REQUEST['title']));
            $description  = trim(htmlspecialchars($_REQUEST['description']));
            $youtube = trim(htmlspecialchars($_REQUEST['youtube']));
            $images = trim(htmlspecialchars($_REQUEST['images']));
            $sdate = trim(htmlspecialchars($_REQUEST['sdate']));
            $edate = trim(htmlspecialchars($_REQUEST['edate']));
            $stime = trim(htmlspecialchars($_REQUEST['stime']));
            $etime = trim(htmlspecialchars($_REQUEST['etime']));
            $venue = trim(htmlspecialchars($_REQUEST['venue']));
            $department = trim(htmlspecialchars($_REQUEST['department']));
            $departmentname = trim(htmlspecialchars($_REQUEST['departmentname']));
            $eventid = trim(htmlspecialchars($_REQUEST['eventid']));
            $token = trim(htmlspecialchars($_SESSION['token']));
            $email  = trim(htmlspecialchars($_SESSION['email']));

            $sdate = $sdate . " " . $stime;
            $edate = $edate . " " . $etime;
            $pdfPath = "";
            $uploadOk = 1;

            try {
                $userAuth  = validateSessionToken($pdoConn, $token, $email);
                if ($userAuth) {
                    $username  = $userAuth['username'];
                    // $sql = "INSERT INTO events (name, description, youtube, image, start_datetime, end_datetime, venue, department, department_name, created_date, updated_date) VALUES (:name, :description, :youtube, :image, :sdate, :edate, :venue, :department, :departmentname, NOW(), NOW())";
                    // $stmt = $pdoConn->prepare($sql);
                    // $stmt->bindParam(":name", $title);
                    // $stmt->bindParam(":description", $description);
                    // $stmt->bindParam(":youtube", $youtube);
                    // $stmt->bindParam(":image", $images);
                    // $stmt->bindParam(":sdate", $sdate);
                    // $stmt->bindParam(":edate", $edate);
                    // $stmt->bindParam(":venue", $venue);
                    // $stmt->bindParam(":department", $department);
                    // $stmt->bindParam(":departmentname", $departmentname);
                    // $stmt->execute();
                    $sql = "UPDATE events SET name = :name, description = :description, youtube = :youtube, image = :image, start_datetime = :sdate, end_datetime = :edate, venue = :venue, department = :department, department_name = :departmentname, updated_date = NOW() WHERE id = :id";
                    $stmt = $pdoConn->prepare($sql);
                    $stmt->bindParam(":name", $title);

                    $stmt->bindParam(":description", $description);
                    $stmt->bindParam(":youtube", $youtube);
                    $stmt->bindParam(":image", $images);
                    $stmt->bindParam(":sdate", $sdate);
                    $stmt->bindParam(":edate", $edate);
                    $stmt->bindParam(":venue", $venue);
                    $stmt->bindParam(":department", $department);
                    $stmt->bindParam(":departmentname", $departmentname);
                    $stmt->bindParam(":id", $eventid);
                    $stmt->execute();
                    $json["error"] = array("code" => "#200", "description" => "Success.");
                } else {
                    $json["error"] = array("code" => "#400", "description" => "Invalid token.");
                }
            } catch (Exception $e) {
                $json["error"] = array("code" => "#500", "description" => $e->getMessage());
            }
        } else {
            $json["error"] = array("code" => "#400", "description" => "Invalid request 1.");
        }
    } else if ($mode == 'deleteevent') {
        if (isset($_REQUEST['eventid'])) {
            $id = trim(htmlspecialchars($_REQUEST['eventid']));
            $token = trim(htmlspecialchars($_SESSION['token']));
            $email  = trim(htmlspecialchars($_SESSION['email']));
            try {
                $userAuth  = validateSessionToken($pdoConn, $token, $email);
                if ($userAuth) {
                    $sql = "DELETE FROM events WHERE id = :id";
                    $stmt = $pdoConn->prepare($sql);
                    $stmt->bindParam(":id", $id);
                    $stmt->execute();
                    $json["error"] = array("code" => "#200", "description" => "Success.");
                } else {
                    $json["error"] = array("code" => "#400", "description" => "Invalid token.");
                }
            } catch (Exception $e) {
                $json["error"] = array("code" => "#500", "description" => $e->getMessage());
            }
        } else {
            $json["error"] = array("code" => "#400", "description" => "Invalid request.");
        }
    } else if ($mode == 'editannouncement') {
        if (isset($_REQUEST['announcementid']) && isset($_REQUEST['title']) && isset($_REQUEST['description']) && isset($_REQUEST['link']) && isset($_REQUEST['images'])) {
            $id = trim(htmlspecialchars($_REQUEST['announcementid']));
            $title = trim(htmlspecialchars($_REQUEST['title']));
            $description  = trim(htmlspecialchars($_REQUEST['description']));
            $link  = trim(htmlspecialchars($_REQUEST['link']));
            $token = trim(htmlspecialchars($_SESSION['token']));
            $email  = trim(htmlspecialchars($_SESSION['email']));
            $images = trim(htmlspecialchars($_REQUEST['images']));
            $pdfPath = "";
            $uploadOk = 1;
            try {
                $userAuth  = validateSessionToken($pdoConn, $token, $email);
                if (isset($_FILES['pdf'])) {
                    $target_dir = $uploadsDirectory . "pdf/";
                    $pdfname = uniqid() . ".pdf";
                    $target_file = $target_dir . $pdfname;
                    $uploadOk = 1;
                    $imageFileType = strtolower(pathinfo($target_file, PATHINFO_EXTENSION));
                    // Check if image file is a actual image or fake image
                    $check = getimagesize($_FILES["pdf"]["tmp_name"]);
                    if ($check !== false) {
                        $json["error"] = array("code" => "#400", "description" => "File is not a pdf.");
                        $uploadOk = 0;
                    }
                    if ($_FILES["pdf"]["size"] > 50000000) {
                        $json["error"] = array("code" => "#400", "description" => "Sorry, your file is too large.");
                        $uploadOk = 0;
                    }
                    if (
                        $imageFileType != "pdf"
                    ) {
                        $json["error"] = array("code" => "#400", "description" => "Sorry, only PDF files are allowed.");
                        $uploadOk = 0;
                    }

                    if ($uploadOk != 0) {
                        if (move_uploaded_file($_FILES["pdf"]["tmp_name"], $target_file)) {
                            $pdfPath = $pdfname;
                            $json["error"] = array("code" => "#200", "description" => "The file " . htmlspecialchars(basename($_FILES["pdf"]["name"])) . " has been uploaded.");
                        } else {
                            $json["error"] = array("code" => "#400", "description" => "Sorry, there was an error uploading your file.");
                        }
                    }
                }
                if ($userAuth) {
                    if ($uploadOk == 1) {
                        $username  = $userAuth['username'];
                        $sql = "UPDATE announcements SET name = :name, url = :url, description = :description, image = :image,";
                        if ($pdfPath != "") {
                            $sql .= " pdf = :pdf,";
                        }
                        $sql .= " updated_date = NOW() WHERE id = :id";
                        $stmt = $pdoConn->prepare($sql);
                        $stmt->bindParam(":name", $title);
                        $stmt->bindParam(":url", $link);
                        $stmt->bindParam(":description", $description);
                        $stmt->bindParam(":image", $images);
                        if ($pdfPath != "") {
                            $stmt->bindParam(":pdf", $pdfPath);
                        }
                        $stmt->bindParam(":id", $id);
                        $stmt->execute();
                        $json["error"] = array("code" => "#200", "description" => "Success.");
                    } else {
                        $json["error"] = array("code" => "#400", "description" => "PDF is not uploaded");
                    }
                } else {
                    $json["error"] = array("code" => "#400", "description" => "Invalid token.");
                }
            } catch (Exception $e) {
                $json["error"] = array("code" => "#500", "description" => $e->getMessage());
            }
        } else {
            $json["error"] = array("code" => "#400", "description" => "Invalid request 1.");
        }
    } else if ($mode == 'deleteannouncement') {
        if (isset($_REQUEST['announcementid'])) {
            $id = trim(htmlspecialchars($_REQUEST['announcementid']));
            $token = trim(htmlspecialchars($_SESSION['token']));
            $email  = trim(htmlspecialchars($_SESSION['email']));
            try {
                $userAuth  = validateSessionToken($pdoConn, $token, $email);
                if ($userAuth) {
                    $sql = "DELETE FROM announcements WHERE id = :id";
                    $stmt = $pdoConn->prepare($sql);
                    $stmt->bindParam(":id", $id);
                    $stmt->execute();
                    $json["error"] = array("code" => "#200", "description" => "Success.");
                } else {
                    $json["error"] = array("code" => "#400", "description" => "Invalid token.");
                }
            } catch (Exception $e) {
                $json["error"] = array("code" => "#500", "description" => $e->getMessage());
            }
        } else {
            $json["error"] = array("code" => "#400", "description" => "Invalid request.");
        }
    } else if ($mode == 'addgallery') {
        if (isset($_REQUEST['title']) && isset($_REQUEST['description']) && isset($_REQUEST['images'])) {
            $title = trim(htmlspecialchars($_REQUEST['title']));
            $description  = trim(htmlspecialchars($_REQUEST['description']));
            $token = trim(htmlspecialchars($_SESSION['token']));
            $email  = trim(htmlspecialchars($_SESSION['email']));
            $images = trim(htmlspecialchars($_REQUEST['images']));
            $pdfPath = "";
            $uploadOk = 1;
            try {
                $userAuth  = validateSessionToken($pdoConn, $token, $email);

                if ($userAuth) {
                    if ($uploadOk == 1) {
                        $username  = $userAuth['username'];
                        $sql = "INSERT INTO gallery (name, description, image, created_date) VALUES (:name, :description, :image, NOW())";
                        $stmt = $pdoConn->prepare($sql);
                        $stmt->bindParam(":name", $title);
                        $stmt->bindParam(":description", $description);
                        $stmt->bindParam(":image", $images);
                        $stmt->execute();

                        $sql = "SELECT regid FROM regid";
                        $stmt = $pdoConn->prepare($sql);
                        $stmt->execute();
                        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
                        $active = array();
                        foreach ($result as $row) {
                            $active[] = $row["regid"];
                        }
                        sendGCM(
                            "New Gallery Added",
                            $title,
                            $active,
                            "gallery"
                        );
                        $json["error"] = array("code" => "#200", "description" => "Success.");
                    } else {
                        $json["error"] = array("code" => "#400", "description" => "PDF is not uploaded");
                    }
                } else {
                    $json["error"] = array("code" => "#400", "description" => "Invalid token.");
                }
            } catch (Exception $e) {
                $json["error"] = array("code" => "#500", "description" => $e->getMessage());
            }
        } else {
            $json["error"] = array("code" => "#400", "description" => "Invalid request 1.");
        }
    } else if ($mode == 'editgallery') {
        if (isset($_REQUEST['galleryid']) && isset($_REQUEST['title']) && isset($_REQUEST['description']) && isset($_REQUEST['images'])) {
            $id = trim(htmlspecialchars($_REQUEST['galleryid']));
            $title = trim(htmlspecialchars($_REQUEST['title']));
            $description  = trim(htmlspecialchars($_REQUEST['description']));
            $images = trim(htmlspecialchars($_REQUEST['images']));
            try {
                $sql = "UPDATE gallery SET name = :name, description = :description, image = :image, updated_date = NOW() WHERE id = :id";
                $stmt = $pdoConn->prepare($sql);
                $stmt->bindParam(":name", $title);
                $stmt->bindParam(":description", $description);
                $stmt->bindParam(":image", $images);
                $stmt->bindParam(":id", $id);
                $stmt->execute();
                $json["error"] = array("code" => "#200", "description" => "Success");
            } catch (Exception $e) {
                $json["error"] = array("code" => "#500", "description" => $e->getMessage());
            }
        } else {
            $json["error"] = array("code" => "#400", "description" => "Invalid request 1.");
        }
    } else if ($mode == 'deletegallery') {
        if (isset($_REQUEST['galleryid'])) {
            $id = trim(htmlspecialchars($_REQUEST['galleryid']));
            $token = trim(htmlspecialchars($_SESSION['token']));
            $email  = trim(htmlspecialchars($_SESSION['email']));
            try {
                $userAuth  = validateSessionToken($pdoConn, $token, $email);
                if ($userAuth) {
                    $sql = "DELETE FROM gallery WHERE id = :id";
                    $stmt = $pdoConn->prepare($sql);
                    $stmt->bindParam(":id", $id);
                    $stmt->execute();
                    $json["error"] = array("code" => "#200", "description" => "Success.");
                } else {
                    $json["error"] = array("code" => "#400", "description" => "Invalid token.");
                }
            } catch (Exception $e) {
                $json["error"] = array("code" => "#500", "description" => $e->getMessage());
            }
        } else {
            $json["error"] = array("code" => "#400", "description" => "Invalid request.");
        }
    } else if ($mode == 'addnews') {
        if (isset($_REQUEST['title']) && isset($_REQUEST['description']) && isset($_REQUEST['images']) && isset($_REQUEST['department'])) {
            $title = trim(htmlspecialchars($_REQUEST['title']));
            $description  = trim(htmlspecialchars($_REQUEST['description']));
            $token = trim(htmlspecialchars($_SESSION['token']));
            $email  = trim(htmlspecialchars($_SESSION['email']));
            $images = trim(htmlspecialchars($_REQUEST['images']));
            $department = trim(htmlspecialchars($_REQUEST['department']));
            $departmentname = trim(htmlspecialchars($_REQUEST['departmentname']));
            $link = trim(htmlspecialchars($_REQUEST['link']));
            $pdfPath = "";
            $uploadOk = 1;
            try {
                if (isset($_FILES['pdf'])) {
                    $target_dir = $uploadsDirectory . "pdf/";
                    $pdfname = uniqid() . ".pdf";
                    $target_file = $target_dir . $pdfname;
                    $uploadOk = 1;
                    $imageFileType = strtolower(pathinfo($target_file, PATHINFO_EXTENSION));
                    // Check if image file is a actual image or fake image
                    $check = getimagesize($_FILES["pdf"]["tmp_name"]);
                    if ($check !== false) {
                        $json["error"] = array("code" => "#400", "description" => "File is not a pdf.");
                        $uploadOk = 0;
                    }
                    if ($_FILES["pdf"]["size"] > 50000000) {
                        $json["error"] = array("code" => "#400", "description" => "Sorry, your file is too large.");
                        $uploadOk = 0;
                    }
                    if (
                        $imageFileType != "pdf"
                    ) {
                        $json["error"] = array("code" => "#400", "description" => "Sorry, only PDF files are allowed.");
                        $uploadOk = 0;
                    }

                    if ($uploadOk != 0) {
                        if (move_uploaded_file($_FILES["pdf"]["tmp_name"], $target_file)) {
                            $pdfPath = $pdfname;
                            $json["error"] = array("code" => "#200", "description" => "The file " . htmlspecialchars(basename($_FILES["pdf"]["name"])) . " has been uploaded.");
                        } else {
                            $json["error"] = array("code" => "#400", "description" => "Sorry, there was an error uploading your file.");
                        }
                    }
                }

                if ($uploadOk == 1) {
                    $username  = $userAuth['username'];
                    $sql = "INSERT INTO news (name, description, image, created_date, department, departmentname,link, pdf) VALUES (:name, :description, :image, NOW(), :department, :departmentname,:link, :pdf)";
                    $stmt = $pdoConn->prepare($sql);
                    $stmt->bindParam(":name", $title);
                    $stmt->bindParam(":description", $description);
                    $stmt->bindParam(":image", $images);
                    $stmt->bindParam(":department", $department);
                    $stmt->bindParam(":departmentname", $departmentname);
                    $stmt->bindParam(":link", $link);
                    $stmt->bindParam(":pdf", $pdfPath);
                    $stmt->execute();

                    if ($department == "common") {
                        $sql = "SELECT regid FROM regid";
                        $stmt = $pdoConn->prepare($sql);
                        $stmt->execute();
                        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
                        $active = array();
                        foreach ($result as $row) {
                            $active[] = $row["regid"];
                        }
                        sendGCM(
                            "New News Added",
                            $title,
                            $active,
                            "news"
                        );
                    }

                    $json["error"] = array("code" => "#200", "description" => "Success.");
                } else {
                    $json["error"] = array("code" => "#400", "description" => "PDF is not uploaded");
                }
            } catch (Exception $e) {
                $json["error"] = array("code" => "#500", "description" => $e->getMessage());
            }
        } else {
            $json["error"] = array("code" => "#400", "description" => "Invalid request 1.");
        }
    } else if ($mode == 'editnews') {
        if (isset($_REQUEST['newsid']) && isset($_REQUEST['title']) && isset($_REQUEST['description']) && isset($_REQUEST['images']) && isset($_REQUEST['department'])) {
            $id = trim(htmlspecialchars($_REQUEST['newsid']));
            $title = trim(htmlspecialchars($_REQUEST['title']));
            $description  = trim(htmlspecialchars($_REQUEST['description']));
            $token = trim(htmlspecialchars($_SESSION['token']));
            $email  = trim(htmlspecialchars($_SESSION['email']));
            $images = trim(htmlspecialchars($_REQUEST['images']));
            $department = trim(htmlspecialchars($_REQUEST['department']));
            $departmentname = trim(htmlspecialchars($_REQUEST['departmentname']));
            $link = trim(htmlspecialchars($_REQUEST['link'] ?? ""));

            $pdfPath = "";
            $uploadOk = 1;

            try {
                if (isset($_FILES['pdf'])) {
                    $target_dir = $uploadsDirectory . "pdf/";
                    $pdfname = uniqid() . ".pdf";
                    $target_file = $target_dir . $pdfname;
                    $uploadOk = 1;
                    $imageFileType = strtolower(pathinfo($target_file, PATHINFO_EXTENSION));
                    // Check if image file is a actual image or fake image
                    $check = getimagesize($_FILES["pdf"]["tmp_name"]);
                    if ($check !== false) {
                        $json["error"] = array("code" => "#400", "description" => "File is not a pdf.");
                        $uploadOk = 0;
                    }
                    if ($_FILES["pdf"]["size"] > 50000000) {
                        $json["error"] = array("code" => "#400", "description" => "Sorry, your file is too large.");
                        $uploadOk = 0;
                    }
                    if (
                        $imageFileType != "pdf"
                    ) {
                        $json["error"] = array("code" => "#400", "description" => "Sorry, only PDF files are allowed.");
                        $uploadOk = 0;
                    }

                    if ($uploadOk != 0) {
                        if (move_uploaded_file($_FILES["pdf"]["tmp_name"], $target_file)) {
                            $pdfPath = $pdfname;
                            $json["error"] = array("code" => "#200", "description" => "The file " . htmlspecialchars(basename($_FILES["pdf"]["name"])) . " has been uploaded.");
                        } else {
                            $json["error"] = array("code" => "#400", "description" => "Sorry, there was an error uploading your file.");
                        }
                    }
                }
                $sql = "UPDATE news SET name = :name, description = :description, image = :image,  department = :department, departmentname = :departmentname, link = :link,  updated_date = NOW()";
                if ($pdfPath != "") {
                    $sql .= ", pdf = :pdf";
                }
                $sql .= " WHERE id = :id";
                $stmt = $pdoConn->prepare($sql);
                $stmt->bindParam(":name", $title);
                $stmt->bindParam(":description", $description);
                $stmt->bindParam(":image", $images);
                $stmt->bindParam(":link", $link);
                $stmt->bindParam(":department", $department);
                $stmt->bindParam(":departmentname", $departmentname);
                if ($pdfPath != "") {
                    $stmt->bindParam(":pdf", $pdfPath);
                }
                $stmt->bindParam(":id", $id);
                $stmt->execute();
                $json["error"] = array("code" => "#200", "description" => "Success");
            } catch (Exception $e) {
                $json["error"] = array("code" => "#500", "description" => $e->getMessage());
            }
        } else {
            $json["error"] = array("code" => "#400", "description" => "Invalid request 1.");
        }
    } else if ($mode == 'deletenews') {
        if (isset($_REQUEST['eventid'])) {
            $id = trim(htmlspecialchars($_REQUEST['eventid']));
            $token = trim(htmlspecialchars($_SESSION['token']));
            $email  = trim(htmlspecialchars($_SESSION['email']));
            try {
                $userAuth  = validateSessionToken($pdoConn, $token, $email);
                if ($userAuth) {
                    $sql = "DELETE FROM news WHERE id = :id";
                    $stmt = $pdoConn->prepare($sql);
                    $stmt->bindParam(":id", $id);
                    $stmt->execute();
                    $json["error"] = array("code" => "#200", "description" => "Success.");
                } else {
                    $json["error"] = array("code" => "#400", "description" => "Invalid token.");
                }
            } catch (Exception $e) {
                $json["error"] = array("code" => "#500", "description" => $e->getMessage());
            }
        } else {
            $json["error"] = array("code" => "#400", "description" => "Invalid request.");
        }
    } else if ($mode == 'addJob') {
        if (isset($_REQUEST['title']) && isset($_REQUEST['description']) && isset($_REQUEST['images'])) {
            $title = trim(htmlspecialchars($_REQUEST['title']));
            $description  = trim(htmlspecialchars($_REQUEST['description']));
            $token = trim(htmlspecialchars($_SESSION['token']));
            $email  = trim(htmlspecialchars($_SESSION['email']));
            $images = trim(htmlspecialchars($_REQUEST['images']));
            $link = trim(htmlspecialchars($_REQUEST['link']));
            $pdfPath = "";
            $uploadOk = 1;
            try {
                if (isset($_FILES['pdf'])) {
                    $target_dir = $uploadsDirectory . "pdf/";
                    $pdfname = uniqid() . ".pdf";
                    $target_file = $target_dir . $pdfname;
                    $uploadOk = 1;
                    $imageFileType = strtolower(pathinfo($target_file, PATHINFO_EXTENSION));
                    // Check if image file is a actual image or fake image
                    $check = getimagesize($_FILES["pdf"]["tmp_name"]);
                    if ($check !== false) {
                        $json["error"] = array("code" => "#400", "description" => "File is not a pdf.");
                        $uploadOk = 0;
                    }
                    if ($_FILES["pdf"]["size"] > 50000000) {
                        $json["error"] = array("code" => "#400", "description" => "Sorry, your file is too large.");
                        $uploadOk = 0;
                    }
                    if (
                        $imageFileType != "pdf"
                    ) {
                        $json["error"] = array("code" => "#400", "description" => "Sorry, only PDF files are allowed.");
                        $uploadOk = 0;
                    }

                    if ($uploadOk != 0) {
                        if (move_uploaded_file($_FILES["pdf"]["tmp_name"], $target_file)) {
                            $pdfPath = $pdfname;
                            $json["error"] = array("code" => "#200", "description" => "The file " . htmlspecialchars(basename($_FILES["pdf"]["name"])) . " has been uploaded.");
                        } else {
                            $json["error"] = array("code" => "#400", "description" => "Sorry, there was an error uploading your file.");
                        }
                    }
                }

                if ($uploadOk == 1) {
                    $username  = $userAuth['username'];
                    $sql = "INSERT INTO jobs (name, description, image, created_date,link, pdf) VALUES (:name, :description, :image, NOW(),:link, :pdf)";
                    $stmt = $pdoConn->prepare($sql);
                    $stmt->bindParam(":name", $title);
                    $stmt->bindParam(":description", $description);
                    $stmt->bindParam(":image", $images);
                    $stmt->bindParam(":link", $link);
                    $stmt->bindParam(":pdf", $pdfPath);
                    $stmt->execute();

                    $sql = "SELECT regid FROM regid";
                    $stmt = $pdoConn->prepare($sql);
                    $stmt->execute();
                    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
                    $active = array();
                    foreach ($result as $row) {
                        $active[] = $row["regid"];
                    }
                    sendGCM(
                        "New Job Offer Added",
                        $title,
                        $active,
                        "jobs"
                    );
                    $json["error"] = array("code" => "#200", "description" => "Success.");
                } else {
                    $json["error"] = array("code" => "#400", "description" => "PDF is not uploaded");
                }
            } catch (Exception $e) {
                $json["error"] = array("code" => "#500", "description" => $e->getMessage());
            }
        } else {
            $json["error"] = array("code" => "#400", "description" => "Invalid request 1.");
        }
    } else if ($mode == 'editJob') {
        if (isset($_REQUEST['jobid']) && isset($_REQUEST['title']) && isset($_REQUEST['description']) && isset($_REQUEST['images'])) {
            $id = trim(htmlspecialchars($_REQUEST['jobid']));
            $title = trim(htmlspecialchars($_REQUEST['title']));
            $description  = trim(htmlspecialchars($_REQUEST['description']));
            $token = trim(htmlspecialchars($_SESSION['token']));
            $email  = trim(htmlspecialchars($_SESSION['email']));
            $images = trim(htmlspecialchars($_REQUEST['images']));
            $link = trim(htmlspecialchars($_REQUEST['link'] ?? ""));

            $pdfPath = "";
            $uploadOk = 1;

            try {
                if (isset($_FILES['pdf'])) {
                    $target_dir = $uploadsDirectory . "pdf/";
                    $pdfname = uniqid() . ".pdf";
                    $target_file = $target_dir . $pdfname;
                    $uploadOk = 1;
                    $imageFileType = strtolower(pathinfo($target_file, PATHINFO_EXTENSION));
                    // Check if image file is a actual image or fake image
                    $check = getimagesize($_FILES["pdf"]["tmp_name"]);
                    if ($check !== false) {
                        $json["error"] = array("code" => "#400", "description" => "File is not a pdf.");
                        $uploadOk = 0;
                    }
                    if ($_FILES["pdf"]["size"] > 50000000) {
                        $json["error"] = array("code" => "#400", "description" => "Sorry, your file is too large.");
                        $uploadOk = 0;
                    }
                    if (
                        $imageFileType != "pdf"
                    ) {
                        $json["error"] = array("code" => "#400", "description" => "Sorry, only PDF files are allowed.");
                        $uploadOk = 0;
                    }

                    if ($uploadOk != 0) {
                        if (move_uploaded_file($_FILES["pdf"]["tmp_name"], $target_file)) {
                            $pdfPath = $pdfname;
                            $json["error"] = array("code" => "#200", "description" => "The file " . htmlspecialchars(basename($_FILES["pdf"]["name"])) . " has been uploaded.");
                        } else {
                            $json["error"] = array("code" => "#400", "description" => "Sorry, there was an error uploading your file.");
                        }
                    }
                }
                $sql = "UPDATE jobs SET name = :name, description = :description, image = :image, link = :link,  updated_date = NOW()";
                if ($pdfPath != "") {
                    $sql .= ", pdf = :pdf";
                }
                $sql .= " WHERE id = :id";
                $stmt = $pdoConn->prepare($sql);
                $stmt->bindParam(":name", $title);
                $stmt->bindParam(":description", $description);
                $stmt->bindParam(":image", $images);
                $stmt->bindParam(":link", $link);
                if ($pdfPath != "") {
                    $stmt->bindParam(":pdf", $pdfPath);
                }
                $stmt->bindParam(":id", $id);
                $stmt->execute();
                $json["error"] = array("code" => "#200", "description" => "Success");
            } catch (Exception $e) {
                $json["error"] = array("code" => "#500", "description" => $e->getMessage());
            }
        } else {
            $json["error"] = array("code" => "#400", "description" => "Invalid request 1.");
        }
    } else if ($mode == 'deletejobs') {
        if (isset($_REQUEST['eventid'])) {
            $id = trim(htmlspecialchars($_REQUEST['eventid']));
            $token = trim(htmlspecialchars($_SESSION['token']));
            $email  = trim(htmlspecialchars($_SESSION['email']));
            try {
                $userAuth  = validateSessionToken($pdoConn, $token, $email);
                if ($userAuth) {
                    $sql = "DELETE FROM jobs WHERE id = :id";
                    $stmt = $pdoConn->prepare($sql);
                    $stmt->bindParam(":id", $id);
                    $stmt->execute();
                    $json["error"] = array("code" => "#200", "description" => "Success.");
                } else {
                    $json["error"] = array("code" => "#400", "description" => "Invalid token.");
                }
            } catch (Exception $e) {
                $json["error"] = array("code" => "#500", "description" => $e->getMessage());
            }
        } else {
            $json["error"] = array("code" => "#400", "description" => "Invalid request.");
        }
    } else if ($mode == 'getannouncement') {
        $sql = "SELECT * FROM announcements";
        $stmt = $pdoConn->prepare($sql);
        $stmt->execute();
        $result = $stmt->fetchAll();
        $json["data"] = array();
        for ($i = 0; $i < count($result); $i++) {
            $image = explode(",", $result[$i]["image"]);
            $image = array_filter($image);
            $imgArr = array();
            for ($j = 0; $j < count($image); $j++) {
                $imgArr[] = $baseUrl . "uploads/images/" . $image[$j];
            }
            $json["data"][] = array(
                "id" => $result[$i]["id"],
                "name" => htmlspecialchars_decode($result[$i]["name"]),
                "url" => $result[$i]["url"],
                "description" => htmlspecialchars_decode($result[$i]["description"]),
                "pdf" => $result[$i]["pdf"],
                "image" => $imgArr,
                "created_date" => strtotime($result[$i]["created_date"]) * 1000,
            );
        }
        $json["error"] = array("code" => "#200", "description" => "Success.");
    } else if ($mode == 'getnews') {
        if (isset($_REQUEST['department'])) {
            $department = trim(htmlspecialchars($_REQUEST['department']));
            $sql = "SELECT * FROM news WHERE department = :department";
            $stmt = $pdoConn->prepare($sql);
            $stmt->bindParam(":department", $department);
            $stmt->execute();
            $result = $stmt->fetchAll();
            $json["data"] = array();
            for ($i = 0; $i < count($result); $i++) {
                $image = explode(",", $result[$i]["image"]);
                $image = array_filter($image);
                $imgArr = array();
                for ($j = 0; $j < count($image); $j++) {
                    $imgArr[] = $baseUrl . "uploads/images/" . $image[$j];
                }
                $json["data"][] = array(
                    "id" => $result[$i]["id"],
                    "name" => htmlspecialchars_decode($result[$i]["name"]),
                    "description" => htmlspecialchars_decode($result[$i]["description"]),
                    "image" => $imgArr,
                    "pdf" => $result[$i]["pdf"],
                    "url" => $result[$i]["link"],
                    "created_date" => strtotime($result[$i]["created_date"]) * 1000,
                );
            }
            $json["error"] = array("code" => "#200", "description" => "Success.");
        } else {
            $json["error"] = array("code" => "#400", "description" => "Invalid request.");
        }
    } else if ($mode == 'getgallery') {
        $sql = "SELECT * FROM gallery";
        $stmt = $pdoConn->prepare($sql);
        $stmt->execute();
        $result = $stmt->fetchAll();
        $json["data"] = array();
        for ($i = 0; $i < count($result); $i++) {
            $image = explode(",", $result[$i]["image"]);
            $image = array_filter($image);
            $imgArr = array();
            for ($j = 0; $j < count($image); $j++) {
                $imgArr[] = $baseUrl . "uploads/images/" . $image[$j];
            }
            $json["data"][] = array(
                "id" => $result[$i]["id"],
                "name" => htmlspecialchars_decode($result[$i]["name"]),
                "description" => htmlspecialchars_decode($result[$i]["description"]),
                "image" => $imgArr,
                "created_date" => strtotime($result[$i]["created_date"]) * 1000,
            );
        }
    } else if ($mode == 'getJobs') {
        $sql = "SELECT * FROM jobs";
        $stmt = $pdoConn->prepare($sql);
        $stmt->execute();
        $result = $stmt->fetchAll();
        $json["data"] = array();
        for ($i = 0; $i < count($result); $i++) {
            $image = explode(",", $result[$i]["image"]);
            $image = array_filter($image);
            $imgArr = array();
            for ($j = 0; $j < count($image); $j++) {
                $imgArr[] = $baseUrl . "uploads/images/" . $image[$j];
            }
            $json["data"][] = array(
                "id" => $result[$i]["id"],
                "name" => htmlspecialchars_decode($result[$i]["name"]),
                "description" => htmlspecialchars_decode($result[$i]["description"]),
                "image" => $imgArr,
                "pdf" => $result[$i]["pdf"],
                "url" => $result[$i]["link"],
                "created_date" => strtotime($result[$i]["created_date"]) * 1000,
            );
        }
    } else if ($mode == 'getevents') {
        if (isset($_REQUEST['department'])) {
            $department = trim(htmlspecialchars($_REQUEST['department']));
            $sql = "SELECT * FROM events WHERE department = :department";
            $stmt = $pdoConn->prepare($sql);
            $stmt->bindParam(":department", $department);
            $stmt->execute();
            $result = $stmt->fetchAll();
            $json["data"] = array();
            for ($i = 0; $i < count($result); $i++) {
                $image = explode(",", $result[$i]["image"]);
                $image = array_filter($image);
                $imgArr = array();
                for ($j = 0; $j < count($image); $j++) {
                    $imgArr[] = $baseUrl . "uploads/images/" . $image[$j];
                }
                $json["data"][] = array(
                    "id" => $result[$i]["id"],
                    "name" => htmlspecialchars_decode($result[$i]["name"]),
                    "description" => htmlspecialchars_decode($result[$i]["description"]),
                    "image" => $imgArr,
                    "url" => $result[$i]["youtube"],
                    "venue" => $result[$i]["venue"],
                    "sdatetime" => strtotime($result[$i]["start_datetime"]) * 1000,
                    "edatetime" => strtotime($result[$i]["end_datetime"]) * 1000,
                    "created_date" => strtotime($result[$i]["created_date"]) * 1000,
                );
            }
            $json["error"] = array("code" => "#200", "description" => "Success.");
        } else {
            $json["error"] = array("code" => "#400", "description" => "Invalid request.");
        }
    } else if ($mode == "getsingleevent") {
        $id = trim(htmlspecialchars($_REQUEST['eventid']));
        $sql = "SELECT * FROM events WHERE id = :id";
        $stmt = $pdoConn->prepare($sql);
        $stmt->bindParam(":id", $id);
        $stmt->execute();
        $result = $stmt->fetch();
        if ($result) {
            $image = explode(",", $result["image"]);
            $image = array_filter($image);
            $imgArr = array();
            for ($j = 0; $j < count($image); $j++) {
                $imgArr[] = $baseUrl . "uploads/images/" . $image[$j];
            }
            $json["data"] = array(
                "id" => $result["id"],
                "name" => htmlspecialchars_decode($result["name"]),
                "description" => htmlspecialchars_decode($result["description"]),
                "image" => $imgArr,
                "url" => $result["youtube"],
                "venue" => $result["venue"],
                "sdatetime" => strtotime($result["start_datetime"]) * 1000,
                "edatetime" => strtotime($result["end_datetime"]) * 1000,
                "created_date" => strtotime($result["created_date"]) * 1000,
            );
        } else {
            $json["error"] = array("code" => "#400", "description" => "This event is not available.");
        }
    } else if ($mode == 'getschedule') {
        $sql = "SELECT * FROM events";
        $stmt = $pdoConn->prepare($sql);
        $stmt->bindParam(":department", $department);
        $stmt->execute();
        $result = $stmt->fetchAll();
        $json["data"] = array();

        $sql = "SELECT * FROM admins WHERE role='subadmin'";
        $stmt = $pdoConn->prepare($sql);
        $stmt->execute();
        $result1 = $stmt->fetchAll();

        for ($i = 0; $i < count($result); $i++) {
            $adminId = $result[$i]["department"];
            $adminName = $result[$i]["department_name"];
            $adminColor = "#000000";
            for ($j = 0; $j < count($result1); $j++) {
                if ($result1[$j]["id"] == $adminId) {
                    $adminColor = $result1[$j]["color"];
                }
            }
            $json["data"][] = array(
                "id" => $result[$i]["id"],
                "name" => htmlspecialchars_decode($result[$i]["name"]),
                "startdatetime" => strtotime($result[$i]["start_datetime"]) * 1000,
                "enddatetime" => strtotime($result[$i]["end_datetime"]) * 1000,
                "departmentid" => $result[$i]["department"],
                "departmentname" => $adminName,
                "color" => $adminColor,
            );
        }
        $json["error"] = array("code" => "#200", "description" => "Success.");
    } else if ($mode == 'getstaffs') {
        if (isset($_REQUEST['department'])) {
            $department = trim(htmlspecialchars($_REQUEST['department']));
            $sql = "SELECT * FROM staffs WHERE departmentid = :department";
            $stmt = $pdoConn->prepare($sql);
            $stmt->bindParam(":department", $department);
            $stmt->execute();
            $result = $stmt->fetchAll();
            $json["data"] = array();
            for ($i = 0; $i < count($result); $i++) {
                $json["data"][] = $result[$i];
            }
            $json["error"] = array("code" => "#200", "description" => "Success.");
        } else {
            $json["error"] = array("code" => "#400", "description" => "Invalid request.");
        }
    } else if ($mode == 'addslider') {
        $images = $_REQUEST['images'];
        $images = explode(",", $images);
        file_put_contents($baseDirectory . 'json/slider.json', json_encode($images));
        $json["error"] = array("code" => "#200", "description" => "Success.");
    } else if ($mode == 'getslider') {
        $json["error"] = array("code" => "#200", "description" => "Success.");
        $images = json_decode(file_get_contents($baseDirectory . 'json/slider.json'));
        $json["data"] = $images;
    } else if ($mode == "sendNotification") {
        if (isset($_REQUEST["title"]) && isset($_REQUEST["message"])) {
            $title = $_REQUEST["title"];
            $message = $_REQUEST["message"];
            $sql = "SELECT regid FROM regid";
            $stmt = $pdoConn->prepare($sql);
            $stmt->execute();
            $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $active = array();
            foreach ($result as $row) {
                $active[] = $row["regid"];
            }
            sendGCM($title, $message, $active, "home");
        } else {
            $json["error"] = array("code" => "#400", "description" => "Name, category and content are required.");
        }
    } else if ($mode == "updateregid") {
        $regid = $_REQUEST["regid"] ?? "";
        $version = $_REQUEST["version"] ?? "1.0.0 (1)";
        $sql  = "SELECT * FROM regid WHERE regid = :regid";
        $stmt = $pdoConn->prepare($sql);
        $stmt->bindParam(":regid", $regid);
        $stmt->execute();
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($result) {
            $date = $result["created_at"];
            $status = "active";
            $sql = "UPDATE regid SET version = :version, created_at = :created_at, status = :status WHERE regid = :regid";
            $stmt = $pdoConn->prepare($sql);
            $stmt->bindParam(":version", $version);
            $stmt->bindParam(":created_at", $date);
            $stmt->bindParam(":status", $status);
            $stmt->bindParam(":regid", $regid);
            $stmt->execute();
        } else {
            $date = date("Y-m-d H:i:s");
            $status = "active";
            $sql = "INSERT INTO regid (regid, version, created_at, status) VALUES (:regid, :version, :created_at, :status)";
            $stmt = $pdoConn->prepare($sql);
            $stmt->bindParam(":regid", $regid);
            $stmt->bindParam(":version", $version);
            $stmt->bindParam(":created_at", $date);
            $stmt->bindParam(":status", $status);
            $stmt->execute();
        }
        track($pdoConn, $version);
    } else if ($mode == "getAllDepartments") {
        $sql = "SELECT * FROM admins WHERE role='subadmin'";
        $stmt = $pdoConn->prepare($sql);
        $stmt->execute();
        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
        for ($i = 0; $i < count($result); $i++) {
            unset($result[$i]["password"]);
            unset($result[$i]["role"]);
            unset($result[$i]["created_at"]);
            unset($result[$i]["updated_at"]);
            if ($result[$i]["departmenttype"] == "1") {
                $json["data"]['Aided Departments'][] = $result[$i];
            } else if ($result[$i]["departmenttype"] == "2") {
                $json["data"]['Self Financed Departments'][] = $result[$i];
            } else if ($result[$i]["departmenttype"] == "3") {
                $json["data"]['Extension Activities'][] = $result[$i];
            } else if ($result[$i]["departmenttype"] == "4") {
                $json["data"]['Clubs & Other Forums'][] = $result[$i];
            }
        }
    } else if ($mode == "addadmin") {
        if (
            isset($_REQUEST['name']) &&
            isset($_REQUEST['email']) &&
            isset($_REQUEST['phone']) &&
            isset($_REQUEST['password']) &&
            isset($_REQUEST['type']) &&
            isset($_REQUEST['color']) &&
            isset($_REQUEST['profile'])
        ) {
            $name = $_REQUEST['name'];
            $email = $_REQUEST['email'];
            $phone = $_REQUEST['phone'];
            $password = $_REQUEST['password'];
            $type = $_REQUEST['type'];
            $color = $_REQUEST['color'] ?? "#000000";
            $profile = $_REQUEST['profile'];
            $index = $_REQUEST['index'];
            $emailRegex = "/^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/";
            $phoneRegex = "/^[0-9]{10}$/";
            if (!preg_match($emailRegex, $email)) {
                $json["error"] = array("code" => "#400", "description" => "Invalid email.");
            } elseif (!preg_match($phoneRegex, $phone)) {
                $json["error"] = array("code" => "#400", "description" => "Invalid phone number.");
            } else {
                $sql = "SELECT * FROM admins WHERE email = :email OR phone = :phone";
                $stmt = $pdoConn->prepare($sql);
                $stmt->bindParam(":email", $email);
                $stmt->bindParam(":phone", $phone);
                $stmt->execute();
                $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
                if (count($result) > 0) {
                    $json["error"] = array("code" => "#400", "description" => "Email or phone already exists.");
                } else {
                    $role = "subadmin";
                    $date = date("Y-m-d H:i:s");
                    $sql = "INSERT INTO admins (
                                email, fullname, password, role, created_at, updated_at, phone, profile, departmenttype, color, sindex
                            ) VALUES (
                                :email, :fullname, :password, :role, :created_at, :updated_at, :phone, :profile, :departmenttype, :color, :index
                            )";
                    $stmt = $pdoConn->prepare($sql);
                    $stmt->bindParam(":email", $email);
                    $stmt->bindParam(":fullname", $name);
                    $stmt->bindParam(":password", $password);
                    $stmt->bindParam(":role", $role);
                    $stmt->bindParam(":created_at", $date);
                    $stmt->bindParam(":updated_at", $date);
                    $stmt->bindParam(":phone", $phone);
                    $stmt->bindParam(":profile", $profile);
                    $stmt->bindParam(":departmenttype", $type);
                    $stmt->bindParam(":color", $color);
                    $stmt->bindParam(":index", $index);
                    $stmt->execute();
                    $json["error"] = array("code" => "#200", "description" => "Success.");
                }
            }
        } else {
            $json["error"] = array("code" => "#400", "description" => "Name, email, phone, password, type and profile are required.");
        }
    } else if ($mode == 'updateadmin') {
        $adminid = $_REQUEST['adminid'];
        $name = $_REQUEST['name'];
        $email = $_REQUEST['email'];
        $phone = $_REQUEST['phone'];
        $password = $_REQUEST['password'];
        $type = $_REQUEST['type'];
        $profile = $_REQUEST['profile'];
        $index = $_REQUEST['index'];
        $color = $_REQUEST['color'] ?? "#000000";
        $emailRegex = "/^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/";
        $phoneRegex = "/^[0-9]{10}$/";
        if (!preg_match($emailRegex, $email)) {
            $json["error"] = array("code" => "#400", "description" => "Invalid email.");
        } elseif (!preg_match($phoneRegex, $phone)) {
            $json["error"] = array("code" => "#400", "description" => "Invalid phone number.");
        } else {
            $sql = "SELECT * FROM admins WHERE (email = :email OR phone = :phone) AND id != :id";
            $stmt = $pdoConn->prepare($sql);
            $stmt->bindParam(":email", $email);
            $stmt->bindParam(":phone", $phone);
            $stmt->bindParam(":id", $adminid);
            $stmt->execute();
            $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $date = date("Y-m-d H:i:s");
            $sql = "UPDATE admins SET email = :email, fullname = :fullname, phone = :phone, departmenttype = :departmenttype, profile = :profile, updated_at = :updated_at, color = :color, sindex = :sindex WHERE id = :id";
            $stmt = $pdoConn->prepare($sql);
            $stmt->bindParam(":email", $email);
            $stmt->bindParam(":fullname", $name);
            $stmt->bindParam(":phone", $phone);
            $stmt->bindParam(":departmenttype", $type);
            $stmt->bindParam(":profile", $profile);
            $stmt->bindParam(":updated_at", $date);
            $stmt->bindParam(":color", $color);
            $stmt->bindParam(":id", $adminid);
            $stmt->bindParam(":sindex", $index);
            $stmt->execute();
            $json["error"] = array("code" => "#200", "description" => "Success.");
        }
    } else if ($mode == 'deleteadmin') {
        $adminid = $_REQUEST['adminid'];
        $sql = "DELETE FROM admins WHERE id = :id";
        $stmt = $pdoConn->prepare($sql);
        $stmt->bindParam(":id", $adminid);
        $stmt->execute();
        $json["error"] = array("code" => "#200", "description" => "Success.");
    } else if ($mode == 'deletepdf') {
        if (isset($_REQUEST['staffid'])) {
            $adminid = $_REQUEST['staffid'];
            $sql = "UPDATE staffs SET pdf = '' WHERE id = :id";
            $stmt = $pdoConn->prepare($sql);
            $stmt->bindParam(":id", $adminid);
            $stmt->execute();
            $json["error"] = array("code" => "#200", "description" => "Success.");
        } else if (isset($_REQUEST['announcementid'])) {
            $adminid = $_REQUEST['announcementid'];
            $sql = "UPDATE announcements SET pdf = '' WHERE id = :id";
            $stmt = $pdoConn->prepare($sql);
            $stmt->bindParam(":id", $adminid);
            $stmt->execute();
            $json["error"] = array("code" => "#200", "description" => "Success.");
        } else if (isset($_REQUEST['eventid'])) {
            $adminid = $_REQUEST['eventid'];
            $sql = "UPDATE events SET pdf = '' WHERE id = :id";
            $stmt = $pdoConn->prepare($sql);
            $stmt->bindParam(":id", $adminid);
            $stmt->execute();
            $json["error"] = array("code" => "#200", "description" => "Success.");
        } else {
            $json["error"] = array("code" => "#400", "description" => "Invalid request.");
        }
    } else if ($mode == "addadminabout") {
        $adminid = $_REQUEST['adminid'];
        $content = $_REQUEST['content'];
        $directory = $baseDirectory . "/json/about/";
        if (!file_exists($directory)) {
            mkdir($directory, 0777, true);
        }
        $filename = $directory . $adminid . ".json";
        $content = json_encode(array(
            "content" => $content
        ));
        file_put_contents($filename, $content);
        $json["error"] = array("code" => "#200", "description" => "Success.");
    } else if ($mode == "addadminstaffs") {
        $adminid = $_REQUEST['adminid'];
        $content = $_REQUEST['content'];
        $directory = $baseDirectory . "/json/staff/";
        if (!file_exists($directory)) {
            mkdir($directory, 0777, true);
        }
        $filename = $directory . $adminid . ".json";
        $content = json_encode(array(
            "content" => $content
        ));
        file_put_contents($filename, $content);
        $json["error"] = array("code" => "#200", "description" => "Success.");
    } else if ($mode == "addadminsocial") {
        $facebook = $_REQUEST['facebook'];
        $twitter = $_REQUEST['twitter'];
        $instagram = $_REQUEST['instagram'];
        $linkedin = $_REQUEST['linkedin'];
        $youtube = $_REQUEST['youtube'];
        $adminid = $_REQUEST['adminid'];

        $directory = $baseDirectory . "/json/social/";
        if (!file_exists($directory)) {
            mkdir($directory, 0777, true);
        }
        $filename = $directory . $adminid . ".json";
        $content = json_encode(array(
            "facebook" => $facebook,
            "twitter" => $twitter,
            "instagram" => $instagram,
            "linkedin" => $linkedin,
            "youtube" => $youtube
        ),);
        file_put_contents($filename, $content);
        $json["error"] = array("code" => "#200", "description" => "Success.");
    } else if ($mode == "getsocial") {
        if (isset($_REQUEST['department'])) {
            $department = $_REQUEST['department'];
            $directory = $baseDirectory . "/json/social/";
            $filename = $directory . $department . ".json";
            if (file_exists($filename)) {
                $content = file_get_contents($filename);
                $json["data"] = json_decode($content, true);
            } else {
                $data = array(
                    "facebook" => "",
                    "twitter" => "",
                    "instagram" => "",
                    "linkedin" => "",
                    "youtube" => ""
                );
            }
            $json["error"] = array("code" => "#200", "description" => "Success.");
        }
    } else if ($mode == "addstaff") {
        if (
            isset($_REQUEST['name']) &&
            isset($_REQUEST['index']) &&
            isset($_REQUEST['age']) &&
            isset($_REQUEST['position']) &&
            isset($_REQUEST['qualificaiton']) &&
            isset($_REQUEST['department']) &&
            isset($_REQUEST['gender']) &&
            isset($_REQUEST['type']) &&
            isset($_REQUEST['profile']) &&
            isset($_REQUEST['phone'])
        ) {
            $name = $_REQUEST['name'];
            $index = $_REQUEST['index'];
            $age = $_REQUEST['age'];
            $position = $_REQUEST['position'];
            $qualificaiton = $_REQUEST['qualificaiton'];
            $phone = $_REQUEST['phone'];
            $gender = $_REQUEST['gender'];
            $type = $_REQUEST['type'];
            $pdfPath = "";
            $profile = $_REQUEST['profile'] ?? "";
            $department = $_REQUEST['department'];

            if ($department == "iqac") {
                $departmentid = "iqac";
                $departmentname = "IQAC";
            } else {
                $sql = "SELECT * FROM admins WHERE id = :id";
                $stmt = $pdoConn->prepare($sql);
                $stmt->bindParam(":id", $department);
                $stmt->execute();
                $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

                $departmentid = $result[0]['id'];
                $departmentname = $result[0]['fullname'];
            }
            if (!preg_match($phoneRegex, $phone)) {
                $json["error"] = array("code" => "#400", "description" => "Invalid phone number.");
            } else {
                if (isset($_FILES['pdf'])) {
                    $target_dir = $uploadsDirectory . "pdf/";
                    $pdfname = uniqid() . ".pdf";
                    $target_file = $target_dir . $pdfname;
                    $uploadOk = 1;
                    $imageFileType = strtolower(pathinfo($target_file, PATHINFO_EXTENSION));
                    // Check if image file is a actual image or fake image
                    $check = getimagesize($_FILES["pdf"]["tmp_name"]);
                    if ($check !== false) {
                        $json["error"] = array("code" => "#400", "description" => "File is not a pdf.");
                        $uploadOk = 0;
                    }
                    if ($_FILES["pdf"]["size"] > 50000000) {
                        $json["error"] = array("code" => "#400", "description" => "Sorry, your file is too large.");
                        $uploadOk = 0;
                    }
                    if (
                        $imageFileType != "pdf"
                    ) {
                        $json["error"] = array("code" => "#400", "description" => "Sorry, only PDF files are allowed.");
                        $uploadOk = 0;
                    }

                    if ($uploadOk != 0) {
                        if (move_uploaded_file($_FILES["pdf"]["tmp_name"], $target_file)) {
                            $pdfPath = $pdfname;
                            $json["error"] = array("code" => "#200", "description" => "The file " . htmlspecialchars(basename($_FILES["pdf"]["name"])) . " has been uploaded.");
                        } else {
                            $json["error"] = array("code" => "#400", "description" => "Sorry, there was an error uploading your file.");
                        }
                    }
                }

                $sql = "INSERT INTO staffs (
                            name,sindex,position,qualification,phone,age,created_at, departmentid, departmentname, gender, type, pdf, image
                        ) VALUES (
                            :name,:sindex,:position,:qualification,:phone,:age,:created_at, :departmentid, :departmentname, :gender, :type, :pdf, :image
                        )";
                $stmt = $pdoConn->prepare($sql);
                $stmt->bindParam(":name", $name);
                $stmt->bindParam(":sindex", $index);
                $stmt->bindParam(":position", $position);
                $stmt->bindParam(":qualification", $qualificaiton);
                $stmt->bindParam(":phone", $phone);
                $stmt->bindParam(":age", $age);
                $stmt->bindParam(":created_at", $datetime);
                $stmt->bindParam(":departmentid", $departmentid);
                $stmt->bindParam(":departmentname", $departmentname);
                $stmt->bindParam(":gender", $gender);
                $stmt->bindParam(":type", $type);
                $stmt->bindParam(":pdf", $pdfPath);
                $stmt->bindParam(":image", $profile);
                $stmt->execute();
                $json["error"] = array("code" => "#200", "description" => "Success.");
            }
        } else {
            $json["error"] = array("code" => "#400", "description" => "Name, email, phone, password, type and profile are required.");
        }
    } else  if ($mode == 'updatestaff') {
        if (
            isset($_REQUEST['name']) &&
            isset($_REQUEST['age']) &&
            isset($_REQUEST['index']) &&
            isset($_REQUEST['position']) &&
            isset($_REQUEST['qualificaiton']) &&
            isset($_REQUEST['department']) &&
            isset($_REQUEST['gender']) &&
            isset($_REQUEST['type']) &&
            isset($_REQUEST['profile']) &&
            isset($_REQUEST['phone'])
        ) {
            $adminid = $_REQUEST['staffid'];
            $name = $_REQUEST['name'];
            $index = $_REQUEST['index'];
            $age = $_REQUEST['age'];
            $position = $_REQUEST['position'];
            $qualificaiton = $_REQUEST['qualificaiton'];
            $gender = $_REQUEST['gender'];
            $phone = $_REQUEST['phone'];
            $type = $_REQUEST['type'];
            $profile = $_REQUEST['profile'] ?? "";
            $pdfPath = "";
            $department = $_REQUEST['department'];

            if ($department == "iqac") {
                $departmentid = "iqac";
                $departmentname = "IQAC";
            } else {
                $sql = "SELECT * FROM admins WHERE id = :id";
                $stmt = $pdoConn->prepare($sql);
                $stmt->bindParam(":id", $department);
                $stmt->execute();
                $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

                $departmentid = $result[0]['id'];
                $departmentname = $result[0]['fullname'];
            }

            if (!preg_match($phoneRegex, $phone)) {
                $json["error"] = array("code" => "#400", "description" => "Invalid phone number.");
            } else {
                if (isset($_FILES['pdf'])) {
                    $target_dir = $uploadsDirectory . "pdf/";
                    $pdfname = uniqid() . ".pdf";
                    $target_file = $target_dir . $pdfname;
                    $uploadOk = 1;
                    $imageFileType = strtolower(pathinfo($target_file, PATHINFO_EXTENSION));
                    // Check if image file is a actual image or fake image
                    $check = getimagesize($_FILES["pdf"]["tmp_name"]);
                    if ($check !== false) {
                        $json["error"] = array("code" => "#400", "description" => "File is not a pdf.");
                        $uploadOk = 0;
                    }
                    if ($_FILES["pdf"]["size"] > 50000000) {
                        $json["error"] = array("code" => "#400", "description" => "Sorry, your file is too large.");
                        $uploadOk = 0;
                    }
                    if (
                        $imageFileType != "pdf"
                    ) {
                        $json["error"] = array("code" => "#400", "description" => "Sorry, only PDF files are allowed.");
                        $uploadOk = 0;
                    }

                    if ($uploadOk != 0) {
                        if (move_uploaded_file($_FILES["pdf"]["tmp_name"], $target_file)) {
                            $pdfPath = $pdfname;
                            $json["error"] = array("code" => "#200", "description" => "The file " . htmlspecialchars(basename($_FILES["pdf"]["name"])) . " has been uploaded.");
                        } else {
                            $json["error"] = array("code" => "#400", "description" => "Sorry, there was an error uploading your file.");
                        }
                    }
                }

                $sql = "SELECT * FROM admins WHERE id = :id";
                $stmt = $pdoConn->prepare($sql);
                $stmt->bindParam(":id", $department);
                $stmt->execute();
                $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
                $departmentid = $result[0]['id'];
                $departmentname = $result[0]['fullname'];
                $sql = "UPDATE staffs SET name = :name,sindex = :sindex, position = :position, qualification = :qualification, phone = :phone, age = :age, departmentid = :departmentid, departmentname = :departmentname, gender = :gender, type = :type, image = :image";
                //  WHERE id = :id";
                if ($pdfPath != "") {
                    $sql .= ", pdf = :pdf";
                }
                $sql .= " WHERE id = :id";
                $stmt = $pdoConn->prepare($sql);
                $stmt->bindParam(":name", $name);
                $stmt->bindParam(":sindex", $index);
                $stmt->bindParam(":position", $position);
                $stmt->bindParam(":qualification", $qualificaiton);
                $stmt->bindParam(":phone", $phone);
                $stmt->bindParam(":age", $age);
                $stmt->bindParam(":gender", $gender);
                $stmt->bindParam(":departmentid", $departmentid);
                $stmt->bindParam(":departmentname", $departmentname);
                $stmt->bindParam(":type", $type);
                $stmt->bindParam(":image", $profile);
                if ($pdfPath != "") {
                    $stmt->bindParam(":pdf", $pdfPath);
                }
                $stmt->bindParam(":id", $adminid);
                $stmt->execute();
                $json["error"] = array("code" => "#200", "description" => "Success.");
            }
        } else {
            $json["error"] = array("code" => "#400", "description" => "Name, email, phone, password, type and profile are required.");
        }
    } else if ($mode == 'deletestaff') {
        $adminid = $_REQUEST['staffid'];
        $sql = "DELETE FROM staffs WHERE id = :id";
        $stmt = $pdoConn->prepare($sql);
        $stmt->bindParam(":id", $adminid);
        $stmt->execute();
        $json["error"] = array("code" => "#200", "description" => "Success.");
    } else if ($mode == "addcontent") {
        if (
            isset($_REQUEST['name']) &&
            isset($_REQUEST['content']) &&
            isset($_REQUEST['type']) &&
            isset($_REQUEST['index']) &&
            isset($_REQUEST['icon'])
        ) {
            $name = $_REQUEST['name'];
            $content = $_REQUEST['content'];
            $type = $_REQUEST['type'];
            $index = $_REQUEST['index'];
            $icon = $_REQUEST['icon'];
            $date = date("Y-m-d H:i:s");
            $sql = "INSERT INTO contents (
                        title, content, icon, type,  created_at, updated_at, sindex
                    ) VALUES (
                        :name, :content, :icon, :type, :created_at, :updated_at, :sindex
                    )";
            $stmt = $pdoConn->prepare($sql);
            $stmt->bindParam(":name", $name);
            $stmt->bindParam(":content", $content);
            $stmt->bindParam(":icon", $icon);
            $stmt->bindParam(":type", $type);
            $stmt->bindParam(":created_at", $date);
            $stmt->bindParam(":updated_at", $date);
            $stmt->bindParam(":sindex", $index);
            $stmt->execute();
            $json["error"] = array("code" => "#200", "description" => "Success.");
        } else {
            $json["error"] = array("code" => "#400", "description" => "Name, content and icon are required.");
        }
    } else if ($mode == 'updatecontent') {
        $contentid = $_REQUEST['contentid'];
        $name = $_REQUEST['name'];
        $content = $_REQUEST['content'];
        $icon = $_REQUEST['icon'];
        $type = $_REQUEST['type'];
        $index = $_REQUEST['index'];
        $date = date("Y-m-d H:i:s");
        $sql = "UPDATE contents SET title = :name, content = :content, icon = :icon, updated_at = :updated_at, type = :type, `sindex` = :index WHERE id = :id";
        $stmt = $pdoConn->prepare($sql);
        $stmt->bindParam(":name", $name);
        $stmt->bindParam(":content", $content);
        $stmt->bindParam(":icon", $icon);
        $stmt->bindParam(":updated_at", $date);
        $stmt->bindParam(":id", $contentid);
        $stmt->bindParam(":type", $type);
        $stmt->bindParam(":index", $index);
        $stmt->execute();
        $json["error"] = array("code" => "#200", "description" => "Success.");
    } else if ($mode == "getallcontents") {
        $sql = "SELECT id,title,icon,updated_at FROM contents WHERE type = '1' ORDER BY contents.sindex ASC";
        $stmt = $pdoConn->prepare($sql);
        $stmt->execute();
        $result = $stmt->fetchAll();
        $json["error"] = array("code" => "#200", "description" => "Success.");
        $json["data"] = $result;
    } else if ($mode == "getallfacilities") {
        $sql = "SELECT id,title,icon,updated_at FROM contents WHERE type = '2' ORDER BY contents.sindex ASC";
        $stmt = $pdoConn->prepare($sql);
        $stmt->execute();
        $result = $stmt->fetchAll();
        $json["error"] = array("code" => "#200", "description" => "Success.");
        $json["data"] = $result;
    } else if ($mode == 'deletecontent') {
        $contentid = $_REQUEST['contentid'];
        $sql = "DELETE FROM contents WHERE id = :id";
        $stmt = $pdoConn->prepare($sql);
        $stmt->bindParam(":id", $contentid);
        $stmt->execute();
        $json["error"] = array("code" => "#200", "description" => "Success.");
    } else if ($mode == "userlogin") {
        $mobile = $_REQUEST['mobile'];
        $regid = $_REQUEST['regid'] ?? "";
        $sql = "SELECT * FROM users WHERE phone = :phone";
        $stmt = $pdoConn->prepare($sql);
        $stmt->bindParam(":phone", $mobile);
        $stmt->execute();
        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
        if (count($result) > 0) {
            $sql = "UPDATE users SET regid = :regid WHERE phone = :phone";
            $stmt = $pdoConn->prepare($sql);
            $stmt->bindParam(":regid", $regid);
            $stmt->bindParam(":phone", $mobile);
            $stmt->execute();

            $json["error"] = array("code" => "#200", "description" => "Success.");
            $json["data"] = $result[0];
        } else {
            $json["error"] = array("code" => "#201", "description" => "Success.");
        }
    } else if ($mode == "userlogin") {
        $mobile = $_REQUEST['mobile'];
        $regid = $_REQUEST['regid'] ?? "";
        $sql = "SELECT * FROM users WHERE phone = :phone";
        $stmt = $pdoConn->prepare($sql);
        $stmt->bindParam(":phone", $mobile);
        $stmt->execute();
        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
        if (count($result) > 0) {
            $sql = "UPDATE users SET regid = :regid WHERE phone = :phone";
            $stmt = $pdoConn->prepare($sql);
            $stmt->bindParam(":regid", $regid);
            $stmt->bindParam(":phone", $mobile);
            $stmt->execute();

            $json["error"] = array("code" => "#200", "description" => "Success.");
            $json["data"] = $result[0];
        } else {
            $json["error"] = array("code" => "#201", "description" => "Success.");
        }
    } else if ($mode == "guestlogin") {
        $regid = $_REQUEST['regid'] ?? "";
        $sdkVersion = $_REQUEST['sdkVersion'] ?? "";
        $release = $_REQUEST['release'] ?? "";
        $brand = $_REQUEST['brand'] ?? "";
        $model = $_REQUEST['model'] ?? "";
        $width = $_REQUEST['width'] ?? "";
        $height = $_REQUEST['height'] ?? "";
        $device = $_REQUEST['device'] ?? "";
        $product = $_REQUEST['product'] ?? "";
        $manufacturer = $_REQUEST['manufacturer'] ?? "";
        $ip = getIpAddress();
        $deivce = array(
            "sdkVersion" => $sdkVersion,
            "release" => $release,
            "brand" => $brand,
            "model" => $model,
            "width" => $width,
            "height" => $height,
            "device" => $device,
            "product" => $product,
            "manufacturer" => $manufacturer
        );
        $device = json_encode($deivce);
        $sql = "INSERT INTO guests (regid, device, ip) VALUES (:regid, :device, :ip)";
        $stmt = $pdoConn->prepare($sql);
        $stmt->bindParam(":regid", $regid);
        $stmt->bindParam(":device", $device);
        $stmt->bindParam(":ip", $ip);
        $stmt->execute();
        $json["error"] = array("code" => "#200", "description" => "Success.");
    } else if ($mode == "updateprofilepic") {
        if (isset($_REQUEST['phone'])) {
            $phone = $_REQUEST['phone'];
            if (isset($_FILES['image'])) {
                $file = $_FILES['image'];
                $fileName = $file['name'];
                $fileTmpName = $file['tmp_name'];
                $fileSize = $file['size'];
                $extensions = array("jpg", "jpeg", "png", "gif");
                $fileExt = explode('.', $fileName);
                $fileActualExt = PATHINFO($fileName, PATHINFO_EXTENSION);
                $fileNameNew = time() . "_" . uniqid('', true) . "." . $fileActualExt;
                $target_dir = $uploadsDirectory . "images/";
                $fileDestination = $target_dir . $fileNameNew;
                if (in_array($fileActualExt, $extensions)) {
                    if ($fileSize < 1024 * 1024 * 100) {
                        if (move_uploaded_file($fileTmpName, $fileDestination)) {
                            $json["data"] = array("id" => $fileNameNew, "image_url" => $baseUrl . "uploads/images/" . $fileNameNew, "type" => $fileExt, "size" => $fileSize);
                            $sql = "UPDATE users SET image = :image WHERE phone = :phone";
                            $stmt = $pdoConn->prepare($sql);
                            $stmt->bindParam(":image", $fileNameNew);
                            $stmt->bindParam(":phone", $phone);
                            $stmt->execute();
                        } else {
                            $json["error"] = array("code" => "#500", "description" => "Error uploading file.");
                        }
                    } else {
                        $json["error"] = array("code" => "#500", "description" => "File size is too big.");
                    }
                } else {
                    $json["error"] = array("code" => "#500", "description" => "File type is not supported.");
                }
            }
        }
    } else if ($mode == "update_profile") {
        $mobile = $_REQUEST['mobile'];
        $name = $_REQUEST['name'];
        $type = $_REQUEST['type'];
        $department = $_REQUEST['department'] ?? "";
        $date = date("Y-m-d H:i:s");
        $dob = $_REQUEST['dob'];
        $working = $_REQUEST['working'] ?? "";
        $joiningyear = $_REQUEST['joiningyear'] ?? "";
        $email = $_REQUEST['email'] ?? "";
        $gender = $_REQUEST['gender'] ?? "";
        $grade = $_REQUEST['grade'] ?? "";
        $regid = $_REQUEST['regid'] ?? "";
        $rollno = $_REQUEST['rollno'] ?? "";
        $registerno = $_REQUEST['registerno'] ?? "";
        $libraryno = strtoupper($_REQUEST['libraryno'] ?? "");
        $willingtodonate = $_REQUEST['willingtodonate'] ?? "";
        $bloodgroup = $_REQUEST['bloodgroup'] ?? "";
        $coursetype = $_REQUEST['coursetype'] ?? "";
        $stafftype = $_REQUEST['stafftype'] ?? "";
        $sql = "SELECT * FROM users WHERE phone = :phone";
        $stmt = $pdoConn->prepare($sql);
        $stmt->bindParam(":phone", $mobile);
        $stmt->execute();
        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (count($result) > 0) {
            $sql = "UPDATE users SET fullname = :name, type = :type, department = :department, dob = :dob, joiningyear = :joiningyear, updated_at = :updated_at, working = :working, email = :email, gender = :gender, grade = :grade, willingtodonate = :willingtodonate, bloodgroup = :bloodgroup, coursetype = :coursetype, stafftype = :stafftype, regid = :regid, rollno = :rollno, registerno = :registerno, libraryno = :libraryno WHERE phone = :phone";
            $stmt = $pdoConn->prepare($sql);
            $stmt->bindParam(":name", $name);
            $stmt->bindParam(":type", $type);
            $stmt->bindParam(":department", $department);
            $stmt->bindParam(":dob", $dob);
            $stmt->bindParam(":joiningyear", $joiningyear);
            $stmt->bindParam(":updated_at", $date);
            $stmt->bindParam(":phone", $mobile);
            $stmt->bindParam(":working", $working);
            $stmt->bindParam(":gender", $gender);
            $stmt->bindParam(":email", $email);
            $stmt->bindParam(":grade", $grade);
            $stmt->bindParam(":willingtodonate", $willingtodonate);
            $stmt->bindParam(":bloodgroup", $bloodgroup);
            $stmt->bindParam(":coursetype", $coursetype);
            $stmt->bindParam(":stafftype", $stafftype);
            $stmt->bindParam(":regid", $regid);
            $stmt->bindParam(":rollno", $rollno);
            $stmt->bindParam(":registerno", $registerno);
            $stmt->bindParam(":libraryno", $libraryno);
            $stmt->execute();
            $json["error"] = array("code" => "#200", "description" => "Success.");
        } else {
            $sql = "INSERT INTO users (
                        fullname, phone, type, department, dob, joiningyear, created_at, updated_at, working, email, coursetype, stafftype, gender, grade, willingtodonate, bloodgroup, regid
                    ) VALUES (
                        :name, :phone, :type, :department, :dob, :joiningyear, :created_at, :updated_at, :working, :email, :coursetype, :stafftype, :gender, :grade, :willingtodonate, :bloodgroup, :regid
                    )";
            $stmt = $pdoConn->prepare($sql);
            $stmt->bindParam(":name", $name);
            $stmt->bindParam(":phone", $mobile);
            $stmt->bindParam(":type", $type);
            $stmt->bindParam(":department", $department);
            $stmt->bindParam(":dob", $dob);
            $stmt->bindParam(":joiningyear", $joiningyear);
            $stmt->bindParam(":created_at", $date);
            $stmt->bindParam(":updated_at", $date);
            $stmt->bindParam(":working", $working);
            $stmt->bindParam(":email", $email);
            $stmt->bindParam(":grade", $grade);
            $stmt->bindParam(":willingtodonate", $willingtodonate);
            $stmt->bindParam(":bloodgroup", $bloodgroup);
            $stmt->bindParam(":coursetype", $coursetype);
            $stmt->bindParam(":stafftype", $stafftype);
            $stmt->bindParam(":gender", $gender);
            $stmt->bindParam(":regid", $regid);
            $stmt->execute();
            $json["error"] = array("code" => "#200", "description" => "Success.");
        }
        $sql = "SELECT * FROM users WHERE phone = :phone";
        $stmt = $pdoConn->prepare($sql);
        $stmt->bindParam(":phone", $mobile);
        $stmt->execute();
        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $json["data"] = $result[0];
    } else if ($mode == "geAllAdmins") {
        $sql = "SELECT email,fullname,phone,color,departmenttype FROM admins WHERE departmenttype != 'College'";
        $stmt = $pdoConn->prepare($sql);
        $stmt->execute();
        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $json["error"] = array("code" => "#200", "description" => "Success.");
        $json["data"] = $result;
    } else if ($mode == "contactMessage") {
        $datetime = date("Y-m-d H:i:s");
        try {
            $name = $_REQUEST["name"] ?? "";
            $email = $_REQUEST["email"] ?? "";
            $mobile = $_REQUEST["mobile"] ?? "";
            $message = $_REQUEST["message"] ?? "";
            $category = $_REQUEST["category"] ?? "";
            $name = htmlspecialchars($name);
            $mobile = htmlspecialchars($mobile);
            $email = htmlspecialchars($email);
            $message = htmlspecialchars($message);
            $category = htmlspecialchars($category);

            $sql = "INSERT INTO contact (name, email, phone, message, category, created_at) VALUES (:name, :email, :phone, :message, :category, :created_at)";
            $stmt = $pdoConn->prepare($sql);
            $stmt->bindParam(":name", $name);
            $stmt->bindParam(":email", $email);
            $stmt->bindParam(":phone", $mobile);
            $stmt->bindParam(":message", $message);
            $stmt->bindParam(":category", $category);
            $stmt->bindParam(":created_at", $datetime);
            $stmt->execute();

            $json["error"] = array("code" => "#200", "description" => "Success.");
        } catch (Exception $e) {
            $json["error"] = array("code" => "#500", "description" => $e->getMessage());
        }
    } else {
        $json['error'] = array("code" => "#403", "description" => "Invalid mode.");
    }
} else {
    $json["error"] = array("code" => "#403", "description" => "Mode is required.");
}

unset($json["regid"]);
echo json_encode($json);
