<?php


if (isset($_GET['adminid'])) {
    $id = $_GET['adminid'];
    $sql = "SELECT * FROM admins WHERE id = $id";
    $stmt = $pdoConn->prepare($sql);
    $stmt->execute();
    $propertyEdit = $stmt->fetchAll();
    if (count($propertyEdit) > 0) {
?>
        <h3><b>Add Admin</b></h3>
        <br />
        <div class="row">
            <div class="col-md-6">
                <h6>Admin Name*</h6>
                <div class="p-2">
                    <input type="text" class="form-control" id="name" placeholder="Enter admin name" required value="<?= $propertyEdit[0]['fullname'] ?>">
                </div>
            </div>
            <div class="col-md-6">
                <h6>Seniority Index*</h6>
                <div class="p-2">
                    <input type="text" class="form-control" id="index" placeholder="Enter seniority index" required value="<?= $propertyEdit[0]['sindex'] ?>">
                </div>
            </div>
            <div class="col-md-6">
                <h6>Admin Email*</h6>
                <div class="p-2">
                    <input type="email" class="form-control" id="email" placeholder="Enter admin email" required value="<?= $propertyEdit[0]['email'] ?>">
                </div>
            </div>
            <div class="col-md-6">
                <h6>Admin Phone*</h6>
                <div class="p-2">
                    <input type="phone" class="form-control" id="phone" placeholder="Enter admin phone" required value="<?= $propertyEdit[0]['phone'] ?>">
                </div>
            </div>
            <div class="col-md-6">
                <h6>Admin Password*</h6>
                <div class="p-2">
                    <input type="text" class="form-control" id="password" placeholder="Enter admin password" required value="<?= $propertyEdit[0]['password'] ?>">
                </div>
            </div>
            <div class="col-md-6">
                <h6>Admin Color*</h6>
                <div class="p-2">
                    <input type="color" class="form-control" id="color" placeholder="Enter admin color" required value="<?= $propertyEdit[0]['color'] ?>">
                </div>
            </div>
            <div class="col-md-6">
                <div class="p-2">
                    <h6>Type*</h6>
                    <select class="form-select" id="type" aria-label="Default select example">
                        <option value="1" <?= $propertyEdit[0]['departmenttype'] == 1 ? 'selected' : '' ?>>Aided Department</option>
                        <option value="2" <?= $propertyEdit[0]['departmenttype'] == 2 ? 'selected' : '' ?>>Self Financed Department</option>
                        <option value="3" <?= $propertyEdit[0]['departmenttype'] == 3 ? 'selected' : '' ?>>Extension Activities</option>
                        <option value="4" <?= $propertyEdit[0]['departmenttype'] == 4 ? 'selected' : '' ?>>Clubs & Other Forums</option>
                    </select>
                </div>
            </div>
            <div class="col-md-12 col-lg-12 col-sm-12 col-xs-12">
                <div class="p-2">
                    <h6>Admin Profile Picture (single image)*</h6>
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
                "alreadyUploaded": "<?php echo ($propertyEdit[0]['profile']); ?>",
            };
            $(".saveButton").click(function() {
                var name = $("#name").val();
                var email = $("#email").val();
                var phone = $("#phone").val();
                var password = $("#password").val();
                var type = $("#type").val();
                var color = $("#color").val();
                var proiflePhoto = '';
                var index = $("#index").val();
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
                } else if (name == "" || email == "" || phone == "" || password == "" || type == "" || index == "") {
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
                            formData.append("mode", "updateadmin");
                            formData.append("name", name);
                            formData.append("email", email);
                            formData.append("phone", phone);
                            formData.append("password", password);
                            formData.append("type", type);
                            formData.append("profile", proiflePhoto);
                            formData.append("color", color);
                            formData.append("adminid", "<?= $id ?>");
                            formData.append("index", index);
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
                                            text: "Admin Added Successfully",
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
            $("#flexCheckDefault").click(function() {
                if ($(this).is(":checked")) {
                    $(".scheduleDateTime").show();
                } else {
                    $(".scheduleDateTime").hide();
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
