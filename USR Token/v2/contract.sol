
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interface.sol";


contract USRToken is ERC20 {
    using SafeMath for uint256;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

    uint256 private constant _MAX_TAX_PERCENTAGE = 10000; // 100%
    uint256 public constant PURCHASE_TAX_PERCENTAGE = 250; // 2.5%
    uint256 public constant SALE_TAX_PERCENTAGE = 450; // 4.5%
    uint256 public constant TRANSFER_TAX_PERCENTAGE = 350; // 3.5%

    constructor(string memory name, string memory symbol, address _router) ERC20(name, symbol) {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_router);
         // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
    }

    function _calculateTax(uint256 amount, uint256 taxPercentage) internal pure returns (uint256) {
        return amount.mul(taxPercentage).div(_MAX_TAX_PERCENTAGE);
    }

    function _transferWithTax(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        uint256 purchaseTax = _calculateTax(amount, PURCHASE_TAX_PERCENTAGE);
        uint256 saleTax = _calculateTax(amount, SALE_TAX_PERCENTAGE);
        uint256 transferTax = _calculateTax(amount, TRANSFER_TAX_PERCENTAGE);

        if (sender == uniswapV2Pair) {
            // Transfer from contract, apply purchase tax
            _transfer(sender, recipient, amount.sub(purchaseTax));
            _burn(sender, purchaseTax);
        } else if (recipient == uniswapV2Pair) {
            // Transfer to contract, apply sale tax
            _transfer(sender, recipient, amount.sub(saleTax));
            _burn(recipient, saleTax);
        } else {
            // Normal transfer, apply transfer tax
            _transfer(sender, recipient, amount.sub(transferTax));
            _burn(sender, transferTax);
        }
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transferWithTax(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transferWithTax(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            allowance(sender, msg.sender).sub(amount, "ERC20: transfer amount exceeds allowance")
        );
        return true;
    }
}
