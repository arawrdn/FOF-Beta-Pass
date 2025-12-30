// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract GMBuildersNFT {
    string public name = "GM Builders";
    string public symbol = "GMB";
    uint256 public constant MAX_SUPPLY = 666;
    uint256 public constant MINT_PRICE = 0.00001 ether;
    uint256 public constant MAX_PER_WALLET = 2;
    
    uint256 public totalSupply;
    uint256 public immutable saleEndTime;
    address public immutable owner;

    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(address => uint256) public mintedCount;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    constructor() {
        owner = msg.sender;
        saleEndTime = block.timestamp + 24 hours;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function mint(uint256 quantity) external payable {
        require(block.timestamp <= saleEndTime, "Sale ended");
        require(totalSupply + quantity <= MAX_SUPPLY, "Exceeds max supply");
        require(mintedCount[msg.sender] + quantity <= MAX_PER_WALLET, "Exceeds limit per wallet");
        require(msg.value >= MINT_PRICE * quantity, "Insufficient ETH");

        for (uint256 i = 0; i < quantity; i++) {
            uint256 tokenId = totalSupply + 1;
            _owners[tokenId] = msg.sender;
            _balances[msg.sender]++;
            totalSupply++;
            emit Transfer(address(0), msg.sender, tokenId);
        }
    }

    function withdraw() external onlyOwner {
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address tokenOwner = _owners[tokenId];
        require(tokenOwner != address(0), "Token does not exist");
        return tokenOwner;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_owners[tokenId] != address(0), "Token does not exist");
        
        string memory svg = string(abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            '<defs><linearGradient id="grad" x1="0%" y1="0%" x2="100%" y2="100%">',
            '<stop offset="0%" style="stop-color:orange;stop-opacity:1" />',
            '<stop offset="100%" style="stop-color:black;stop-opacity:1" /></linearGradient></defs>',
            '<rect width="100%" height="100%" fill="url(#grad)" />',
            '<text x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" font-family="Arial" font-size="24" fill="white" font-weight="bold">GM Builders</text>',
            '</svg>'
        ));

        return string(abi.encodePacked(
            "data:application/json;base64,",
            _base64(abi.encodePacked(
                '{"name": "GM Builders #', _toString(tokenId), '", ',
                '"description": "FCFS GM Builders on Base", ',
                '"image": "data:image/svg+xml;base64,', _base64(bytes(svg)), '"}'
            ))
        ));
    }

    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function _base64(bytes memory data) internal pure returns (string memory) {
        string memory table = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        uint256 len = data.length;
        if (len == 0) return "";
        string memory result = new string(4 * ((len + 2) / 3));
        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)
            for { let i := 0 } lt(i, len) { } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xFFFFFF)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                mstore8(add(resultPtr, 1), mload(add(tablePtr, and(shr(12, input), 0x3F))))
                mstore8(add(resultPtr, 2), mload(add(tablePtr, and(shr(6, input), 0x3F))))
                mstore8(add(resultPtr, 3), mload(add(tablePtr, and(input, 0x3F))))
                resultPtr := add(resultPtr, 4)
            }
            switch mod(len, 3)
            case 1 { mstore8(sub(resultPtr, 2), 0x3d) mstore8(sub(resultPtr, 1), 0x3d) }
            case 2 { mstore8(sub(resultPtr, 1), 0x3d) }
        }
        return result;
    }
}
