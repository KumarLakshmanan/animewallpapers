<?php
if (!isset($_SESSION)) {
    session_start();
}
function distance($lat1, $lon1, $lat2, $lon2, $unit)
{
    if (($lat1 == $lat2) && ($lon1 == $lon2)) {
        return 0;
    } else {
        $theta = $lon1 - $lon2;
        $dist = sin(deg2rad($lat1)) * sin(deg2rad($lat2)) +  cos(deg2rad($lat1)) * cos(deg2rad($lat2)) * cos(deg2rad($theta));
        $dist = acos($dist);
        $dist = rad2deg($dist);
        $miles = $dist * 60 * 1.1515;
        $unit = strtoupper($unit);
        if ($unit == "K") {
            return ($miles * 1.609344);
        } else if ($unit == "N") {
            return ($miles * 0.8684);
        } else {
            return $miles;
        }
    }
}
function calculateDistance($lat1, $lng1, $lat2, $lng2)
{
    $earthRadius = 6371;
    $dLat = deg2rad($lat2 - $lat1);
    $dLng = deg2rad($lng2 - $lng1);

    $a = sin($dLat / 2) * sin($dLat / 2) +
        cos(deg2rad($lat1)) * cos(deg2rad($lat2)) *
        sin($dLng / 2) * sin($dLng / 2);
    $c = 2 * atan2(sqrt($a), sqrt(1 - $a));
    $distance = $earthRadius * $c;
    return $distance;
}
function getTaxVal($total, $percent)
{
    return ($total * $percent) / 100;
}

function generateEpin()
{
    global $pdoConn;
    $rand = rand(1000000000, 9999999999);
    $sql = "SELECT id FROM pins WHERE pin_no = :pin";
    $stmt = $pdoConn->prepare($sql);
    $stmt->execute(array(':pin' => $rand));
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    if ($row) {
        generateEpin();
    } else {
        return $rand;
    }
}

function getIpAddress()
{
    if (!empty($_SERVER['HTTP_CLIENT_IP'])) {
        $ip = $_SERVER['HTTP_CLIENT_IP'];
    } elseif (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
        $ip = $_SERVER['HTTP_X_FORWARDED_FOR'];
    } else {
        $ip = $_SERVER['REMOTE_ADDR'];
    }
    return $ip;
}
function timeSince($ipochTime)
{
    $time = time() - $ipochTime;
    $time = ($time < 1) ? 1 : $time;
    $tokens = array(
        31536000 => 'yr',
        2592000 => 'mth',
        604800 => 'wk',
        86400 => 'day',
        3600 => 'hr',
        60 => 'min',
        1 => 'sec'
    );
    foreach ($tokens as $unit => $text) {
        if ($time < $unit) continue;
        $numberOfUnits = floor($time / $unit);
        return $numberOfUnits . ' ' . $text . (($numberOfUnits > 1) ? 's' : '');
    }
}
function readJsonFile($filename)
{
    $handle = fopen($filename, "r");
    $contents = fread($handle, filesize($filename));
    fclose($handle);
    return $contents;
}
function generateUniqueUserid()
{
    $pre_userid = "MB" . rand(10000000, 99999999);
    if (file_exists(BASE_PATH . "json/users/" . $pre_userid)) {
        return generateUniqueUserid();
    } else {
        return $pre_userid;
    }
}

function generateUniqueVendorId()
{
    $pre_userid = "MBV" . rand(10000000, 99999999);
    if (file_exists(BASE_PATH . "json/vendors/vendor/" . $pre_userid)) {
        return generateUniqueVendorId();
    } else {
        return $pre_userid;
    }
}

function generateUniqueResid()
{
    $preuserid = "BR-" . rand(10000000, 99999999);
    if (file_exists(BASE_PATH . "json/restaurant/" . $preuserid)) {
        return  generateUniqueResid();
    } else {
        return $preuserid;
    }
}
function randPassword()
{
    $characters = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    $randomstr = '';
    for ($i = 0; $i < rand(12, 20); $i++) {
        $randomstr .= $characters[rand(0, strlen($characters) - 1)];
    }
    return $randomstr;
}

function getBrowser($userAgent)
{
    $browserName = 'Other';
    $browserArray = array(
        '/msie/i' => 'Internet Explorer',
        '/firefox/i' => 'Firefox',
        '/safari/i' => 'Safari',
        '/chrome/i' => 'Chrome',
        '/edge/i' => 'Edge',
        '/opera/i' => 'Opera',
        '/netscape/i' => 'Netscape',
        '/maxthon/i' => 'Maxthon',
        '/konqueror/i' => 'Konqueror',
        '/mobile/i' => 'Handheld Browser'
    );
    foreach ($browserArray as $regex => $value) {
        if (preg_match($regex, $userAgent)) {
            $browserName = $value;
        }
    }
    return $browserName;
}
function getOs($userAgent)
{
    $osName = 'Unknown OS';
    $osArray = array(
        '/windows nt 11/i' => 'Windows 11',
        '/windows nt 10/i' => 'Windows 10',
        '/windows nt 6.3/i' => 'Windows 8.1',
        '/windows nt 6.2/i' => 'Windows 8',
        '/windows nt 6.1/i' => 'Windows 7',
        '/windows nt 6.0/i' => 'Windows Vista',
        '/windows nt 5.2/i' => 'Windows Server 2003/XP x64',
        '/windows nt 5.1/i' => 'Windows XP',
        '/windows xp/i' => 'Windows XP',
        '/windows nt 5.0/i' => 'Windows 2000',
        '/windows me/i' => 'Windows ME',
        '/win98/i' => 'Windows 98',
        '/win95/i' => 'Windows 95',
        '/win16/i' => 'Windows 3.11',
        '/macintosh|mac os x/i' => 'Mac OS X',
        '/mac_powerpc/i' => 'Mac OS 9',
        '/linux/i' => 'Linux',
        '/ubuntu/i' => 'Ubuntu',
        '/iphone/i' => 'iPhone',
        '/ipod/i' => 'iPod',
        '/ipad/i' => 'iPad',
        '/android/i' => 'Android',
        '/blackberry/i' => 'BlackBerry',
        '/webos/i' => 'Mobile'
    );
    foreach ($osArray as $regex => $value) {
        if (preg_match($regex, $userAgent)) {
            $osName = $value;
        }
    }
    return $osName;
}
function sendGCMV2($data, $userData)
{
    $registredUsers = array();

    foreach ($userData as $key => $value) {
        if (!isset($registredUsers[$value['regid']])) {
            $registredUsers[$value['regid']] = array(
                "firstname" => $value['first_name'],
                "lastname" => $value['last_name'],
                "userid" => $value['user_id'],
                "telephone" => $value['telephone'],
                "regid" => $value['regid'],
            );
        }
    }
    $gcmresult = array();

    $regidInputFile = BASE_PATH . "json/logs/sendNotifications/input/" . date("Y-m-d-H") . "/";
    $regidOutputFile = BASE_PATH . "json/logs/sendNotifications/output/" . date("Y-m-d-H") . "/";
    if (!file_exists($regidInputFile)) {
        mkdir($regidInputFile, 0777, true);
    }
    if (!file_exists($regidOutputFile)) {
        mkdir($regidOutputFile, 0777, true);
    }

    $i = 0;
    $count = count($registredUsers);
    while ($i < $count) {
        $id1 = array_slice($registredUsers, $i, 1000);
        $i = $i + 1000;

        $extension = date("i-s") . "_" . rand(0, 999999999999) . ".json";

        $regidInputFile .= $extension;
        $regidOutputFile .= $extension;

        file_put_contents($regidInputFile, json_encode($id1));
        $cmd = "nohup php " . BASE_PATH . "lib/sendNotificationsV2.php '" . json_encode($data) . "' '" . $regidInputFile . "' '" . $regidOutputFile . "' > /dev/null 2>&1 &";
        shell_exec($cmd);
        $gcmresult[] = $cmd;
    }
    return $gcmresult;
}

function getRowsCount($sql, $pdoConn)
{
    $stmt = $pdoConn->prepare($sql);
    $stmt->execute();
    $row = $stmt->fetchAll(PDO::FETCH_ASSOC);
    return count($row);
}
function getRows($sql, $pdoConn)
{
    $stmt = $pdoConn->prepare($sql);
    $stmt->execute();
    $row = $stmt->fetchAll(PDO::FETCH_ASSOC);
    return $row;
}
function getRow($sql, $pdoConn)
{
    $stmt = $pdoConn->prepare($sql);
    $stmt->execute();
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    return $row;
}
function generateOfferPin($pdoConn)
{
    $pin = 'MB-';
    $pin .= rand(1000, 9999) . '-';
    $pin .= rand(1000, 9999) . '-';
    $pin .= rand(1000, 9999);
    $sql = "SELECT * FROM pin_offers WHERE pin_no = '$pin'";
    $stmt = $pdoConn->prepare($sql);
    $stmt->execute();
    $row = $stmt->fetchAll(PDO::FETCH_ASSOC);
    if (count($row) == 0) {
        return $pin;
    } else {
        generateOfferPin($pdoConn);
    }
}
function createTicket($tic, $category, $subject, $message, $user_id, $admin = false)
{
    try {
        $nowDate = date('Y-m-d h:i:s');
        $time = strtotime($nowDate);
        $foldername = BASE_PATH . "json/users/" . $user_id . "/tickets/";
        if (!file_exists($foldername)) {
            mkdir($foldername, 0777, true);
        }
        // filter message & subject
        $subject = htmlspecialchars($subject);
        $message = htmlspecialchars($message);
        $category = htmlspecialchars($category);
        $filename = $foldername . $tic . ".json";
        if (!file_exists($filename)) {
            $data = array(
                "user_id" => $user_id,
                "ticket_no" => $tic,
                "subject" => $subject,
                "category" => $category,
                "lastmessage" => $message,
                "lastmessagefrom" => $admin ? "admin" : "user",
                "status" => "0",
                "totalmessage" => "1",
                "create_date" => $nowDate,
                "update_date" => $nowDate,
            );
            file_put_contents($filename, json_encode($data));

            $newfolder = BASE_PATH . "json/tickets/";
            if (!file_exists($newfolder)) {
                mkdir($newfolder, 0777, true);
            }
            $newfilename = $newfolder . $tic . ".json";
            file_put_contents($newfilename, json_encode($data));
        } else {
            $data = json_decode(file_get_contents($filename), true);
            $data['lastmessage'] = $message;
            $data['lastmessagefrom'] = $admin ? "admin" : "user";
            $data['update_date'] = $nowDate;
            $data['status'] = "0";
            $data['totalmessage'] = $data['totalmessage'] + 1;
            file_put_contents($filename, json_encode($data));

            $newfolder = BASE_PATH . "json/tickets/";
            if (!file_exists($newfolder)) {
                mkdir($newfolder, 0777, true);
            }
            $newfilename = $newfolder . $tic . ".json";
            file_put_contents($newfilename, json_encode($data));
        }

        $chatData = array(
            "user_id" => $user_id,
            "ticket_no" => $tic,
            "subject" => $subject,
            "category" => $category,
            "message" => $message,
            "messagefrom" => $admin ? "admin" : "user",
            "create_date" => $nowDate,
        );
        $newfolder = BASE_PATH . "json/singletickets/" . $tic . "/";
        if (!file_exists($newfolder)) {
            mkdir($newfolder, 0777, true);
        }
        $glob = glob($newfolder . $time . "*.json");
        $newfilename = $newfolder . $time . count($glob) . ".json";
        file_put_contents($newfilename, json_encode($chatData));
        return $time . count($glob);
    } catch (\Throwable $th) {
        return $th->getMessage();
    }
}
function foldersize($path)
{
    $total_size = 0;
    $files = scandir($path);
    $cleanPath = rtrim($path, '/') . '/';
    foreach ($files as $t) {
        if ($t <> "." && $t <> "..") {
            $currentFile = $cleanPath . $t;
            if (is_dir($currentFile)) {
                $size = foldersize($currentFile);
                $total_size += $size;
            } else {
                $size = filesize($currentFile);
                $total_size += $size;
            }
        }
    }
    return $total_size;
}

function format_size($size)
{
    global $units;
    $mod = 1024;
    for ($i = 0; $size > $mod; $i++) {
        $size /= $mod;
    }
    $endIndex = strpos($size, ".") + 3;
    return substr($size, 0, $endIndex) . ' ' . $units[$i];
}

function convertImageUrlToBase64($filepath)
{
    if (strpos($filepath, CDN_URL) === false) {
        return $filepath;
    }
    $filepath = str_replace(CDN_URL, "", $filepath);
    $image_path = CDN_PATH . $filepath;
    $image_data = file_get_contents($image_path);
    $base64_data = base64_encode($image_data);
    return "data:image/jpeg;base64," . $base64_data;
}
function getAllInviteesByUserId($userid)
{
    $userFolder = BASE_PATH . "json/users/" . $userid . "/downline";
    if (!file_exists($userFolder)) {
        mkdir($userFolder, 0777, true);
        return [];
    }
    $downlineIds = scandir($userFolder);
    $downlineIds = array_diff($downlineIds, array('.', '..'));
    $downlineIds = array_values($downlineIds);
    $downlineIds = array_map(function ($value) {
        return str_replace(".json", "", $value);
    }, $downlineIds);
    return $downlineIds;
}


function decryptToJson($data, $encryptionKey)
{
    $data = base64_decode($data);
    $salt = substr($data, 8, 8);
    $encryptedData = substr($data, 16);
    $salted = '';
    $dx = '';
    while (strlen($salted) < 48) {
        $dx = md5($dx . $encryptionKey . $salt, true);
        $salted .= $dx;
    }
    $key = substr($salted, 0, 32);
    $iv = substr($salted, 32, 16);
    $decryptedData = openssl_decrypt($encryptedData, 'AES-256-CBC', $key, OPENSSL_RAW_DATA, $iv);
    $decryptedData = json_decode($decryptedData, true);
    return $decryptedData;
}
function encryptFromJson($data, $encryptionKey)
{
    $dataJson = json_encode($data);
    $salt = openssl_random_pseudo_bytes(8);
    $salted = '';
    $dx = '';
    while (strlen($salted) < 48) {
        $dx = md5($dx . $encryptionKey . $salt, true);
        $salted .= $dx;
    }
    $key = substr($salted, 0, 32);
    $iv = substr($salted, 32, 16);
    $encryptedData = openssl_encrypt($dataJson, 'AES-256-CBC', $key, OPENSSL_RAW_DATA, $iv);
    $encryptedData = 'Salted__' . $salt . $encryptedData;
    $encryptedDataB64 = base64_encode($encryptedData);
    return $encryptedDataB64;
}
// create a AES encryption key
function createEncryptionKey($length = 32)
{
    $key = '';
    $pattern = '1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    $patternLength = strlen($pattern) - 1;
    for ($i = 0; $i < $length; $i++) {
        $key .= $pattern[mt_rand(0, $patternLength)];
    }
    return $key;
}
function transactionNo()
{
    return "MB-TRANS-" . rand(10000000000, 99999999999);
}

function getSessionToken($db, String $username, int $id)
{
    $created_at = date('Y-m-d H:i:s');
    $token = md5($username . $id . $created_at);
    // more than 2 days old
    $sql = "DELETE FROM `sessions` WHERE AuthId = :id AND created_at < DATE_SUB(NOW(), INTERVAL 2 DAY)";
    $stmt = $db->prepare($sql);
    $stmt->bindParam(':id', $id);
    $stmt->execute();
    $ip = getClientIP();
    $sql = "INSERT INTO `sessions` (`AuthId`, `AuthUsername`, `AuthKey`, `created_at`, `ip_addr`) VALUES (:id, :username, :token, :created_at, :ip)";
    $stmt = $db->prepare($sql);
    $stmt->bindParam(':id', $id);
    $stmt->bindParam(':username', $username);
    $stmt->bindParam(':token', $token);
    $stmt->bindParam(':created_at', $created_at);
    $stmt->bindParam(':ip', $ip);
    $stmt->execute();
    return $token;
}

function validateSessionToken($db, String $token, $username = null)
{
    $sql = "SELECT * FROM `sessions` WHERE `AuthKey` = :token LIMIT 1";
    $stmt = $db->prepare($sql);
    $stmt->bindParam(':token', $token);
    $stmt->execute();
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    if ($stmt->rowCount() > 0) {
        if ($result['AuthUsername'] == $username) {
            return $result;
        }
    }
    return false;
}


function getClientIP()
{
    $ipAddress = '';
    if (isset($_SERVER['HTTP_CLIENT_IP']))
        $ipAddress = $_SERVER['HTTP_CLIENT_IP'];
    else if (isset($_SERVER['HTTP_X_FORWARDED_FOR']))
        $ipAddress = $_SERVER['HTTP_X_FORWARDED_FOR'];
    else if (isset($_SERVER['HTTP_X_FORWARDED']))
        $ipAddress = $_SERVER['HTTP_X_FORWARDED'];
    else if (isset($_SERVER['HTTP_FORWARDED_FOR']))
        $ipAddress = $_SERVER['HTTP_FORWARDED_FOR'];
    else if (isset($_SERVER['HTTP_FORWARDED']))
        $ipAddress = $_SERVER['HTTP_FORWARDED'];
    else if (isset($_SERVER['REMOTE_ADDR']))
        $ipAddress = $_SERVER['REMOTE_ADDR'];
    else
        $ipAddress = 'UNKNOWN';
    return $ipAddress;
}


function createSlug($string)
{
    $string = strtolower($string);
    $string = preg_replace('/[^a-z0-9_\s-]/', '', $string);
    $string = preg_replace('/[\s-]+/', ' ', $string);
    $string = preg_replace('/[\s_]/', '-', $string);
    return $string;
}

function getIdFromYoutubeUrl($url)
{
    $regex = '#^(?:https?://)?' . // http(s)://
        '(?:www\.)?' . // www.
        '(?:m\.)?' . // m.
        '(?:youtu\.be/|youtube\.com(?:/embed/|/v/|/watch\?v=|/watch\?.+&v=))' . // youtu.be/
        '([\w-]{11})' . // youtube id .e.g. 8U4Yce6_xjY
        '(?:.+)?$#x';
    $result = preg_match($regex, $url, $matches);
    if ($result) {
        return $matches[1];
    } else {
        return false;
    }
}
function validateSession($db)
{
    if (!isset($_SESSION)) {
        session_start();
    }
    if (isset($_SESSION['token'])) {
        return true;
    } else if (isset($_COOKIE['token']) && isset($_COOKIE['email'])) {
        $token = $_COOKIE['token'];
        $email = $_COOKIE['email'];
        $userAuth = validateSessionToken($db, $token, $email);
        if ($userAuth) {
            $sql = "SELECT * FROM users WHERE email = :email";
            $stmt = $db->prepare($sql);
            $stmt->bindParam(':email', $email);
            $stmt->execute();
            $result = $stmt->fetch(PDO::FETCH_ASSOC);
            $_SESSION['id'] = $result["id"];
            $_SESSION['email'] = $result["email"];
            $_SESSION['fullname'] = $result["fullname"];
            $_SESSION['email'] = $result["email"];
            $_SESSION['role'] = $result["role"];
            $_SESSION['token'] = $token;
            return true;
        } else {
            return false;
        }
    } else {
        return false;
    }
}


class BrowserDetection
{

    private $_user_agent;
    private $_name;
    private $_version;
    private $_platform;

    private $_basic_browser = array(
        'Trident\/7.0' => 'Internet Explorer 11',
        'Beamrise' => 'Beamrise',
        'Opera' => 'Opera',
        'OPR' => 'Opera',
        'Shiira' => 'Shiira',
        'Chimera' => 'Chimera',
        'Phoenix' => 'Phoenix',
        'Firebird' => 'Firebird',
        'Camino' => 'Camino',
        'Netscape' => 'Netscape',
        'OmniWeb' => 'OmniWeb',
        'Konqueror' => 'Konqueror',
        'icab' => 'iCab',
        'Lynx' => 'Lynx',
        'Links' => 'Links',
        'hotjava' => 'HotJava',
        'amaya' => 'Amaya',
        'IBrowse' => 'IBrowse',
        'iTunes' => 'iTunes',
        'Silk' => 'Silk',
        'Dillo' => 'Dillo',
        'Maxthon' => 'Maxthon',
        'Arora' => 'Arora',
        'Galeon' => 'Galeon',
        'Iceape' => 'Iceape',
        'Iceweasel' => 'Iceweasel',
        'Midori' => 'Midori',
        'QupZilla' => 'QupZilla',
        'Namoroka' => 'Namoroka',
        'NetSurf' => 'NetSurf',
        'BOLT' => 'BOLT',
        'EudoraWeb' => 'EudoraWeb',
        'shadowfox' => 'ShadowFox',
        'Swiftfox' => 'Swiftfox',
        'Uzbl' => 'Uzbl',
        'UCBrowser' => 'UCBrowser',
        'Kindle' => 'Kindle',
        'wOSBrowser' => 'wOSBrowser',
        'Epiphany' => 'Epiphany',
        'SeaMonkey' => 'SeaMonkey',
        'Avant Browser' => 'Avant Browser',
        'Firefox' => 'Firefox',
        'Chrome' => 'Google Chrome',
        'MSIE' => 'Internet Explorer',
        'Internet Explorer' => 'Internet Explorer',
        'Safari' => 'Safari',
        'Mozilla' => 'Mozilla'
    );

    private $_basic_platform = array(
        'windows' => 'Windows',
        'iPad' => 'iPad',
        'iPod' => 'iPod',
        'iPhone' => 'iPhone',
        'mac' => 'Apple',
        'android' => 'Android',
        'linux' => 'Linux',
        'Nokia' => 'Nokia',
        'BlackBerry' => 'BlackBerry',
        'FreeBSD' => 'FreeBSD',
        'OpenBSD' => 'OpenBSD',
        'NetBSD' => 'NetBSD',
        'UNIX' => 'UNIX',
        'DragonFly' => 'DragonFlyBSD',
        'OpenSolaris' => 'OpenSolaris',
        'SunOS' => 'SunOS',
        'OS\/2' => 'OS/2',
        'BeOS' => 'BeOS',
        'win' => 'Windows',
        'Dillo' => 'Linux',
        'PalmOS' => 'PalmOS',
        'RebelMouse' => 'RebelMouse'
    );

    function __construct($ua = '')
    {
        if (empty($ua)) {
            $this->_user_agent = (!empty($_SERVER['HTTP_USER_AGENT']) ? $_SERVER['HTTP_USER_AGENT'] : getenv('HTTP_USER_AGENT'));
        } else {
            $this->_user_agent = $ua;
        }
    }

    function detect()
    {
        $this->detectBrowser();
        $this->detectPlatform();
        return $this;
    }

    function detectBrowser()
    {
        foreach ($this->_basic_browser as $pattern => $name) {
            if (preg_match("/" . $pattern . "/i", $this->_user_agent, $match)) {
                $this->_name = $name;
                // finally get the correct version number
                $known = array('Version', $pattern, 'other');
                $pattern_version = '#(?<browser>' . join('|', $known) . ')[/ ]+(?<version>[0-9.|a-zA-Z.]*)#';
                if (!preg_match_all($pattern_version, $this->_user_agent, $matches)) {
                    // we have no matching number just continue
                }
                // see how many we have
                $i = count($matches['browser']);
                if ($i != 1) {
                    //we will have two since we are not using 'other' argument yet
                    //see if version is before or after the name
                    if (strripos($this->_user_agent, "Version") < strripos($this->_user_agent, $pattern)) {
                        @$this->_version = $matches['version'][0];
                    } else {
                        @$this->_version = $matches['version'][1];
                    }
                } else {
                    $this->_version = $matches['version'][0];
                }
                break;
            }
        }
    }

    function detectPlatform()
    {
        foreach ($this->_basic_platform as $key => $platform) {
            if (stripos($this->_user_agent, $key) !== false) {
                $this->_platform = $platform;
                break;
            }
        }
    }

    function getBrowser()
    {
        if (!empty($this->_name)) {
            return $this->_name;
        } else {
            return 'Unknown';
        }
    }

    function getVersion()
    {
        return $this->_version;
    }

    function getPlatform()
    {
        if (!empty($this->_platform)) {
            return $this->_platform;
        } else {
            return 'Unknown';
        }
    }

    function getUserAgent()
    {
        return $this->_user_agent;
    }

    function getInfo()
    {
        return "<strong>Browser Name:</strong> {$this->getBrowser()}<br/>\n" .
            "<strong>Browser Version:</strong> {$this->getVersion()}<br/>\n" .
            "<strong>Browser User Agent String:</strong> {$this->getUserAgent()}<br/>\n" .
            "<strong>Platform:</strong> {$this->getPlatform()}<br/>";
    }
}

function random_num($length)
{
    $text = "";
    if ($length < 5) {
        $length = 5;
    }
    $len = rand(4, $length);
    for ($i = 0; $i < $len; $i++) {
        $text .= rand(0, 9);
    }
    return $text;
}

function track($db, $version)
{
    $sql = "INSERT INTO `page_views` (`id`, `page`, `ip`, `date`, `time`, `referer`, `session_id`, `device`, `browser`, `agent`) VALUES (NULL, :page, :ip, :date, :time, :referer, :session_id, :device, :browser, :agent);";
    $params = array(
        ':page' => "updateregid",
        ':ip' => getIpAddress(),
        ':date' => date('Y-m-d'),
        ':time' => date('H:i:s'),
        ':referer' => "ANDROID APK",
        ':session_id' => session_id(),
        ':device' => $version,
        ':browser' => "UNKNOWN",
        ':agent' => "UNKNOWN"
    );
    $db->prepare($sql)->execute($params);
}
