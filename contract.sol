// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * The Big On-Chain Button
 * - Premi il bottone: incrementa il contatore globale
 * - Traccia i "taps" per address
 * - Cooldown anti-spam (default: 15s)
 * - Tip opzionale al contratto (withdraw da parte dell'owner)
 */
contract BigButton {
    event Pressed(address indexed user, uint256 totalPresses, uint256 userPresses, string message, uint256 tip);

    address public owner;
    uint256 public totalPresses;
    uint256 public cooldownSeconds = 15;

    mapping(address => uint256) public presses;       // quante pressioni ha fatto l'utente
    mapping(address => uint256) public lastPressAt;   // timestamp ultima pressione per cooldown

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /// @notice Cambia il cooldown (in secondi)
    function setCooldown(uint256 seconds_) external onlyOwner {
        require(seconds_ <= 3600, "Cooldown too high");
        cooldownSeconds = seconds_;
    }

    /// @notice Premi il bottone. Puoi includere un messaggio breve e una tip opzionale via msg.value.
    function press(string calldata message_) external payable {
        uint256 last = lastPressAt[msg.sender];
        require(block.timestamp >= last + cooldownSeconds, "Cooldown active");

        totalPresses += 1;
        presses[msg.sender] += 1;
        lastPressAt[msg.sender] = block.timestamp;

        emit Pressed(msg.sender, totalPresses, presses[msg.sender], message_, msg.value);
        // eventuale tip resta nel contratto finche' l'owner non fa withdraw
    }

    /// @notice Preleva le tip accumulate
    function withdraw(address payable to, uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "Insufficient balance");
        to.transfer(amount);
    }

    /// @notice Saldo accumulato da tip
    function tipsBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
