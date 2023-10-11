// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/**
 * An experiment in Soul Bound Tokens (SBT's) following Vitalik's
 * co-authored whitepaper at:
 * https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4105763
 *
 * I propose for a rename to Non-Transferable Tokens NTT's
 */

contract SBT {

    struct Soul {
        string identity;
        string url;
        uint256 score;
        uint256 timestamp;
    }

    mapping (address => Soul) private souls;
    mapping (address => mapping (address => Soul)) soulProfiles;
    mapping (address => address[]) private profiles;
    uint public maxSoulLimit = 500;
    uint public totalSoulCount;
    uint public expiryInSecond = 63072000; // two years default

    string public name;
    string public ticker;
    address public operator;
    bytes32 private zeroHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
    
    event Mint(address _soul);
    event Burn(address _soul);
    event Update(address _soul);
    event SetProfile(address _profiler, address _soul);
    event RemoveProfile(address _profiler, address _soul);

    constructor(string memory _name, string memory _ticker) {
      name = _name;
      ticker = _ticker;
      operator = msg.sender;
    }

    function changeMaxSoulLimit(uint _newLimit) public returns(bool){
        require(msg.sender == operator, "Only operator can change this limit");
        maxSoulLimit = _newLimit;
        return true;
    }

    function changeExpiryInSecond(uint _seconds) public returns(bool){
        require(msg.sender == operator, "Only operator can change this limit");
        expiryInSecond = _seconds;
        return true;
    }

    function mint(address _soul,string memory _identity,string memory _url,uint256 _score) external {
        require(totalSoulCount + 1 <= maxSoulLimit, "limit reached");
        require(keccak256(bytes(souls[_soul].identity)) == zeroHash, "Soul already exists");
        require(msg.sender == operator, "Only operator can mint new souls");
        Soul memory temp;
        temp.identity = _identity;
        temp.url = _url;
        temp.score = _score;
        temp.timestamp = block.timestamp;
        souls[_soul] = temp;
        totalSoulCount++;
        emit Mint(_soul);
    }

    function bulkMint(address[] memory _soul,string[] memory _identity,string[] memory _url,uint256[] memory _score) external {
        require(msg.sender == operator, "Only operator can mint new souls");
        require(totalSoulCount + _soul.length <= maxSoulLimit, "limit reached");
        require(_soul.length == _identity.length && _soul.length == _url.length && _soul.length == _score.length &&  _soul.length > 1, "invalid input");
        
        for(uint i=0;i<_soul.length;i++) {
            require(keccak256(bytes(souls[_soul[i]].identity)) == zeroHash, "Soul already exists");
            Soul memory temp;
            temp.identity = _identity[i];
            temp.url = _url[i];
            temp.score = _score[i];
            temp.timestamp = block.timestamp;
            souls[_soul[i]] = temp;
            totalSoulCount++;
            emit Mint(_soul[i]);
        }
    }


    function burn(address _soul) external {
        require(msg.sender == _soul || msg.sender == operator, "Only users and issuers have rights to delete their data");
        delete souls[_soul];
        for (uint i=0; i<profiles[_soul].length; i++) {
            address profiler = profiles[_soul][i];
            delete soulProfiles[profiler][_soul];
        }
        emit Burn(_soul);
    }

    function update(address _soul, Soul memory _soulData) external {
        require(msg.sender == operator, "Only operator can update soul data");
        require(keccak256(bytes(souls[_soul].identity)) != zeroHash, "Soul does not exist");
        souls[_soul] = _soulData;
        emit Update(_soul);
    }

    function hasSoul(address _soul) external view returns (bool) {
        if (keccak256(bytes(souls[_soul].identity)) == zeroHash && souls[_soul].timestamp + expiryInSecond > block.timestamp) {
            return false;
        } else {
            return true;
        }
    }

    function getSoul(address _soul) external view returns (Soul memory) {
        return souls[_soul];
    }

    /**
     * Profiles are used by 3rd parties and individual users to store data.
     * Data is stored in a nested mapping relative to msg.sender
     * By default they can only store data on addresses that have been minted
     */
    function setProfile(address _soul, Soul memory _soulData) external {
        require(keccak256(bytes(souls[_soul].identity)) != zeroHash, "Cannot create a profile for a soul that has not been minted");
        soulProfiles[msg.sender][_soul] = _soulData;
        profiles[_soul].push(msg.sender);
        emit SetProfile(msg.sender, _soul);
    }

    function getProfile(address _profiler, address _soul) external view returns (Soul memory) {
        return soulProfiles[_profiler][_soul];
    }

    function listProfiles(address _soul) external view returns (address[] memory) {
        return profiles[_soul];
    }

    function hasProfile(address _profiler, address _soul) external view returns (bool) {
        if (keccak256(bytes(soulProfiles[_profiler][_soul].identity)) == zeroHash) {
            return false;
        } else {
            return true;
        }
    }

    function removeProfile(address _profiler, address _soul) external {
        require(msg.sender == _soul, "Only users have rights to delete their profile data");
        delete soulProfiles[_profiler][msg.sender];
        emit RemoveProfile(_profiler, _soul);
    }
}
