// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/**


 */

contract Frown is ERC721A, Ownable, ReentrancyGuard {
    using ECDSA for bytes32;

    mapping(address => uint256) public numberOfGEMintsOnAddress;
    mapping(address => uint256) public numberOfWLMintsOnAddress;
    mapping(address => uint256) public numberOfOGMintsOnAddress;
    mapping(address => uint256) public totalClaimed;
    mapping(address => uint256) public airdropList;

    //Sale flags
    bool public GEsaleActive = false;
    bool public OGsaleActive = false;
    bool public WLsaleActive = false;
    bool public saleActive = false;

    //Mint limits
    uint256 public ADDRESS_MAX_MINTS = 12;
    uint256 public ADDRESS_GE_MAX_MINTS = 3;
    uint256 public ADDRESS_OG_MAX_MINTS = 3;
    uint256 public ADDRESS_WL_MAX_MINTS = 3;
    uint256 public PUBLIC_MINT_PER_TX = 12;

    //Supply
    uint256 public maxSupply;

    //Pricing
    uint256 public GEprice = 0.08 ether;
    uint256 public OGprice = 0.08 ether;
    uint256 public WLprice = 0.12 ether;
    uint256 public price = 0.18 ether;

    //Pre-reveal IPFS link
    string private _baseTokenURI = ""; //naming of this seems off?

    //Merkle roots
    bytes32 public GEMerkleRoot =
        0x5ca83a030c01fd6b97579c236835bf3c16ab8ee596f5986d9203ac3c5a37e8f6;
    bytes32 public OGMerkleRoot =
        0x5ca83a030c01fd6b97579c236835bf3c16ab8ee596f5986d9203ac3c5a37e8f6;
    bytes32 public WLMerkleRoot =
        0xb962a1d6a53354253b8d3eb626122ca11c747cab1d3f6bdb1395b26359cbb7bc;
    //	bytes32 private freeClaim; //why private ?

    event Claimed(uint256 count, address sender);
    //	event FreeClaimActive(bool live);
    event ClaimAirdrop(uint256 count, address sender);
    event Airdrop(uint256 count, address sender);

    constructor() ERC721A("TXtest", "TXTEST") {}

    /**
        GE mint
    **/

    function mintGESale(uint256 numberOfMints, bytes32[] calldata _merkleProof)
        external
        payable
    {
        require(GEsaleActive, "GE Presale must be active to mint");

        require(
            MerkleProof.verify(
                _merkleProof,
                GEMerkleRoot,
                keccak256(abi.encodePacked(msg.sender))
            ),
            "Invalid OG proof - Caller not on OG whitelisted"
        );

        require(numberOfMints > 0, "Sender is trying to mint zero token"); //optional: this is a general check for all mint functions that can be factor out into a separate internal mint function

        require(
            numberMinted(msg.sender) + numberOfMints <= ADDRESS_MAX_MINTS,
            "Sender is trying to mint more than allocated tokens"
        ); //optional: this is a general check for all mint functions that can be factor out into a separate internal mint function

        require(
            numberOfGEMintsOnAddress[msg.sender] + numberOfMints <=
                ADDRESS_GE_MAX_MINTS,
            "Sender is trying to mint more than their whitelist amount"
        );
        require(
            totalSupply() + numberOfMints <= maxSupply,
            "This would exceed the max number of mints allowed"
        ); //optional: this is a general check for all mint functions that can be factor out into a separate internal mint function
        require(
            msg.value >= numberOfMints * GEprice,
            "Not enough ether to mint"
        );

        numberOfGEMintsOnAddress[msg.sender] += numberOfMints;
        _safeMint(msg.sender, numberOfMints);
    }

    /**
     * OG mint
     */
    function mintOGSale(uint256 numberOfMints, bytes32[] calldata _merkleProof)
        external
        payable
    {
        require(OGsaleActive, "OG Presale must be active to mint");

        require(
            MerkleProof.verify(
                _merkleProof,
                OGMerkleRoot,
                keccak256(abi.encodePacked(msg.sender))
            ),
            "Invalid OG proof - Caller not on OG whitelisted"
        );

        require(numberOfMints > 0, "Sender is trying to mint zero token"); //optional: this is a general check for all mint functions that can be factor out into a separate internal mint function

        require(
            numberMinted(msg.sender) + numberOfMints <= ADDRESS_MAX_MINTS,
            "Sender is trying to mint more than allocated tokens"
        ); //optional: this is a general check for all mint functions that can be factor out into a separate internal mint function

        require(
            numberOfOGMintsOnAddress[msg.sender] + numberOfMints <=
                ADDRESS_OG_MAX_MINTS,
            "Sender is trying to mint more than their whitelist amount"
        );
        require(
            totalSupply() + numberOfMints <= maxSupply,
            "This would exceed the max number of mints allowed"
        ); //optional: this is a general check for all mint functions that can be factor out into a separate internal mint function
        require(
            msg.value >= numberOfMints * OGprice,
            "Not enough ether to mint"
        );

        numberOfOGMintsOnAddress[msg.sender] += numberOfMints;
        _safeMint(msg.sender, numberOfMints);
    }

    /**
     * Whitelist mint
     */
    function mintWLSale(uint256 numberOfMints, bytes32[] calldata _merkleProof)
        external
        payable
    {
        require(WLsaleActive, "Sale must be active to mint");

        require(
            MerkleProof.verify(
                _merkleProof,
                WLMerkleRoot,
                keccak256(abi.encodePacked(msg.sender))
            ),
            "Invalid proof - Caller not whitelisted"
        );

        require(numberOfMints > 0, "Sender is trying to mint none");
        require(
            numberMinted(msg.sender) + numberOfMints <= ADDRESS_MAX_MINTS,
            "Sender is trying to mint more than allocated tokens"
        );
        require(
            numberOfWLMintsOnAddress[msg.sender] + numberOfMints <=
                ADDRESS_WL_MAX_MINTS,
            "Sender is trying to mint more than their whitelist amount"
        );
        require(
            totalSupply() + numberOfMints <= maxSupply,
            "Mint would exceed max supply of mints"
        );
        require(
            msg.value >= numberOfMints * WLprice,
            "Amount of ether is not enough"
        );

        numberOfWLMintsOnAddress[msg.sender] += numberOfMints;
        _safeMint(msg.sender, numberOfMints);
    }

    /**
     * Public mint
     */
    function mint(uint256 numberOfMints) external payable {
        require(saleActive, "Public sale must be active to mint");
        require(numberOfMints > 0, "Sender is trying to mint none");
        require(
            numberOfMints <= PUBLIC_MINT_PER_TX,
            "Sender is trying to mint too many in a single transaction"
        );
        require(
            numberMinted(msg.sender) + numberOfMints <= ADDRESS_MAX_MINTS,
            "Sender is trying to mint more than allocated tokens"
        );
        require(
            totalSupply() + numberOfMints <= maxSupply,
            "Mint would exceed max supply of mints"
        );
        require(
            msg.value >= numberOfMints * price,
            "Amount of ether is not enough"
        );

        _safeMint(msg.sender, numberOfMints);
    }

    /**
     * Reserve mint for founders
     */

    function reserveMint(uint256 quantity, address _recipient)
        external
        onlyOwner
    {
        require(quantity > 0, "Need to mint more than 0");

        _safeMint(_recipient, quantity);
    }

    function addAirdrop(address user, uint256 amount) external onlyOwner {
        airdropList[user] += amount;
        emit Airdrop(amount, user);
    }

    function airdropMint(uint256 quantity, address _recipient)
        external
        onlyOwner
    {
        require(quantity > 0, "Need to mint more than 0");

        _safeMint(_recipient, quantity);
    }

    //SETTERS FOR SALE PHASES
    function setOnlyGE() public onlyOwner {
        GEsaleActive = true;
        OGsaleActive = false;
        WLsaleActive = false;
        saleActive = false;
    }

    function setOnlyOG() public onlyOwner {
        OGsaleActive = true;
        GEsaleActive = false;
        WLsaleActive = false;
        saleActive = false;
    }

    function setOnlyWhitelisted() public onlyOwner {
        GEsaleActive = false;
        OGsaleActive = false;
        WLsaleActive = true;
        saleActive = false;
    }

    function setOnlyPublicSale() public onlyOwner {
        GEsaleActive = false;
        OGsaleActive = false;
        WLsaleActive = false;
        saleActive = true;
    }

    function toggleSaleOff() external onlyOwner {
        GEsaleActive = false;
        OGsaleActive = false;
        WLsaleActive = false;
        saleActive = false;
    }

    function toggleAllsaleOn() external onlyOwner {
        GEsaleActive = true;
        OGsaleActive = true;
        WLsaleActive = true;
        saleActive = true;
    }

    function setGEMerkleRoot(bytes32 newMerkleRoot) external onlyOwner {
        GEMerkleRoot = newMerkleRoot;
    }

    function setOGMerkleRoot(bytes32 newMerkleRoot) external onlyOwner {
        OGMerkleRoot = newMerkleRoot;
    }

    function setWLMerkleRoot(bytes32 newMerkleRoot) external onlyOwner {
        WLMerkleRoot = newMerkleRoot;
    }

    function _verifyWhitelist(address _user, bytes32[] calldata _merkleProof)
        internal
        view
        returns (bool)
    {
        bytes32 leaf = keccak256(abi.encodePacked(_user));
        return MerkleProof.verify(_merkleProof, WLMerkleRoot, leaf); //this seems to be duplicate
    }

    function _withdraw(address _address, uint256 _amount) private {
        (bool success, ) = _address.call{value: _amount}("");
        require(success, "Transfer failed.");
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    function numberMinted(address owner) public view returns (uint256) {
        return _numberMinted(owner);
    }

    function tokenIdOfOwner(address _owner)
        external
        view
        returns (uint256[] memory)
    {
        uint256 tokenCount = totalSupply();

        uint256[] memory tokensId = new uint256[](tokenCount);
        uint256 arrayIndex;
        for (uint256 i; i < tokenCount; i++) {
            TokenOwnership memory owner = _ownershipOf(i);
            if (owner.addr == _owner) {
                tokensId[arrayIndex] = i;
                arrayIndex++;
            }
        }
        return tokensId;
    }

    function getOwnershipData(uint256 tokenId)
        external
        view
        returns (TokenOwnership memory)
    {
        return _ownershipOf(tokenId);
    }

    /**
     * To change the starting tokenId, please override this function.
     */
    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }

    // withdraw all funds to owners address
    function emergencyWithdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    //change the supply limit
    function changeSupplyLimit(uint256 _new) external onlyOwner {
        maxSupply = _new;
    }

    //set public mint price
    function setGEprice(uint256 _new) external onlyOwner {
        GEprice = _new;
    }

    function setOGprice(uint256 _new) external onlyOwner {
        OGprice = _new;
    }

    function setWLprice(uint256 _new) external onlyOwner {
        WLprice = _new;
    }

    function setMintPrice(uint256 _new) external onlyOwner {
        price = _new;
    }

    function setMaxAddress(uint256 _new) external onlyOwner {
        ADDRESS_MAX_MINTS = _new;
    }

    function setGEMax(uint256 _new) external onlyOwner {
        ADDRESS_GE_MAX_MINTS = _new;
    }

    function setOGMax(uint256 _new) external onlyOwner {
        ADDRESS_OG_MAX_MINTS = _new;
    }

    function setWLMax(uint256 _new) external onlyOwner {
        ADDRESS_WL_MAX_MINTS = _new;
    }

    function setPublicMax(uint256 _new) external onlyOwner {
        PUBLIC_MINT_PER_TX = _new;
    }
}
