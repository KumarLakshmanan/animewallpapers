<h3><b>Add Staff</b></h3>
<br />
<div class="row">
    <div class="col-md-6">
        <h6>Staff Name*</h6>
        <div class="p-2">
            <input type="text" class="form-control" id="name" placeholder="Enter Staff name" required>
        </div>
    </div>
    <div class="col-md-6">
        <h6>Seniority Index*</h6>
        <div class="p-2">
            <input type="text" class="form-control" id="index" placeholder="Enter seniority index" required>
        </div>
    </div>
    <div class="col-md-6">
        <h6>Staff age</h6>
        <div class="p-2">
            <input type="number" class="form-control" id="age" placeholder="Enter Staff age" required>
        </div>
    </div>
    <div class="col-md-6">
        <h6>Staff position*</h6>
        <div class="p-2">
            <input type="text" class="form-control" id="position" placeholder="Enter Staff position" required>
        </div>
    </div>
    <div class="col-md-6">
        <h6>Staff qualification</h6>
        <div class="p-2">
            <input type="text" class="form-control" id="qualificaiton" placeholder="Enter Staff qualificaiton" required>
        </div>
    </div>
    <div class="col-md-6">
        <h6>Staff Phone*</h6>
        <div class="p-2">
            <input type="number" class="form-control" id="phone" placeholder="Enter Staff phone" required>
        </div>
    </div>
    <div class="col-md-6">
        <h6>Staff Type*</h6>
        <div class="p-2">
            <input type="text" class="form-control" id="type" placeholder="Enter Staff type" required>
        </div>
    </div>
    <div class="col-md-6">
        <h6>Staff Gender*</h6>
        <div class="p-2">
            <select class="form-select" id="gender" aria-label="Default select example">
                <option value="Male">Male</option>
                <option value="Female">Female</option>
            </select>
        </div>
    </div>
    <div class="col-md-6">
        <h6>Staff Department*</h6>
        <div class="p-2">
            <select class="form-select" id="department" aria-label="Default select example">
                <option value="0">Select Department</option>
                <option value="iqac">IQAC</option>
                <?php
                $sql = "SELECT * FROM admins WHERE role != 'admin'";
                $stmt = $pdoConn->prepare($sql);
                $stmt->execute();
                $departments = $stmt->fetchAll();
                foreach ($departments as $department) {
                ?>
                    <option value="<?= $department['id'] ?>"><?= $department['fullname'] ?>
                        <?php
                        if ($department['departmenttype'] == "1") {
                            echo "(Aided)";
                        } elseif ($department['departmenttype'] == "2") {
                            echo "(Self)";
                        }
                        ?>
                    </option>
                <?php
                }
                ?>
            </select>
        </div>
    </div>
    <div class="col-md-6">
        <h6>Profile/Bio Data PDF</h6>
        <div class="p-2">
            <input type="file" class="form-control" id="pdf" placeholder="Enter Staff pdf" required>
        </div>
    </div>
    <div class="col-md-12 col-lg-12 col-sm-12 col-xs-12">
        <div class="p-2">
            <h6>Profile Picture (single image)</h6>
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
    });
    let _xUserData = {
        "baseURL": "<?= $baseUrl ?>",
        "auth": "<?= $_SESSION['token'] ?>",
        "username": "<?= $_SESSION['email'] ?>",
    };
    $(".saveButton").click(function() {
        var name = $("#name").val();
        var age = $("#age").val();
        var position = $("#position").val();
        var qualificaiton = $("#qualificaiton").val();
        var phone = $("#phone").val();
        var department = $("#department").val();
        var gender = $("#gender").val();
        var index = $("#index").val();
        var type = $("#type").val();
        var profilePhoto = '';
        $(".uploaded-image").each(function() {
            profilePhoto = ($(this).attr("data-name"));
        });

        if (name == "" || position == "" || index == "" || qualificaiton == "" || phone == "" || gender == "" || department == "") {
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
                    formData.append("mode", "addstaff");
                    formData.append("name", name);
                    formData.append("age", age);
                    formData.append("index", index);
                    formData.append("position", position);
                    formData.append("qualificaiton", qualificaiton);
                    formData.append("phone", phone);
                    formData.append("department", department);
                    formData.append("gender", gender);
                    formData.append("type", type);
                    formData.append("pdf", $("#pdf")[0].files[0]);
                    formData.append("profile", profilePhoto);
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
                                    text: "Staff Added Successfully",
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