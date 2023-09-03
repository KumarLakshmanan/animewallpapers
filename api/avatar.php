<?php
class Initials
{
    /**
     * Generate initials from a name
     *
     * @param string $name
     * @return string
     */
    public function generate(string $name): string
    {
        $words = explode(' ', $name);
        if (count($words) >= 3) {
            return mb_strtoupper(
                mb_substr($words[0], 0, 1, 'UTF-8') .
                    mb_substr(end($words), 0, 1, 'UTF-8'),
                'UTF-8'
            );
        }
        return $this->makeInitialsFromSingleWord($name);
    }

    /**
     * Make initials from a word with no spaces
     *
     * @param string $name
     * @return string
     */
    protected function makeInitialsFromSingleWord(string $name): string
    {
        preg_match_all('#([A-Z]+)#', $name, $capitals);
        if (count($capitals[1]) >= 2) {
            return mb_substr(implode('', $capitals[1]), 0, 2, 'UTF-8');
        }
        return mb_strtoupper(mb_substr($name, 0, 2, 'UTF-8'), 'UTF-8');
    }
}


if (!function_exists('createDefaultAvatar')) {
    function createDefaultAvatar(
        string $text = 'FF',
        array $bgColor = [51, 105, 30],
        array $textColor = [255, 255, 255],
        int $fontSize = 60,
        int $width = 200,
        int $height = 200,
        string $font = './roboto.ttf'
    ) {
        $image = imagecreate($width, $height);

        imagecolorallocate($image, $bgColor[0], $bgColor[1], $bgColor[2]);

        $fontColor = imagecolorallocate($image, $textColor[0], $textColor[1], $textColor[2]);
        $initial = new Initials();
        $text = $initial->generate($text);
        $textBoundingBox = imagettfbbox($fontSize, 0, $font, $text);

        $y = abs(ceil(($height - $textBoundingBox[5]) / 2));
        $x = abs(ceil(($width - $textBoundingBox[2]) / 2));

        imagettftext($image, $fontSize, 0, $x, $y, $fontColor, $font, $text);

        return $image;
    }
}

if (isset($_GET['username'])) {
    try {
        include("./config.php");
        $db = new Connection();
        $pdoConn = $db->getConnection();
        $username = $_GET['username'];
        $sql = "SELECT * FROM users WHERE username = :username";
        $stmt = $pdoConn->prepare($sql);
        $stmt->bindParam(':username', $username);
        $stmt->execute();
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($user) {
            if ($user['photo']) {
                header('Content-Type: image/png');
                $md5Hash = md5($user['photo']);
                $file = "../uploads/avatars/$md5Hash.png";
                if (file_exists($file)) {
                    echo file_get_contents($file);
                } else {
                    $picture = file_get_contents($user['photo']);
                    $file = "../uploads/avatars/$md5Hash.png";
                    file_put_contents($file, $picture);
                    echo $picture;
                }
                exit;
            } else {
                $name = $user['fullname'];
            }
        } else {
            $name = $username;
        }
    } catch (\Throwable $th) {
        $name = "E2";
    }
} else {
    $name = 'E3';
}
$img = createDefaultAvatar($name);

header("Content-Type: image/png");

imagepng($img);
imagedestroy($img);
