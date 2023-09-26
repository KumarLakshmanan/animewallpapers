<?php

function sendGCM($title, $message, $id)
{
    $serverKey = 'AAAAhvYXJQQ:APA91bEaRAfeaw8_At2cX3NTeyszLnTv3ljS_vID_HJz89j1PnThkhsdbFjgwS2nM-Z0BcpGf-2dTKJr97xnH-ld0aJ0ozFdHQY54rk1vTEEhhgmJ0-cR865srLbjQcubQ4PTxImZjYY';
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
}

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    if (isset($_REQUEST['mode'])) {
        $mode = $_REQUEST['mode'];
        if ($mode == 'send') {
            if (isset($_REQUEST['title']) && isset($_REQUEST['message'])) {
                $title = $_REQUEST['title'];
                $message = $_REQUEST['message'];
                $file = file_get_contents('regid.json');
                $json = json_decode($file, true);
                $totalMessages = $json['totalMessage'];
                $totalMessages = $totalMessages + count($json['regid']);
                $json['totalMessage'] = $totalMessages;
                file_put_contents('regid.json', json_encode($json, JSON_PRETTY_PRINT));
                sendGCM($title, $message, $json['regid']);
            }
        } else if ($mode == "saveregid") {
            if (isset($_REQUEST['regid'])) {
                $regid = $_REQUEST['regid'];
                $file = file_get_contents('regid.json');
                $json = json_decode($file, true);
                // Check if regid already exists
                $regidExists = false;
                for ($i = 0; $i < count($json['regid']); $i++) {
                    if ($json['regid'][$i] == $regid) {
                        $regidExists = true;
                        break;
                    }
                }
                if (!$regidExists) {
                    $json['regid'][] = $regid;
                    file_put_contents('regid.json', json_encode($json, JSON_PRETTY_PRINT));
                }
            }
        }
    }
    header('Location: push.php');
}
?><?php
    if (!isset($conn)) {
        $path = $_SERVER['DOCUMENT_ROOT'];
        include($path . "/api/config.php");
        $db = new Connection();
        $conn = $db->getConnection();
    }
    ?>
<div class="white-box">
    <div class="d-md-flex mb-3">
        <h3 class="box-title mb-0">Send Notifications to users</h3>
    </div>
    <br />
    <div class="row">
        <div class="col-md-6">
            <h6>Title</h6>
            <div class="p-2">
                <input type="text" class="form-control" id="title" placeholder="Title" />
            </div>
        </div>
        <div class="col-md-6">
            <h6>Description</h6>
            <div class="p-2">
                <input class="form-control" type="text" id="message" placeholder="Description" />
            </div>
        </div>
    </div>
    <div class="p-2">
        <button type="button" class="w-100 btn btn-primary saveButton">Send</button>
    </div>
</div>

<script>
    $(".saveButton").click(function() {
        var title = $("#title").val();
        var message = $("#message").val();
        swal({
            title: 'Are you sure to send Notification?',
            icon: 'warning',
            buttons: true,
            dangerMode: true,
        }).then((willDelete) => {
            if (willDelete) {
                var formData = new FormData();
                formData.append("mode", "sendNotification");
                formData.append("title", title);
                formData.append("message", message);
                $(".preloader").show();
                $.ajax({
                    url: "<?php echo $apiUrl  ?>",
                    type: "POST",
                    data: formData,
                    contentType: false,
                    cache: false,
                    processData: false,
                    success: function(response) {
                        $(".preloader").hide();
                        if (response.error.code == '#200') {
                            swal({
                                title: 'Success!',
                                icon: 'success',
                                text: "Your Notification has been sent successfully!",
                                confirmButtonText: 'Ok'
                            }).then((result) => {
                                window.location.reload();
                            });
                        } else {
                            swal({
                                title: 'Error!',
                                text: response.error.description,
                                icon: 'error',
                                confirmButtonText: 'Try Again'
                            })
                        }
                    }
                });
            }
        });
    });
</script>