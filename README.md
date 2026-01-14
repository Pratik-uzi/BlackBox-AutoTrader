# Blackbox AutoTrader

Automated trading system that connects **TradingView → TTA Chrome Extension → PHP Webhook → MT5 Expert Advisor (EA)**.

This setup allows you to execute trades automatically on **MT5 brokers like Exness** using TradingView alerts — **no TradingView Premium required**.

---

## 🔗 System Architecture

```
TradingView Strategy
        ↓ (Alert)
TTA Chrome Extension
        ↓ (Webhook POST)
PHP (signal.php)
        ↓ (signal.txt)
MT5 Expert Advisor
```

---

## 📁 Project Structure

```
Blackbox-AutoTrader/
├── webhook/
│   └── signal.php
├── tradingview/
│   └── alert_template.txt
├── mt5/
│   └── BlackboxEA.mq5
├── images/
│   ├── tta_settings.png
│   ├── tradingview_alert.png
│   └── mt5_files_path.png
├── README.md
└── LICENSE
```

---

## 🧩 Step 1: TradingView Setup

1. Open **TradingView**
2. Add your **Blackbox Pine Script strategy** to the chart
3. Make sure **Buy/Sell alert conditions** are present in the script

📌 Recommended timeframe: **5M or 15M (XAUUSD)**

---

## 🧩 Step 2: Install TTA Chrome Extension

1. Open Chrome Web Store
2. Install **"Alert from TradingView to Anywhere (TTA)"**
3. Pin the extension

📸 Example:

![TTA Extension](images/tta_settings.png)

---

## 🧩 Step 3: Create TradingView Alert (VERY IMPORTANT)

1. Click **Create Alert** on TradingView
2. Condition → Your **Buy or Sell signal**
3. Enable **Webhook URL**
4. Paste:

```
http://localhost/Blackbox-AutoTrader/webhook/signal.php
```

5. Alert message format (EXAMPLE):

```
XAUUSD,BUY,{{close}},2358.20,2388.00,1
```

or

```
XAUUSD,SELL,{{close}},2391.50,2355.00,0.8
```

📸 Example:

![TradingView Alert](images/tradingview_alert.png)

---

## 🧩 Step 4: PHP Webhook Setup

1. Install **XAMPP** or **WAMP**
2. Place project folder inside:

```
htdocs/Blackbox-AutoTrader/
```

3. Start **Apache Server**
4. Open browser and test:

```
http://localhost/Blackbox-AutoTrader/webhook/signal.php
```

---

## 🧩 Step 5: MT5 Setup

1. Open **MT5 → File → Open Data Folder**
2. Go to:

```
MQL5/Files/
```

3. This is where `signal.txt` will be written

📸 Example:

![MT5 Files](images/mt5_files_path.png)

4. Compile & attach `BlackboxEA.mq5` to **XAUUSD chart**
5. Enable **AutoTrading**

---

## 🛡️ Safety Notes

* Use **demo first**
* Recommended risk: **0.5% – 1% per trade**
* One trade at a time
* VPS recommended for 24/7 execution

---

## 🧠 Tips

* Alerts must be **manual formatted** (TradingView placeholders are limited)
* PHP file path must match **MT5 Files directory** exactly
* Do NOT open multiple charts with the same EA

---

## 📜 License

MIT License — free to use, modify, and distribute.
