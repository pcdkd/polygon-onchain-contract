// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract PolygonOnchain is ERC721Enumerable, Ownable {
  using Strings for uint256;
  using Counters for Counters.Counter;

  Counters.Counter private _tokenIdCounter;

  string[] public coreValues = ["santi","gyara","chi","ekwe","ilo","jigida","kwenu","ndichie","nno","obodo dike","na-eso","ada","omume","ajebutter","kolo","oba","ore-ofe","soji","yab"];
  string[] public seedValues = ["yakka","arvo","pluggers","esky","stoked","iffy","galah","crikey","cab sav","buckleys","accadacca","togs","cobber","slab","ute","devo","heaps","rellies","snag"];
  string[] public baseValues = ["frontier","homestead","metropolis","byzantium","constantinople","serenity","samsara","nirvana","anatta","ochre","horizons","rupa","vedana","sanna","sankhara","vinnana"];

  struct Word {
    string name;
    string description;
    string PolyNumber;
    string MumNumber;
    string DadNumber;
    string value;
  }

  mapping (uint256 => Word) public words;

  constructor() ERC721("Polygon Onchain", "PLYGN") {
      _tokenIdCounter.increment();
  }

  uint256 private constant OWNER_MINT_LIMIT = 10;
  uint256 private ownerMintedCount;

  function mint(uint256 numTokens) public payable {
    uint256 supply = totalSupply();
    require(supply + numTokens <= 5000, "Exceeds maximum supply");

    if (msg.sender != owner()) {
        uint256 requiredValue = 0.005 ether * numTokens;
        require(msg.value >= requiredValue, "Ether value sent is not correct");
        if (msg.value > requiredValue) {
            uint256 excessValue = msg.value - requiredValue;
            payable(msg.sender).transfer(excessValue);
        }
    }

    uint256 mintedCount = 0;
    while (mintedCount < numTokens && ownerMintedCount < OWNER_MINT_LIMIT) {
        _tokenIdCounter.increment();
        uint256 _tokenId = _tokenIdCounter.current();

        Word memory newWord = Word(
            string(abi.encodePacked('Polygon Onchain ', uint256(_tokenId).toString())),
            "Polygon Onchain is a generative polygon color collection, unique with each mint, completely onchain.",
            randomNum(21000000, block.timestamp, supply, 0, _tokenId + 100).toString(),
            randomNum(90, 10011955, block.timestamp, 0, _tokenId + 100).toString(),
            randomNum(90, 12081951, block.timestamp, 0, _tokenId + 100).toString(),
            string(
                abi.encodePacked(
                    coreValues[randomNum(coreValues.length, block.timestamp, supply, 0, _tokenId + 100)],
                    '-',
                    seedValues[randomNum(seedValues.length, block.timestamp, supply, 0, _tokenId + 100)],
                    '-',
                    baseValues[randomNum(baseValues.length, block.timestamp, supply, 0, _tokenId + 100)]
                )
            )
        );

        words[supply + 1 + mintedCount] = newWord;
        _safeMint(msg.sender, supply + 1 + mintedCount);
        mintedCount++;
    }

    ownerMintedCount += mintedCount;
}

  function randomNum(uint256 _mod, uint256 _seed, uint256 _salt, uint256 _minMod, uint256 _tokenId) public view returns(uint256){
    require(_mod >= _minMod, "Mod value too small");
    uint256 num = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, _seed, _salt, _tokenId))) % _mod;
    return num;
}

  function buildImage(uint256 _tokenId) public view returns(string memory) {
    string[10] memory polygonClasses;
    for (uint i = 0; i < polygonClasses.length; i++) {
        // Generate a random number between 0 and 99
        uint256 randNum = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, i, _tokenId))) % 100;
        // Map the random number to a polygon class letter
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

    // Generate random opacities for each style class
    string[5] memory styleOpacities;
    for (uint i = 0; i < styleOpacities.length; i++) {
        uint256 randOpacity = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, i + 100, _tokenId))) % 100;
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

    Word memory currentWord = words[_tokenId];

    return string(abi.encodePacked(
      'data:application/json;base64,', Base64.encode(bytes(abi.encodePacked(
        '{"name":"',
        currentWord.name,
        '", "description":"',
        currentWord.description,
        '", "attributes": [{"trait_type": "PolygonNumber", "value": "',
        currentWord.PolyNumber,
        '"}, {"trait_type": "MumNumber", "value": "',
        currentWord.MumNumber,
        '"}, {"trait_type": "DadNumber", "value": "',
        currentWord.DadNumber,
        '"}, {"trait_type": "PolygonID", "value": "',
        currentWord.value,
        '"}], "image": "',
        'data:image/svg+xml;base64,',
        buildImage(_tokenId),
        '"}')))));
  }
 
  function withdraw() public onlyOwner {
    payable(owner()).transfer(address(this).balance);
  }

}