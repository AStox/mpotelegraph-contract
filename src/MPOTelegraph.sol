// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// SPDX-License-Identifier: MIT
// pragma solidity >=0.8.0 <0.9.0;

/// @dev Note that this is a very stripped down ERC-721 knock-off with gas savings as the highest priority. Some features may be unsafe or missing.

struct Telegram {
    address from;
    bytes32 line1;
    bytes32 line2;
    bytes32 line3;
    bytes32 line4;
}

contract MPOTelegraph {
    address private owner;
    uint256 public PRICE = 1000000000000000; // 0.001 eth
    string public name = "Metaversal Post Office Telegraph";
    string public symbol = "MPOT";

    constructor() {
        owner = msg.sender;
    }

    // ERC721 --------------------------------------------------------------->>
    mapping(uint256 => address) private ownership;
    mapping(uint256 => Telegram) private metadata;
    mapping(uint256 => address) private approvedForToken;
    mapping(address => mapping(address => bool)) private approvedForAll;
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Mint(address indexed from, uint256 indexed tokenId, string text);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function ownerOf(uint256 _tokenId) public view virtual returns (address) {
        return ownership[_tokenId];
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public {
        require(msg.sender == ownership[_tokenId] || msg.sender == getApproved(_tokenId) || isApprovedForAll(ownership[_tokenId], msg.sender), "Unauthorized");
        require(ownership[_tokenId] == _from, "The from address does not own this token"); 

        // Clear approvals from the previous owner
        approvedForToken[_tokenId] = address(0);

        ownership[_tokenId] = _to;
        emit Transfer(_from, _to, _tokenId);
    }

    function approve(address _candidate, uint256 _tokenId) public virtual {
        require(msg.sender == ownership[_tokenId] || isApprovedForAll(ownership[_tokenId], msg.sender), "Unauthorized");
        approvedForToken[_tokenId] = _candidate;
        emit Approval(ownership[_tokenId], _candidate, _tokenId);
    }

    function getApproved(uint256 _tokenId) public view virtual returns (address) {
        return approvedForToken[_tokenId];
    }

    function setApprovalForAll(address _candidate, bool _approved) public virtual {
        approvedForAll[msg.sender][_candidate] = _approved;
        emit ApprovalForAll(msg.sender, _candidate, _approved);
    }

    function isApprovedForAll(address _owner, address _candidate) public view virtual returns (bool) {
        return approvedForAll[_owner][_candidate];
    }

    // UNSAFE - USE AT OWN RISK
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public { transferFrom(_from, _to, _tokenId); }
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) public { transferFrom(_from, _to, _tokenId); }
    
    // Ignored
    function balanceOf(address _owner) public view virtual returns (uint256) { return 0; }
    // <<--------------------------------------------------------------- ERC721

    function tokenURI(uint256 _tokenId) public view virtual returns (string memory) {
        return string(abi.encodePacked("https://9amtetu7r1.execute-api.us-east-1.amazonaws.com/?id=", uint2str(_tokenId)));
    }
    // <<------------------------------------------------------- ERC721Metadata


    // ERC165 --------------------------------------------------------------->>
    function supportsInterface(bytes4 _interfaceId) public pure returns (bool) {
        return _interfaceId == 0x80ac58cd || // IERC721
            _interfaceId == 0x5b5e139f || // IERC721Metadata
            _interfaceId == 0x01ffc9a7; // IERC165
    }
    // <<--------------------------------------------------------------- ERC165

    // Other functions ------------------------------------------------------>>

    // function mint(uint256 id, address to, string calldata line1, string calldata line2, string calldata line3, string calldata line4) public payable {
    function mint(uint256 id, address to, string calldata text) public payable {
    // function mint(uint256 id, address to, string memory input) public payable {
        require(msg.value >= PRICE, "Send more ETH");
        require(ownership[id] == address(0), "ID already in use");

        ownership[id] = to;
        // metadata[id] = Telegram(msg.sender, s2b32(line1),s2b32(line2),s2b32(line3),s2b32(line4));
        // metadata[id] = input;

        emit Transfer(address(0), to, id);
        emit Mint(msg.sender, id, text);
    }

    // function reply(uint256 burnId, string calldata line1, string calldata line2, string calldata line3, string calldata line4) public {
    //     require(msg.sender == ownership[burnId] || msg.sender == getApproved(burnId) || isApprovedForAll(ownership[burnId], msg.sender), "Unauthorized");

    //     emit Transfer(ownership[burnId], address(0), burnId);
    //     ownership[burnId] = metadata[burnId].from;
    //     emit Transfer(address(0), metadata[burnId].from, burnId);
    //     metadata[burnId] = Telegram(msg.sender, s2b32(line1),s2b32(line2),s2b32(line3),s2b32(line4));
    // }

    // Required by etherscan.io
    function totalSupply() public view virtual returns (uint256) {
        return 1;
    }

    function withdraw() public payable {
        (bool success, ) = payable(owner).call{value: msg.value}("");
        require(success, "Could not transfer money to contractOwner");
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

}
