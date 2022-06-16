pragma solidity ^0.8.4;

interface ClassicRewardsInterface {
    function getApproved(uint256 tokenId) external view returns (address);

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function ownerOf(uint256 tokenId) external view returns (address);

    function totalSupply() external view returns (uint256);
}

contract classicRewardsSwap {
    address classicRewardsaddress = 0x0cC7f43A7FBBa594b57C9676ccc2ade02eb62D29;
    ClassicRewardsInterface classicContract =
        ClassicRewardsInterface(classicRewardsaddress);

    function swap(uint256 swapTokenLevel) public {
        uint256[] memory ownerTokenArray = tokenIdOfOwner(msg.sender);
        require(ownerTokenArray.length > 0, "You don't have any tokens now");
        for (uint256 i = 0; i < 500; i++) {
            if (
                classicContract.getApproved((swapTokenLevel - 1) * 500 + i) ==
                address(this)
            ) {
                address swapUserAddress = classicContract.ownerOf(i);
                classicContract.transferFrom(
                    msg.sender,
                    swapUserAddress,
                    ownerTokenArray[0]
                );
                classicContract.transferFrom(
                    swapUserAddress,
                    msg.sender,
                    (swapTokenLevel - 1) * 500 + i
                );
            }
        }
    }

    function tokenIdOfOwner(address _owner)
        private
        view
        returns (uint256[] memory)
    {
        uint256 tokenCount = classicContract.totalSupply();

        uint256[] memory tokensId = new uint256[](tokenCount);
        uint256 arrayIndex;
        for (uint256 i; i < tokenCount; i++) {
            if (classicContract.ownerOf(i) == _owner) {
                tokensId[arrayIndex] = i;
                arrayIndex++;
            }
        }
        return tokensId;
    }
}
