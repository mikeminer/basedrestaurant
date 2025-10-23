<!doctype html>
<html lang="it">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>The Big On-Chain Button</title>
  <style>
    :root {
      --maxw: 720px;
      --radius: 14px;
    }
    body {
      font-family: system-ui, -apple-system, Segoe UI, Roboto, Arial, sans-serif;
      margin: 0; padding: 0;
      background: #0f1115; color: #f5f7fb;
      display: flex; align-items: center; justify-content: center;
      min-height: 100vh;
    }
    .card {
      width: min(92vw, var(--maxw));
      background: #131722;
      border: 1px solid #1f2430;
      border-radius: var(--radius);
      padding: 20px 20px 24px;
      box-shadow: 0 10px 30px rgba(0,0,0,0.35);
    }
    .row { display: flex; gap: 14px; flex-wrap: wrap; align-items: center; }
    .stats {
      display: grid; grid-template-columns: repeat(3, 1fr); gap: 10px; width: 100%;
    }
    .stat {
      background: #0e1320; border: 1px solid #1b2130; border-radius: 12px; padding: 12px;
      text-align: center;
    }
    .stat .label { font-size: 12px; color: #9aa4b2; }
    .stat .value { font-size: 22px; font-weight: 700; letter-spacing: .4px; }
    .cta {
      display: flex; gap: 12px; flex-wrap: wrap; align-items: center; margin: 18px 0 8px;
    }
    input[type="text"], input[type="number"] {
      flex: 1 1 200px;
      background: #0e1320; color: #e8eefc; border: 1px solid #1b2130; border-radius: 10px;
      padding: 12px 14px; font-size: 14px; outline: none;
    }
    input::placeholder { color: #6d7b91; }
    button {
      cursor: pointer; border: none; border-radius: 999px; padding: 16px 22px; font-weight: 800;
      letter-spacing: .3px; font-size: 18px; transition: transform .05s ease;
      background: #ffffff; color: #0a0c10;
      box-shadow: 0 8px 24px rgba(255,255,255,.08), inset 0 -4px 0 rgba(0,0,0,.08);
    }
    button:hover { transform: translateY(-1px); }
    button:active { transform: translateY(1px) scale(.99); }
    .bigbutton {
      display: block; width: 100%;
      margin: 12px 0 8px; padding: 22px 26px; font-size: 22px;
      animation: pulse 1.8s infinite;
    }
    @keyframes pulse {
      0% { box-shadow: 0 0 0 0 rgba(255,255,255,.18); }
      70% { box-shadow: 0 0 0 16px rgba(255,255,255,0); }
      100% { box-shadow: 0 0 0 0 rgba(255,255,255,0); }
    }
    .feed {
      margin-top: 16px; max-height: 320px; overflow: auto;
      background: #0e1320; border:1px solid #1b2130; border-radius: 12px; padding: 10px;
    }
    .item {
      padding: 10px 8px; border-bottom: 1px dashed #1f2636; font-size: 14px;
      display: flex; justify-content: space-between; gap: 12px;
    }
    .item:last-child { border-bottom: none; }
    .muted { color: #8a96a8; font-size: 12px; }
    .ok { color: #a7f3d0; }
    .err { color: #fca5a5; }
    .topbar {
      display:flex; justify-content: space-between; align-items: center; margin-bottom:12px;
    }
    .link { color: #9cc2ff; text-decoration: none; font-size: 13px; }
  </style>
</head>
<body>
  <div class="card">
    <div class="topbar">
      <div><strong>The Big On-Chain Button</strong></div>
      <a class="link" id="explorerLink" href="#" target="_blank" rel="noopener">Explorer ↗</a>
    </div>

    <div class="stats">
      <div class="stat">
        <div class="label">Total presses</div>
        <div class="value" id="totalPresses">—</div>
      </div>
      <div class="stat">
        <div class="label">Your presses</div>
        <div class="value" id="yourPresses">—</div>
      </div>
      <div class="stat">
        <div class="label">Cooldown</div>
        <div class="value" id="cooldown">—</div>
      </div>
    </div>

    <div class="cta">
      <input id="message" type="text" maxlength="64" placeholder="Lascia un messaggio (max 64 char)" />
      <input id="tip" type="number" step="0.0001" min="0" placeholder="Tip in ETH (opzionale)" />
      <button id="connect">Connetti wallet</button>
    </div>

    <button id="press" class="bigbutton">🚀 Premi il Bottone</button>
    <div id="status" class="muted">Stato: non connesso.</div>

    <div class="feed" id="feed"></div>
  </div>

  <!-- Ethers v6 da CDN -->
  <script src="https://cdn.jsdelivr.net/npm/ethers@6.13.2/dist/ethers.umd.min.js"></script>
  <script>
    // === CONFIG ===
    const CONTRACT_ADDRESS = "YOUR_DEPLOYED_CONTRACT_ADDRESS"; // <— sostituisci dopo il deploy
    const EXPLORER_BASE = "https://sepolia.etherscan.io/address/"; // cambia in base alla rete
    const ABI = [
      {"inputs":[],"stateMutability":"nonpayable","type":"constructor"},
      {"anonymous":false,"inputs":[
        {"indexed":true,"internalType":"address","name":"user","type":"address"},
        {"indexed":false,"internalType":"uint256","name":"totalPresses","type":"uint256"},
        {"indexed":false,"internalType":"uint256","name":"userPresses","type":"uint256"},
        {"indexed":false,"internalType":"string","name":"message","type":"string"},
        {"indexed":false,"internalType":"uint256","name":"tip","type":"uint256"}
      ],"name":"Pressed","type":"event"},
      {"inputs":[],"name":"cooldownSeconds","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},
      {"inputs":[],"name":"owner","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},
      {"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"presses","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},
      {"inputs":[{"internalType":"string","name":"message_","type":"string"}],"name":"press","outputs":[],"stateMutability":"payable","type":"function"},
      {"inputs":[],"name":"tipsBalance","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},
      {"inputs":[],"name":"totalPresses","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},
      {"inputs":[{"internalType":"address payable","name":"to","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"withdraw","outputs":[],"stateMutability":"nonpayable","type":"function"},
      {"inputs":[{"internalType":"uint256","name":"seconds_","type":"uint256"}],"name":"setCooldown","outputs":[],"stateMutability":"nonpayable","type":"function"},
      {"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"lastPressAt","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"}
    ];

    // === STATE ===
    let provider, signer, contract, currentAccount;

    const $ = (id) => document.getElementById(id);
    const statusEl = $("status");
    const feedEl = $("feed");

    $("explorerLink").href = EXPLORER_BASE + CONTRACT_ADDRESS;

    function addFeedItem({user, total, userPresses, message, tip}) {
      const item = document.createElement("div");
      item.className = "item";
      const short = user.slice(0,6) + "…" + user.slice(-4);
      item.innerHTML = `
        <div>
          <div><strong>${short}</strong> ha premuto ${message ? `— “${escapeHtml(message)}”` : ""}</div>
          <div class="muted">Utente: ${userPresses} • Tip: ${tip}</div>
        </div>
        <div>#${total}</div>
      `;
      feedEl.prepend(item);
      // keep feed reasonable
      const max = 100;
      while (feedEl.children.length > max) feedEl.removeChild(feedEl.lastChild);
    }

    function escapeHtml(str) {
      return str.replace(/[&<>"']/g, s => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#039;'}[s]));
    }

    async function connect() {
      if (!window.ethereum) {
        status("Installa un wallet (es. MetaMask) per continuare.", true);
        return;
      }
      provider = new ethers.BrowserProvider(window.ethereum);
      await provider.send("eth_requestAccounts", []);
      signer = await provider.getSigner();
      currentAccount = await signer.getAddress();
      contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, signer);

      status(`Connesso: ${currentAccount.slice(0,6)}…${currentAccount.slice(-4)}`, false);
      $("connect").textContent = "Connesso";
      $("connect").disabled = true;

      await refreshStats();
      subscribeEvents();
    }

    async function refreshStats() {
      if (!contract) return;
      const [total, myPresses, cd] = await Promise.all([
        contract.totalPresses(),
        contract.presses(currentAccount),
        contract.cooldownSeconds(),
      ]);
      $("totalPresses").textContent = total.toString();
      $("yourPresses").textContent = myPresses.toString();
      $("cooldown").textContent = cd.toString() + "s";
    }

    function subscribeEvents() {
      contract.on("Pressed", (user, totalPresses, userPresses, message, tip) => {
        addFeedItem({
          user,
          total: totalPresses.toString(),
          userPresses: userPresses.toString(),
          message,
          tip: tip ? ethers.formatEther(tip) + " ETH" : "0"
        });
        $("totalPresses").textContent = totalPresses.toString();
        if (currentAccount && user.toLowerCase() === currentAccount.toLowerCase()) {
          $("yourPresses").textContent = userPresses.toString();
        }
      });
    }

    async function press() {
      if (!contract) return status("Connettiti prima al wallet.", true);
      try {
        const msg = $("message").value.trim();
        const tipEth = $("tip").value ? $("tip").value.trim() : "0";
        const tx = await contract.press(msg, { value: ethers.parseEther(tipEth || "0") });
        status("Transazione inviata… in attesa di conferma.");
        await tx.wait();
        status("✅ Bottone premuto! Guarda la feed qui sotto.", false);
      } catch (err) {
        const reason = (err && err.shortMessage) || (err && err.message) || String(err);
        status("Errore: " + reason, true);
      }
    }

    function status(text, isError=false) {
      statusEl.textContent = "Stato: " + text;
      statusEl.className = isError ? "err" : "ok";
    }

    $("connect").addEventListener("click", connect);
    $("press").addEventListener("click", press);

    // Autoconnect se l'utente ha già dato permessi
    (async function auto() {
      if (window.ethereum) {
        const accs = await window.ethereum.request({ method: "eth_accounts" });
        if (accs && accs.length) connect();
      }
    })();
  </script>
</body>
</html>
