<?php

?>
<h3><b>Fill the Following Form To Add New Category</b></h3>
<br />
<div class="row">
    <div class="col-md-6">
        <h6>Sub Category Name *</h6>
        <div class="p-2">
            <input type="text" class="form-control" id="title" placeholder="Enter Job name" required>
        </div>
    </div>
    <div class="col-md-6">
        <h6>Main Category *</h6>
        <div class="p-2">
            <select class="form-control" id="maincategory" required>
                <option value="">Select maincategory Category</option>
                <?php
                $sql = "SELECT id, name FROM `categories`";
                $stmt = $pdoConn->prepare($sql);
                $stmt->execute();
                $categories = $stmt->fetchAll();
                foreach ($categories as $category) {
                    echo '<option value="' . $category['id'] . '">' . $category['name'] . '</option>';
                }
                ?>
            </select>
        </div>
    </div>
    <div class="col-md-12 col-lg-12 col-sm-12 col-xs-12">
        <div class="p-2">
            <label for="images">Sub Category Image</label>
            <div class="input-images" id="images" style="padding-top: .5rem;background: white"></div>
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
        var images = [];
        $(".uploaded-image").each(function() {
            images.push($(this).attr("data-name"));
        });
        var description = $("#description").val();
        var title = $("#title").val();
        var link = $("#link").val();

        if (images.length == 0) {
            swal({
                icon: 'error',
                type: 'error',
                title: 'Oops...',
                text: 'Please upload at least one image!',
            })
        } else if (title == "") {
            swal({
                icon: 'error',
                type: 'error',
                title: 'Oops...',
                text: 'Please fill all required the fields!',
            })
        } else if ($("#maincategory").val() == "") {
            swal({
                icon: 'error',
                type: 'error',
                title: 'Oops...',
                text: 'Please select maincategory!',
            })
        } else {
            swal({
                title: 'Are you sure to publish?',
                text: "The Job will be saved to the server!",
                icon: 'warning',
                buttons: true,
                dangerMode: true,
            }).then((willDelete) => {
                if (willDelete) {
                    var formData = new FormData();
                    formData.append("mode", "addSubCategory");
                    formData.append("title", title);
                    formData.append("image", images[0]);
                    formData.append("categoryid", $("#maincategory").val());
                    $(".preloader").show();
                    $.ajax({
                        url: "<?= $apiUrl ?>",
                        type: "POST",
                        data: formData,
                        processData: false,
                        contentType: false,
                        success: function(response) {
                            $(".preloader").hide();
                            if (response.error.code == '#200') {
                                swal({
                                    title: 'Success!',
                                    icon: 'success',
                                    text: "Your Category has been published!",
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
</script>