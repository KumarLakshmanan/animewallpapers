<?php


if (isset($_GET['adminid'])) {
    $adminid = $_GET['adminid'];
    $directory = $baseDirectory . "/json/social/";
    if (!file_exists($directory)) {
        mkdir($directory, 0777, true);
    }
    $filename = $directory . $adminid . ".json";
    if (file_exists($filename)) {
        $json = file_get_contents($filename);
        $json = json_decode($json, true);
    } else {
        $json = array(
            "facebook" => "",
            "instagram" => "",
            "twitter" => "",
            "linkedin" => "",
            "youtube" => "",
        );
    }
}
?>
<h3><b>Edit Department Social Media</b></h3>
<br />
<div class="row">
    <div class="col-md-6">
        <h6>Facebook</h6>
        <div class="p-2">
            <input type="text" class="form-control" id="facebook" placeholder="Enter facebook link" required value="<?= $json['facebook'] ?? "" ?>">
        </div>
    </div>
    <div class="col-md-6">
        <h6>Instagram</h6>
        <div class="p-2">
            <input type="text" class="form-control" id="instagram" placeholder="Enter instagram link" required value="<?= $json['instagram'] ?? "" ?>">
        </div>
    </div>
    <div class="col-md-6">
        <h6>Twitter</h6>
        <div class="p-2">
            <input type="text" class="form-control" id="twitter" placeholder="Enter twitter link" required value="<?= $json['twitter'] ?? "" ?>">
        </div>
    </div>
    <div class="col-md-6">
        <h6>Linkedin</h6>
        <div class="p-2">
            <input type="text" class="form-control" id="linkedin" placeholder="Enter linkedin link" required value="<?= $json['linkedin'] ?? "" ?>">
        </div>
    </div>
    <div class="col-md-6">
        <h6>Youtube</h6>
        <div class="p-2">
            <input type="text" class="form-control" id="youtube" placeholder="Enter youtube link" required value="<?= $json['youtube'] ?? "" ?>">
        </div>
    </div>
</div>
<div class="p-2">
    <button type="button" class="w-100 btn btn-primary saveButton">Save changes</button>
</div>

<link href="<?= $baseUrl ?>css/image-uploader.min.css" rel="stylesheet" />
<script src="<?= $baseUrl ?>js/image-uploader.min.js"></script>
<script>
    $(document).ready(() => {
        imageUploader.init(".input-images");
    })
    let _xUserData = {
        "baseURL": "<?= $baseUrl ?>",
        "auth": "<?= $_SESSION['token'] ?>",
        "username": "<?= $_SESSION['email'] ?>",
    };
    $(".saveButton").click(function() {
        var facebook = $("#facebook").val();
        var instagram = $("#instagram").val();
        var twitter = $("#twitter").val();
        var linkedin = $("#linkedin").val();
        var youtube = $("#youtube").val();

        swal({
            title: 'Are you sure to publish ?',
            text: "The post will be saved and pushed to the server!",
            icon: 'warning',
            buttons: true,
            dangerMode: true,
        }).then((willDelete) => {
            if (willDelete) {
                var formData = new FormData();
                formData.append("mode", "addadminsocial");
                formData.append("facebook", facebook);
                formData.append("instagram", instagram);
                formData.append("twitter", twitter);
                formData.append("linkedin", linkedin);
                formData.append("youtube", youtube);
                formData.append("adminid", "<?= $adminid ?>");
                $(".preloader").show();
                $.ajax({
                    url: "<?= $apiUrl ?>",
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
                                text: "Admin social links Added Successfully",
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
    $("#flexCheckDefault").click(function() {
        if ($(this).is(":checked")) {
            $(".scheduleDateTime").show();
        } else {
            $(".scheduleDateTime").hide();
        }
    });
</script>