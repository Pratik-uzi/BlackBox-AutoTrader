# Blackbox Advance Trading Strategy (TradingView → MT5)

This project automates the **Blackbox Advance Trading Strategy** for XAUUSD and FX pairs using:

- TradingView (Pine Script v5)
- Webhook alerts (TTA Chrome Extension)
- MetaTrader 5 Expert Advisor (MQL5)

---

## Strategy Overview

The Blackbox strategy is based on **institutional stop-hunt behavior**:

1. Initial breakout of HTF support/resistance
2. Fake continuation (trap phase)
3. Re-cross of the **Laxman Rekha** (original breakout level)
4. Entry only after confirmation
5. Stop loss placed with a **buffer beyond entry**
6. Target at the **next major HTF support/resistance**

---

## Architecture

TradingView Strategy
↓ (Webhook Alert)
TTA Chrome Extension
↓
Local Webhook Listener (PHP)
↓
MT5 EA (Execution Only)


---

## Risk Management

- Risk per trade: **0.8% – 1%**
- Position size calculated automatically
- One trade per symbol at a time
- Partial take profit supported

---

## Setup Instructions

### 1. TradingView
- Add the Pine Script strategy
- Create alerts for Buy/Sell conditions
- Use webhook via TTA Chrome Extension

### 2. Webhook
- Run `signal.php` locally (XAMPP/WAMP)
- Ensure it writes to `MT5/Files/signal.txt`

### 3. MetaTrader 5
- Place EA in `Experts/`
- Allow file access
- Attach EA to the correct symbol chart

---

## Disclaimer

This software is for educational purposes only.
Use at your own risk.
