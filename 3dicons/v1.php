<?php
ini_set('display_errors', 1);
ini_set('error_reporting', E_ALL);

include('config.php');

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');
header('Access-Control-Allow-Headers: Origin, X-Requested-With, Content-Type, Accept');

$displayCurrency = 'INR';

if (!isset($_SESSION)) {
    session_start();
}

$date = date('Y-m-d');
$datetime = date('Y-m-d H:i:s');
$today = strtotime("today");
$dayOfWeek = date("N", $today);
$daysToSubtract = $dayOfWeek - 1;

$firstDateOfWeek = date("Y-m-d", strtotime("-$daysToSubtract days", $today));

$json["data"] = [];
$json["error"] = array("code" => "#200", "description" => "Success.");
$json['request'] = $_REQUEST;
if (isset($_REQUEST["action"])) {
    header('Content-Type: application/json');
    header('Access-Control-Allow-Origin: *');
    $action = trim($_REQUEST["action"]);
    if ($action == "getAllIcons") {
        $search = $_REQUEST['search'] ?? "";
        $limit = $_REQUEST['limit'] ?? 20;
        $page = $_REQUEST['page'] ?? 1;
        $offset = ($page - 1) * $limit;
        $sortBy = $_REQUEST['sortBy'] ?? "id-desc";
        $like = "%" . $search . "%";
        $sql = "SELECT * FROM `images` WHERE `name` LIKE :search ";
        if ($sortBy == "id-desc") {
            $sql .= " ORDER BY `id` DESC";
        } else if ($sortBy == "id-asc") {
            $sql .= " ORDER BY `id` ASC";
        } else if ($sortBy == "views-desc") {
            $sql .= " ORDER BY `views` DESC";
        } else if ($sortBy == "views-asc") {
            $sql .= " ORDER BY `views` ASC";
        } else if ($sortBy == "likes-desc") {
            $sql .= " ORDER BY `likes` DESC";
        } else if ($sortBy == "likes-asc") {
            $sql .= " ORDER BY `likes` ASC";
        }
        $sql .= " LIMIT :limit OFFSET :offset";
        $stmt = $pdoConn->prepare($sql);
        $stmt->bindParam(':search', $like);
        $stmt->bindParam(':limit', $limit, PDO::PARAM_INT);
        $stmt->bindParam(':offset', $offset, PDO::PARAM_INT);
        $stmt->execute();
        $subAdminData = $stmt->fetchAll();
        $json["data"] = $subAdminData;
    } else if ($action == "contactMessage") {
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
            $stmt = $pdoConn->prepare($sql);
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
    } else if ($action == "saveregidv2") {
        if (isset($_REQUEST['regid'])) {
            $sql = "SELECT * FROM regidv2 WHERE regid = :regid";
            $stmt = $conn->prepare($sql);
            $stmt->bindParam(":regid", $_REQUEST['regid']);
            $stmt->execute();
            $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
            if (count($result) == 0) {
                $sql = "INSERT INTO regidv2 (regid) VALUES (:regid)";
                $stmt = $conn->prepare($sql);
                $stmt->bindParam(":regid", $_REQUEST['regid']);
                $stmt->execute();
            }
        } else {
            echo "error";
        }
    } else if ($action == "viewSingleIcon") {
        $id = $_REQUEST['id'] ?? 0;
        $sql = "UPDATE `images` SET `views` = `views` + 1 WHERE `id` = :id";
        $stmt = $pdoConn->prepare($sql);
        $stmt->bindParam(':id', $id);
        $stmt->execute();
    } else if ($action == "likeSingleIcon") {
        $id = $_REQUEST['id'] ?? 0;
        $sql = "UPDATE `images` SET `likes` = `likes` + 1 WHERE `id` = :id";
        $stmt = $pdoConn->prepare($sql);
        $stmt->bindParam(':id', $id);
        $stmt->execute();
    } else if ($action == "downloadSingleIcon") {
        $id = $_REQUEST['id'] ?? 0;
        $sql = "UPDATE `images` SET `downloads` = `downloads` + 1 WHERE `id` = :id";
        $stmt = $pdoConn->prepare($sql);
        $stmt->bindParam(':id', $id);
        $stmt->execute();
    }
} else {
    $json["error"] = array("code" => "#500", "description" => "Invalid request.");
}

echo json_encode($json, JSON_PRETTY_PRINT);
