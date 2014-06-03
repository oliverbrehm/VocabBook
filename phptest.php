<html>

<head>

<title>Test Title</title>

</head>

<body>

<h1>PHP Test</h1>
<br>
<br>

<?php
    
    $name = $_POST['name'];
    $pswd = $_POST['pswd'];
    
    echo "POST Test<br>";

    if($name) {
        echo "Name: $name <br>";
    }
    
    if($pswd) {
        echo "Password: $pswd <br>";
    }
    
?>

</body>