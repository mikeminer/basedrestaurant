# 🍝 Based Pasta Ristorante — dApp link :https://mikeminer.github.io/basedrestaurant/
featured on https://devfolio.co/projects/based-restaurant-e84d and Farcaster Integration

Welcome to **Based Pasta Ristorante**, a playful Web3 restaurant experience built as a decentralized application (dApp) on the **Base network**. 

Users can order NFT-based pasta dishes, send on-chain messages, and tip the waiter in ETH — all from a sleek, one-page interface.

---

## 🚀 Features
- **NFT Pasta Menu** – Choose from iconic Italian pasta dishes (including *Pappardelle al Ragù*) as free on-chain orders.
- **On-chain Orders** – Your pasta choice and note are stored immutably on the Base blockchain.
- **ETH Tips** – Tip your waiter in ETH; the higher your tip, the faster the simulated delivery countdown.
- **Transaction Display** – See your transaction hash and a direct BaseScan link.
- **ENS Integration** – Displays ENS avatar and address for `pappardelle.eth`.
- **Social Sharing** – Quickly DM your order to the chef on X or DeBank.

---

## 🧩 Tech Stack
- **HTML / CSS / Vanilla JavaScript** (fully client-side)
- **[ethers.js v6](https://docs.ethers.io/v6/)** for Web3 interactions
- **Base Mainnet RPC** for blockchain connectivity
- **ENS API** via ethers.js for name and avatar resolution

---

## ⚙️ Setup Instructions

### 1️⃣ Clone the repo
```bash
git clone https://github.com/mikeminer/basedrestaurant.git
cd based-pasta-dapp
```

### 2️⃣ Open the file
Simply open `Based Pasta D App (html)` in your browser.
No build tools required.

---

## 💸 How It Works
1. **Connect your wallet** (MetaMask recommended).
2. **Select your pasta dish** from the dropdown menu.
3. **Add an optional note** (max 64 characters).
4. **Enter an ETH tip amount** (optional).
5. **Click “🍽️ Place order (on-chain)”**.
6. The transaction is sent to the Base network.
7. Once complete, your order summary appears with:
   - BaseScan transaction link
   - Copy-to-clipboard summary
   - Share buttons for X and DeBank

---

## 📫 Social Links
- **Chef (Waiter) ENS:** [pappardelle.eth](https://app.ens.domains/name/pappardelle.eth)
- **X Profile:** [@AnonimoCommando](https://x.com/AnonimoCommando)
- **DeBank:** [0x5d69c42a3a481d0ccfd88cfa8a2a08e2bf456134](https://debank.com/profile/0x5d69c42a3a481d0ccfd88cfa8a2a08e2bf456134)

---

## 🧠 Notes
- The current smart contract address in the demo is static (`0x37e3a8d3ba53f43d955F83B54cBE4C0d39A10b83`). Replace it with your own when deploying.
- To integrate real contract logic, replace the mock `press()` function with your own write interaction.
- ENS resolution and BaseScan links are auto-generated.

---

## 📜 License
This project is released under the **MIT License**.

---

### 🍷 Buon Appetito & Enjoy the Based Pasta Experience!
