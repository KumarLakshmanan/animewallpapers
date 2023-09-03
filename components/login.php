<?php
$csrfToken = md5(uniqid(rand(), TRUE));
$_SESSION['csrfToken'] = $csrfToken;
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login to Dashboard</title>
    <script src="<?php echo $baseUrl ?>js/jquery.min.js"></script>
    <script src="<?= $baseUrl ?>js/sweetalert.js"></script>
    <style media="screen">
        .align {
            -webkit-box-align: center;
            -ms-flex-align: center;
            align-items: center;
            display: -webkit-box;
            display: -ms-flexbox;
            display: flex;
            -webkit-box-orient: vertical;
            -webkit-box-direction: normal;
            -ms-flex-direction: column;
            flex-direction: column;
            -webkit-box-pack: center;
            -ms-flex-pack: center;
            justify-content: center;
        }

        .grid {
            margin-left: auto;
            margin-right: auto;
            max-width: 320px;
            max-width: 20rem;
            width: 90%;
        }

        .hidden {
            border: 0;
            clip: rect(0 0 0 0);
            height: 1px;
            margin: -1px;
            overflow: hidden;
            padding: 0;
            position: absolute;
            width: 1px;
        }

        .icon {
            display: inline-block;
            fill: #000;
            font-size: 16px;
            font-size: 1rem;
            height: 1em;
            vertical-align: middle;
            width: 1em;
        }

        /* layout/base.css */

        body {
            color: #000;
            font-family: 'Open Sans', sans-serif;
            font-size: 14px;
            font-size: 0.875rem;
            font-weight: 400;
            height: 100%;
            line-height: 1.5;
            margin: 0;
            min-height: 100vh;
        }

        input {
            background-image: none;
            border: 0;
            color: inherit;
            font: inherit;
            margin: 0;
            outline: 0;
            padding: 0;
            -webkit-transition: background-color 0.3s;
            transition: background-color 0.3s;
        }

        input[type='submit'] {
            cursor: pointer;
        }


        .form input[type='password'],
        .form input[type='text'],
        .form input[type='submit'] {
            width: 100%;
        }

        .form__field {
            display: -webkit-box;
            display: -ms-flexbox;
            display: flex;
            margin: 14px;
            margin: 0.875rem;
        }

        .form__input {
            -webkit-box-flex: 1;
            -ms-flex: 1;
            flex: 1;
        }

        .login {
            color: #000;
        }

        .login label,
        .login input[type='text'],
        .login input[type='password'],
        .login input[type='submit'] {
            border-radius: 0.25rem;
            padding: 16px;
            padding: 1rem;
        }

        .login label {
            background-color: #eee;
            border-bottom-right-radius: 0;
            border-top-right-radius: 0;
            padding-left: 20px;
            padding-left: 1.25rem;
            padding-right: 20px;
            padding-right: 1.25rem;
        }

        .login input[type='password'],
        .login input[type='text'] {
            background-color: #eee;
            border-bottom-left-radius: 0;
            border-top-left-radius: 0;
        }

        .login input[type='submit'] {
            background-color: #ea4c88;
            color: #000;
            font-weight: 700;
            text-transform: uppercase;
        }

        .login input[type='submit']:focus,
        .login input[type='submit']:hover {
            background-color: #d44179;
        }

        .text--center {
            text-align: center;
        }
    </style>
</head>

<body class="align text--center">
    <div class="grid">
        <form action="<?= $baseUrl ?>api/v1.php" method="POST" class="form login">
            <input type="hidden" name="mode" value="adminlogin">
            <img src="img/applogo.png" alt="" width="100px" style="border-radius: 50%;margin-bottom: 20px;">
            <h2 class="login__title">Login to Wallpapers Admin</h2>
            <div class="form__field">
                <label for="login__username"><svg class="icon">
                        <use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#user"></use>
                    </svg>
                </label>
                <input id="login__username" type="text" name="email" class="form__input" placeholder="Email or Username" required>
            </div>
            <div class="form__field">
                <label for="login__password"><svg class="icon">
                        <use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#lock"></use>
                    </svg></label>
                <input id="login__password" type="password" name="password" class="form__input" placeholder="Password" required>
            </div>
            <input type="hidden" name="csrfToken" value="<?= $csrfToken ?>">
            <div class="form__field">
                <input type="submit" value="Sign In">
            </div>
        </form>
    </div>
    <svg xmlns="http://www.w3.org/2000/svg" class="icons">
        <symbol id="arrow-right" viewBox="0 0 1792 1792">
            <path d="M1600 960q0 54-37 91l-651 651q-39 37-91 37-51 0-90-37l-75-75q-38-38-38-91t38-91l293-293H245q-52 0-84.5-37.5T128 1024V896q0-53 32.5-90.5T245 768h704L656 474q-38-36-38-90t38-90l75-75q38-38 90-38 53 0 91 38l651 651q37 35 37 90z" />
        </symbol>
        <symbol id="lock" viewBox="0 0 1792 1792">
            <path d="M640 768h512V576q0-106-75-181t-181-75-181 75-75 181v192zm832 96v576q0 40-28 68t-68 28H416q-40 0-68-28t-28-68V864q0-40 28-68t68-28h32V576q0-184 132-316t316-132 316 132 132 316v192h32q40 0 68 28t28 68z" />
        </symbol>
        <symbol id="user" viewBox="0 0 1792 1792">
            <path d="M1600 1405q0 120-73 189.5t-194 69.5H459q-121 0-194-69.5T192 1405q0-53 3.5-103.5t14-109T236 1084t43-97.5 62-81 85.5-53.5T538 832q9 0 42 21.5t74.5 48 108 48T896 971t133.5-21.5 108-48 74.5-48 42-21.5q61 0 111.5 20t85.5 53.5 62 81 43 97.5 26.5 108.5 14 109 3.5 103.5zm-320-893q0 159-112.5 271.5T896 896 624.5 783.5 512 512t112.5-271.5T896 128t271.5 112.5T1280 512z" />
        </symbol>
    </svg>
    <script>
        $(document).ready(function() {
            $("form").submit(function(e) {
                e.preventDefault();
                var form = $(this);
                var url = form.attr('action');
                var data = form.serialize();
                $.ajax({
                    type: "POST",
                    url: url,
                    data: data,
                    success: function(data) {
                        if (data.error.code == '#200') {
                            swal({
                                title: 'Success',
                                text: "Login Success",
                                icon: 'success',
                                confirmButtonText: 'Ok'
                            }).then((result) => {
                                window.location.href = '<?= $baseUrl ?>';
                            });
                        } else {
                            swal({
                                title: 'Error',
                                text: data.error.description,
                                icon: 'error',
                                confirmButtonText: 'Ok'
                            });
                        }
                    }
                });
            });
        });
    </script>
</body>

</html>