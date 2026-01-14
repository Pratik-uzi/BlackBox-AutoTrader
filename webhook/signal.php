<?php
// Allow POST requests only
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    exit('Only POST allowed');
}

// Read raw webhook data
$input = file_get_contents("php://input");

if (!$input) {
    http_response_code(400);
    exit('Empty payload');
}

// MT5 Files directory path (CHANGE THIS)
$filePath = "C:/Users/Public/Documents/MetaTrader 5/MQL5/Files/signal.txt";

// Write signal to file
file_put_contents($filePath, $input);

// Respond back to TradingView
http_response_code(200);
echo "Signal received";
?>
