<?php
$type = 1;
if (isset($_REQUEST['type'])) {
    $type = $_REQUEST['type'];
}
if (isset($_GET['contentid'])) {
    $id = $_GET['contentid'];
    $sql = "SELECT * FROM contents WHERE id = $id";
    $stmt = $pdoConn->prepare($sql);
    $stmt->execute();
    $propertyEdit = $stmt->fetchAll();
    if (count($propertyEdit) > 0) {
?>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/tinymce/6.1.2/tinymce.min.js"></script>
        <h3><b>Add Content</b></h3>
        <br />
        <div class="row">
        <div class="col-md-6">
                <h6>Content Title*</h6>
                <div class="p-2">
                    <input type="text" class="form-control" id="name" placeholder="Enter admin name" required value="<?= $propertyEdit[0]['title'] ?>">
                </div>
            </div>
            <div class="col-md-6">
                <h6>Seniority Index*</h6>
                <div class="p-2">
                    <input type="text" class="form-control" id="index" placeholder="Enter seniority index" required value="<?= $propertyEdit[0]['sindex'] ?>">
                </div>
            </div>
            <div class="col-md-6">
                <h6>Content Type*</h6>
                <div class="p-2">
                    <select class="form-control" id="type" value="<?= $propertyEdit[0]['type'] ?>">
                        <option value="1" <?php if ($propertyEdit[0]['type'] == 1) {
                                                echo "selected";
                                            } ?>>About Us</option>
                        <option value="2" <?php if ($propertyEdit[0]['type'] == 2) {
                                                echo "selected";
                                            } ?>>Facilities</option>
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
                "alreadyUploaded": "<?php echo ($propertyEdit[0]['icon']); ?>",
            };
            $(".saveButton").click(function() {
                var name = $("#name").val();
                var type = $("#type").val();
                var proiflePhoto = "<?php echo ($propertyEdit[0]['icon']); ?>";
                var index = $("#index").val();
                $(".uploaded-image").each(function() {
                    proiflePhoto = ($(this).attr("data-name"));
                });
                var content = tinymce.get('tinyMce').getContent();
                if ($(".uploaded-image").length == 0) {
                    swal({
                        icon: 'error',
                        type: 'error',
                        title: 'Oops...',
                        text: 'Please Upload The Image',
                    })
                } else if (name == "" || proiflePhoto == "" || content == "") {
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
                            formData.append("mode", "updatecontent");
                            formData.append("name", name);
                            formData.append("content", content);
                            formData.append("type", type);
                            formData.append("icon", proiflePhoto);
                            formData.append("index", index);
                            formData.append("contentid", "<?= $id ?>");
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
                        editor.setContent(`<?= $propertyEdit[0]['content'] ?>`);
                    });
                }
            });
        </script>

        <style>
            #keywordsInput {
                width: 100%;
                float: left;
            }

            #keywordsInput>input {
                padding: 7px;
                width: calc(100%);
            }
        </style>
<?php
    }
}
