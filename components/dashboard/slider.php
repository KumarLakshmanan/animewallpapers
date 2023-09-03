<?php
$sliderJson = json_decode(file_get_contents($baseDirectory . 'json/slider.json'),true);
?>
<div class="row">
    <div class="col-md-12">
        <div class="p-2">
            <label for="images">Slider Images *</label>
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
        "alreadyUploaded": "<?php echo join(",",$sliderJson); ?>",
    };
    $(".saveButton").click(function() {
        var name = $("#name").val();
        var content = $(".texteditor-content").val();
        var images = [];
        var payment = $("#payment").val();
        var date = $("#date").val();
        $(".uploaded-image").each(function() {
            images.push($(this).attr("data-name"));
        });
        if ($(".uploaded-image").length == 0) {
            swal({
                icon: 'error',
                type: 'error',
                title: 'Oops...',
                text: 'Please Upload The Image',
            })
        } else {
            swal({
                title: 'Are you sure to publish?',
                text: "The post will be saved and pushed to the server!",
                icon: 'warning',
                buttons: true,
                dangerMode: true,
            }).then((willDelete) => {
                if (willDelete) {
                    var formData = new FormData();
                    formData.append("mode", "addslider");
                    formData.append("images", images);
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
                                    text: "Your slider has been saved successfully!",
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
