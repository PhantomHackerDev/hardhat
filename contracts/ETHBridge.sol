// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@layerzerolabs/solidity-examples/contracts/lzApp/NonblockingLzApp.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ETHBridge is NonblockingLzApp {
    IERC20 public usdtToken;
    address public ownerBridge;
    uint16 public bscChainId;

    event TokensUnlocked(address indexed recipient, uint256 amount, string sourceChain);

    constructor(address _lzEndpoint, address _usdtTokenAddress, uint16 _bscChainId) NonblockingLzApp(_lzEndpoint) {
        ownerBridge = msg.sender;
        usdtToken = IERC20(_usdtTokenAddress);
        bscChainId = _bscChainId;
    }

    // Handle the cross-chain message from BSC and unlock tokens
    function _nonblockingLzReceive(uint16 _srcChainId, bytes memory _srcAddress, uint64 _nonce, bytes memory _payload) internal override {
        (address recipient, uint256 amount) = abi.decode(_payload, (address, uint256));

        // Unlock the tokens for the recipient on Ethereum
        require(usdtToken.transfer(recipient, amount), "Token transfer failed");

        emit TokensUnlocked(recipient, amount, "BSC");
    }

    // Function to send tokens back to BSC
    function sendTokensBack(uint256 amount, address recipient) public payable {
        require(usdtToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        // Prepare the payload to send back to BSC
        bytes memory payload = abi.encode(msg.sender, amount, recipient);
        
        // Send cross-chain message back to BSC
        _lzSend(bscChainId, payload, payable(msg.sender), address(0x0), bytes(""), msg.value);
    }
}
