<?php
$type = 1;
if (isset($_REQUEST['type'])) {
    $type = $_REQUEST['type'];
}
?>
<script src="https://cdnjs.cloudflare.com/ajax/libs/tinymce/6.1.2/tinymce.min.js"></script>
<h3><b>Add Content</b></h3>
<br />
<div class="row">
    <div class="col-md-6">
        <h6>Content Title*</h6>
        <div class="p-2">
            <input type="text" class="form-control" id="name" placeholder="Enter admin name" required>
        </div>
    </div>
    <div class="col-md-6">
        <h6>Seniority Index*</h6>
        <div class="p-2">
            <input type="text" class="form-control" id="index" placeholder="Enter admin name" required>
        </div>
    </div>
    <div class="col-md-6">
        <h6>Content Type*</h6>
        <div class="p-2">
            <select class="form-control" id="type">
                <option value="1" <?= $type == "1" ? "selected" : "" ?>>About us</option>
                <option value="2" <?= $type == "2" ? "selected" : "" ?>>Facilities</option>
            </select>
        </div>
    </div>
    <div class="col-md-12 col-lg-12 col-sm-12 col-xs-12">
        <div class="p-2">
            <h6>Content Icon (single image)*</h6>
            <div class="input-images" id="images" style="padding-top: .5rem;background: white"></div>
        </div>
    </div>
    <div class="col-md-12 col-lg-12 col-sm-12 col-xs-12">
        <div class="p-2">
            <h6>Content*</h6>
            <textarea class="form-control" id="tinyMce" rows="3"></textarea>
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
        var name = $("#name").val();
        var type = $("#type").val();
        var proiflePhoto = '';
        var index = $("#index").val();
        var content = tinymce.get('tinyMce').getContent();
        $(".uploaded-image").each(function() {
            proiflePhoto = ($(this).attr("data-name"));
        });
        if ($(".uploaded-image").length == 0) {
            swal({
                icon: 'error',
                type: 'error',
                title: 'Oops...',
                text: 'Please Upload The Image',
            })
        } else if (name == "" || proiflePhoto == "" || type == "") {
            swal({
                icon: 'error',
                type: 'error',
                title: 'Oops...',
                text: 'Please fill all the fields!',
            })
        } else {
            swal({
                title: 'Are you sure to publish ?',
                text: "The post will be saved and pushed to the server!",
                icon: 'warning',
                buttons: true,
                dangerMode: true,
            }).then((willDelete) => {
                if (willDelete) {
                    var formData = new FormData();
                    formData.append("mode", "addcontent");
                    formData.append("name", name);
                    formData.append("content", content);
                    formData.append("index", index);
                    formData.append("type", type);
                    formData.append("icon", proiflePhoto);
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
                                    text: "Content Added Successfully",
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
        }
    });
    tinymce.init({
        branding: false,
        selector: '#tinyMce',
        plugins: 'advlist autolink lists link image charmap preview anchor pagebreak',
        toolbar_mode: 'floating',
        images_upload_url: 'uploadImage.php',
        automatic_uploads: false,
        setup: function(editor) {
            editor.on('init', function(e) {
                editor.setContent('');
            });
        }
    });
</script>