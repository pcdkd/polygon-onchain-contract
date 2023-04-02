// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 +-+ +-+ +-+ +-+ +-+ +-+ +-+ +-+
 |P| |O| |L| |Y| |G| |O| |N| |S|
 +-+ +-+ +-+ +-+ +-+ +-+ +-+ +-+
 |O| |N| |C| |H| |A| |I| |N|    
 +-+ +-+ +-+ +-+ +-+ +-+ +-+    
 */

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract PolygonOnchain is ERC721Enumerable, Ownable {
  using Strings for uint256;
  using Counters for Counters.Counter;

  Counters.Counter private _tokenIdCounter;

  string[] public coreValues = ["santi","gyara","chi","ekwe","ilo","jigida","kwenu","ndichie","nno","obodo dike","na-eso","ada","omume","ajebutter","kolo","oba","ore-ofe","soji","yab","yakka","arvo","pluggers","esky","stoked","iffy","galah","crikey","cab sav","buckleys","accadacca","togs","cobber","slab","ute","devo","heaps","rellies","snag"];
  string[] public baseValues = ["frontier","homestead","metropolis","byzantium","constantinople","serenity","samsara","nirvana","anatta","ochre","horizons","rupa","vedana","sanna","sankhara","vinnana"];

  struct Trait {
    string name;
    string description;
    string MumGenesis;
    string DadGenesis;
    string value;
  }

  mapping (uint256 => Trait) public traits;

  constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {
      _tokenIdCounter.increment();
  }

  uint256 private constant OWNER_MINT_LIMIT = 10;
  uint256 private ownerMintedCount;

  function mint(uint256 numTokens) public payable {
    uint256 supply = totalSupply();
    require(supply + numTokens < 5001, "Exceeds maximum supply");

    if (msg.sender != owner() && msg.value > 0) {
        uint256 requiredValue = 4999999999999 wei * numTokens; // using uint256 value instead of decimal value
        require(msg.value >= requiredValue, "Ether value sent is not correct");

        if (msg.value > requiredValue) {
            uint256 excessValue = msg.value - requiredValue;
            payable(msg.sender).transfer(excessValue);
        }
    }

    uint256 mintedCount = 0;
    while (mintedCount < numTokens && ownerMintedCount < OWNER_MINT_LIMIT) {
        uint256 _tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();

        Trait memory newTrait = Trait(
            string(abi.encodePacked('Polygon Onchain ', uint256(_tokenId).toString())),
            "Polygons is a generative, onchain art project on Ethereum.",
            randomNum(90, 10011955, block.timestamp, _tokenId + 100).toString(),
            randomNum(90, 12081951, block.timestamp, _tokenId + 100).toString(),
            string(
                abi.encodePacked(
                    coreValues[randomNum(coreValues.length, block.timestamp, supply, _tokenId + 100)],
                    '-',
                    baseValues[randomNum(baseValues.length, block.timestamp, supply, _tokenId + 100)]
                )
            )
        );

        traits[supply + 1 + mintedCount] = newTrait;
        _safeMint(msg.sender, supply + 1 + mintedCount);
        mintedCount++;
    }

    ownerMintedCount += mintedCount;
}

  function buildImage(uint256 _tokenId) public view returns(string memory) {
    string[10] memory polygonClasses;
    for (uint i = 0; i < polygonClasses.length; i++) {
        uint256 randNum = randomNum(100, block.timestamp, i, _tokenId);
        if (randNum < 20) {
            polygonClasses[i] = 'a';
        } else if (randNum < 40) {
            polygonClasses[i] = 'b';
        } else if (randNum < 60) {
            polygonClasses[i] = 'c';
        } else if (randNum < 80) {
            polygonClasses[i] = 'd';
        } else {
            polygonClasses[i] = 'e';
        }
    }

    string[5] memory styleOpacities;
    for (uint i = 0; i < styleOpacities.length; i++) {
        uint256 randOpacity = randomNum(100, block.timestamp, i + 100, _tokenId);
        styleOpacities[i] = Strings.toString(randOpacity);
    }

    return Base64.encode(bytes(abi.encodePacked(
        '<svg viewBox="0 0 6 6" xmlns="http://www.w3.org/2000/svg">',
        '<polygon class="', polygonClasses[0], '" points="0 2 6 2 0 4"></polygon>',
        '<polygon class="', polygonClasses[1], '" points="6 2 3 6 0 2"></polygon>',
        '<polygon class="', polygonClasses[2], '" points="0 2 0 2 3 6"></polygon>',
        '<polygon class="', polygonClasses[3], '" points="0 2 0 4 3 6"></polygon>',
        '<polygon class="', polygonClasses[4], '" points="6 2 0 4 3 6"></polygon>',
        '<polygon class="', polygonClasses[5], '" points="3 0 6 4 3 6"></polygon>',
        '<polygon class="', polygonClasses[6], '" points="6 2 6 4 3 0"></polygon>',
        '<style>.a { fill: rgb(181, 241, 75); fill-opacity: ', styleOpacities[0], '%; }',
        '.b { fill: rgb(255, 237, 35); fill-opacity: ', styleOpacities[1], '%; }',
        '.c { fill: rgb(68, 118, 207); fill-opacity: ', styleOpacities[2], '%; }',
        '.d { fill: rgb(150, 64, 217); fill-opacity: ', styleOpacities[3], '%; }',
        '.e { fill: rgb(17, 17, 17); fill-opacity: ', styleOpacities[4], '%; }',
        '</style></svg>'
     )));
    }

  function randomNum(uint256 _mod, uint256 _seed, uint256 _salt, uint256 _tokenId) public view returns(uint256){
    require(_mod > 0, "Mod value must be greater than 0");
    uint256 num = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, _seed, _salt, _tokenId))) % _mod;
    return num;
  }

  function tokenURI(uint256 _tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(_tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );

    Trait memory currentTrait = traits[_tokenId];

    return string(abi.encodePacked(
      'data:application/json;base64,', Base64.encode(bytes(abi.encodePacked(
        '{"name":"',
        currentTrait.name,
        '", "description":"',
        currentTrait.description,
        '", "attributes": [{"trait_type": "MumGenesis", "value": "',
        currentTrait.MumGenesis,
        '"}, {"trait_type": "DadGenesis", "value": "',
        currentTrait.DadGenesis,
        '"}, {"trait_type": "PolygonsWord", "value": "',
        currentTrait.value,
        '"}], "image": "',
        'data:image/svg+xml;base64,',
        buildImage(_tokenId),
        '"}')))));
  }
 
  function withdraw() public onlyOwner {
    payable(owner()).transfer(address(this).balance);
  }

}