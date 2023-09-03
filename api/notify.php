<?php

session_start();
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
ini_set('log_errors', true);
ini_set('error_log', './php-error.log');
include("./config.php");

$active = array(
    "cB6t9TXIRjOlC9kXIuG8mC:APA91bG3XY8KRJicKClew1ZSVG6VOZGff_8sfMuxSLSQxF0LBbHJSqUfQWguXc7oJ3m2q6xGiSGbamEDem6zCJA2siy3HVLJzkV40Tdn4D6uxx8l0P1tsQDlvfBoM4be6eWXq4e_fHbX"
);
sendGCM(
    "New Job Offer Added",
    "Dear User, A new job offer has been added. Please check it out.",
    $active,
    "jobs"
);
