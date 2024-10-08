// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@layerzerolabs/solidity-examples/contracts/lzApp/NonblockingLzApp.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BSCBridge is NonblockingLzApp {
    IERC20 public usdtToken;
    address public ownerBridge;
    uint16 public ethChainId;

    event TokensLocked(address indexed user, uint256 amount, string destinationChain, address recipient);

    constructor(address _lzEndpoint, address _usdtTokenAddress, uint16 _ethChainId) NonblockingLzApp(_lzEndpoint) {
        ownerBridge = msg.sender;
        usdtToken = IERC20(_usdtTokenAddress);
        ethChainId = _ethChainId;
    }

    // Lock USDT and send the message to Ethereum
    function lockAndSendTokens(uint256 amount, address recipient) public payable {
        require(amount > 0, "Amount must be greater than zero");
        require(usdtToken.transferFrom(msg.sender, address(this), amount), "Token transfer failed");

        // Prepare the payload to be sent to the Ethereum contract
        bytes memory payload = abi.encode(msg.sender, amount, recipient);

        // Send cross-chain message using LayerZero
        _lzSend(ethChainId, payload, payable(msg.sender), address(0x0), bytes(""), msg.value);

        emit TokensLocked(msg.sender, amount, "Ethereum", recipient);
    }

    // This is called when a cross-chain message is received
    function _nonblockingLzReceive(uint16 _srcChainId, bytes memory _srcAddress, uint64 _nonce, bytes memory _payload) internal override {
        (address recipient, uint256 amount) = abi.decode(_payload, (address, uint256));

        // Unlock the tokens for the recipient
        require(usdtToken.transfer(recipient, amount), "Unlock failed");
    }
}
