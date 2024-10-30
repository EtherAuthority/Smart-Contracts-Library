// SPDX-License-Identifier: NLC@2021

pragma solidity =0.7.6;

contract Context {

    /**
     * @dev returns address executing the method
     */
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    /**
     * @dev returns data passed into the method
     */
    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

import "./SafeMath.sol";