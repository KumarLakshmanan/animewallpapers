<?php


if (isset($_GET['adminid'])) {
    $adminid = $_GET['adminid'];
    $directory = $baseDirectory . "/json/about/";
    if (!file_exists($directory)) {
        mkdir($directory, 0777, true);
    }
    $filename = $directory . $adminid . ".json";
    if (file_exists($filename)) {
        $json = file_get_contents($filename);
        $json = json_decode($json, true);
    } else {
        $json = array(
            "content" => "",
        );
    }
}
?>
<script src="https://cdnjs.cloudflare.com/ajax/libs/tinymce/6.1.2/tinymce.min.js"></script>
<h3><b>Enter About the Department</b></h3>
<br />
<div class="p-2">
    <textarea class="form-control" id="tinyMce" rows="3"></textarea>
</div>
<div class="p-2">
    <button type="button" class="w-100 btn btn-primary saveButton">Save changes</button>
</div>

<link href="<?= $baseUrl ?>css/image-uploader.min.css" rel="stylesheet" />
<script src="<?= $baseUrl ?>js/image-uploader.min.js"></script>
<script>
    tinymce.init({
        branding: false,
        selector: '#tinyMce',
        plugins: 'advlist autolink lists link image charmap preview anchor pagebreak',
        toolbar_mode: 'floating',
        images_upload_url: 'uploadImage.php',
        automatic_uploads: false,
        setup: function(editor) {
            editor.on('init', function(e) {
                editor.setContent(`<?= $json['content'] ?? "" ?>`);
            });
        }
    });
    let _xUserData = {
        "baseURL": "<?= $baseUrl ?>",
        "auth": "<?= $_SESSION['token'] ?>",
        "username": "<?= $_SESSION['email'] ?>",
    };
    $(".saveButton").click(function() {
        var content = tinymce.get('tinyMce').getContent();
        swal({
            title: 'Are you sure to publish ?',
            text: "The post will be saved and pushed to the server!",
            icon: 'warning',
            buttons: true,
            dangerMode: true,
        }).then((willDelete) => {
            if (willDelete) {
                var formData = new FormData();
                formData.append("mode", "addadminabout");
                formData.append("content", content);
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
                                text: "Department About Added Successfully",
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