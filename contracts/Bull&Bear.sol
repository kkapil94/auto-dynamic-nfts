// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// Chainlink Imports
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
// This import includes functions from both ./KeeperBase.sol and
// ./interfaces/KeeperCompatibleInterface.sol
import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";

// Dev imports. This only works on a local dev network
// and will not work on any test or main livenets.
import "hardhat/console.sol";

contract BullBear is  ERC721Enumerable, ERC721URIStorage, Ownable, KeeperCompatible {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    uint256 public interval;
    uint256 public lastTimeStamp;
    int256 public currentPrice;
    AggregatorV3Interface public priceFeed;
    event TokensUpdated(string trend);
    // IPFS URIs for the dynamic nft graphics/metadata.
    // NOTE: These connect to my IPFS Companion node.
    // You should upload the contents of the /ipfs folder to your own node for development.
    string[] bullUrisIpfs = [
        "https://ipfs.io/ipfs/QmPS5QH9bJArAqDR1Er2iTDTwwEVbPWwhHepodbnHVLSPp?filename=gamer_bull.json.url",
        "https://ipfs.io/ipfs/QmRhmyvrKKKAEd8KZHrLVV2DQQNvgPx5BaZYvT7ZVeUhn1?filename=party_bull.json.url",
        "https://ipfs.io/ipfs/QmVvntPWLF1JK1JJv5QNcvmJxDH32n5hEpkLBXkt1KpVNu?filename=simple_bull.json.url"
    ];
    string[] bearUrisIpfs = [
        "https://ipfs.io/ipfs/QmQ3eKjKtEBjueBThSt1wPrxf2vakkka8iMqsBhafjmKKz?filename=beanie_bear.json.url",
        "https://ipfs.io/ipfs/Qme5bgAtGEdrV3nef1KuQA2qmJHebxckE9yVpXiqphZ2nj?filename=coolio_bear.json.url",
        "https://ipfs.io/ipfs/QmakMeC7q7WYamw7t487DsoG2x6mdRDYrN5gGz7YvicbVN?filename=simple_bear.json.url"
    ];

    constructor(uint updateInterval,address _priceFeed) ERC721("Bull&Bear", "BBTK") {
        interval = updateInterval;
        lastTimeStamp = block.timestamp;
        priceFeed = AggregatorV3Interface(_priceFeed);
        currentPrice = getLatestPrice();
    }

    function safeMint(address to) public {
        // Current counter value will be the minted token's token ID.
        uint256 tokenId = _tokenIdCounter.current();

        // Increment it so next time it's correct when we call .current()
        _tokenIdCounter.increment();

        // Mint the token
        _safeMint(to, tokenId);

        // Default to a bull NFT
        string memory defaultUri = bullUrisIpfs[0];
        _setTokenURI(tokenId, defaultUri);

        console.log(
            "DONE!!! minted token ",
            tokenId,
            " and assigned token url: ",
            defaultUri
        );
    }

    // The following functions are overrides required by Solidity.
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

     function checkUpkeep(bytes calldata) external view override returns (bool upkeepNeeded, bytes  memory) {
    upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;
     }

    function updateTokenUris(string memory trend) internal{
        if (compareString("brear",trend)) {
            for (uint i = 0; i < _tokenIdCounter.current(); i++) {
                _setTokenURI(i,bearUrisIpfs[0]);
            }
        }else{
            for (uint i = 0; i < _tokenIdCounter.current(); i++) {
                _setTokenURI(i,bullUrisIpfs[0]);
            }
        }
        emit TokensUpdated(trend);
    }

    //helpers
    function  compareString(string memory a,string memory b)internal pure returns(bool){
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    function setInterval(uint256 newInterval)public onlyOwner{
        interval = newInterval;
    }

    function setPriceFeed(address newFeed)public onlyOwner{
        priceFeed = AggregatorV3Interface(newFeed);
    }

     function performUpkeep(bytes calldata) external  override {
        if((block.timestamp - lastTimeStamp) > interval){
            lastTimeStamp = block.timestamp;
            int latestPrice = getLatestPrice();
            if (latestPrice == currentPrice) {
                return;
            }
            if (latestPrice < currentPrice) {
                updateTokenUris("bear");
            }else{
                updateTokenUris("bull");
            }
            currentPrice = latestPrice;
        }
     }

     function getLatestPrice() public view returns(int256){
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
       return price;
     }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721URIStorage, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
