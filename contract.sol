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

    // =========================
    // ===== ABI UTILITIES =====
    // =========================

    /// @notice Selector delle funzioni (prime 4 bytes di keccak256 della firma)
    function selectorPress() external pure returns (bytes4) {
        return this.press.selector; // equivalente a bytes4(keccak256("press(string)"))
    }

    function selectorSetCooldown() external pure returns (bytes4) {
        return this.setCooldown.selector; // "setCooldown(uint256)"
    }

    function selectorWithdraw() external pure returns (bytes4) {
        return this.withdraw.selector; // "withdraw(address,uint256)"
    }

    /// @notice Calldata completo (selector + params) per press(string)
    function calldataPress(string calldata message_) external pure returns (bytes memory) {
        return abi.encodeWithSelector(this.press.selector, message_);
    }

    /// @notice Calldata completo per setCooldown(uint256)
    function calldataSetCooldown(uint256 seconds_) external pure returns (bytes memory) {
        return abi.encodeWithSelector(this.setCooldown.selector, seconds_);
    }

    /// @notice Calldata completo per withdraw(address,uint256)
    function calldataWithdraw(address to, uint256 amount) external pure returns (bytes memory) {
        return abi.encodeWithSelector(this.withdraw.selector, to, amount);
    }

    /// @notice Calcola selector da una firma arbitraria, es. "transfer(address,uint256)"
    function selectorOf(string calldata signature) external pure returns (bytes4) {
        return bytes4(keccak256(bytes(signature)));
    }

    /// @notice Concatena selector (da firma) e parametri già encodati (abi.encode(...))
    function makeCalldata(string calldata signature, bytes calldata encodedParams) external pure returns (bytes memory) {
        bytes4 sel = bytes4(keccak256(bytes(signature)));
        return bytes.concat(sel, encodedParams);
    }

    /// @notice Decodifica i parametri di press(string) da un calldata (ignora i primi 4 bytes di selector)
    function decodePressParams(bytes calldata data) external pure returns (string memory message_) {
        require(data.length >= 4, "Bad calldata");
        bytes calldata params = data[4:];
        (message_) = abi.decode(params, (string));
    }

    /// @notice Decodifica i parametri di setCooldown(uint256) da un calldata
    function decodeSetCooldownParams(bytes calldata data) external pure returns (uint256 seconds_) {
        require(data.length >= 4, "Bad calldata");
        bytes calldata params = data[4:];
        (seconds_) = abi.decode(params, (uint256));
    }

    /// @notice Decodifica i parametri di withdraw(address,uint256) da un calldata
    function decodeWithdrawParams(bytes calldata data) external pure returns (address to, uint256 amount) {
        require(data.length >= 4, "Bad calldata");
        bytes calldata params = data[4:];
        (to, amount) = abi.decode(params, (address, uint256));
    }

    /// @notice Hash della firma dell'evento Pressed (topic0)
    function eventPressedTopic0() external pure returns (bytes32) {
        return keccak256("Pressed(address,uint256,uint256,string,uint256)");
    }
}
