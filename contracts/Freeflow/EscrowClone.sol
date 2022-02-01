// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import {SafeERC20} from './utils/SafeERC20.sol';
import {IERC20} from "./utils/IERC20.sol";
import "./utils/ReentrancyGuardUpgradeable.sol";

contract EscrowClone is ReentrancyGuard {
    using SafeERC20 for IERC20;

    address public immutable payer;
    address public immutable payee;
    address public immutable freeflow;
    uint256 public totalAmount;
    uint256 public freeflowCut = 15;
    IERC20 public tokenContractAddress;
    bool isETH = false;

    event Deposit(address payer, uint256 amount);
    event DevWithdrawal(address payee, uint256 amount);
    event FreeflowWithdrawal(address payee, uint256 amount);
    event Refund(address payer, uint256 amount);

    /// @notice we need to capture the type of token that they are trying to deposit
    constructor(address _payer, address _payee, address _freeflow, uint256 _initialAmount) payable {
        payer = _payer;
        payee = _payee;
        freeflow = _freeflow;
        totalAmount = _initialAmount;
    }

    modifier onlyPayer() {
        require(msg.sender == payer);
        _;
    }

    modifier onlyPayee() {
        require(msg.sender == payee);
        _;
    }

    modifier onlyFreeflow() {
        require(msg.sender == freeflow);
        _;
    }

    modifier onlyFreeflowOrPayer() {
        require(msg.sender == freeflow || msg.sender == payer, "Only the freeflow account or payer can withdraw the funds.");
        _;
    }

    //////////////////////////////////////////////////
    /////////      DEPOSIT & WITHDRAWALS    //////////
    //////////////////////////////////////////////////

    /// @dev Transfer ETH from the payer to this smart contract
    function depositETH() public payable onlyPayer {
        require(msg.value > 0, "Cannot deposit 0 ETH.");

        isETH = true;
        totalAmount += msg.value;
        /// TODO switch to transferFrom
        payable(address(this)).transfer(msg.value);

        emit Deposit(msg.sender, msg.value);
    }

    /// @dev   Transfer ERC20 token from the payer to this smart contract
    /// @param _amount The new amount to deposit
    /// @param _tokenAddress The address of the token to deposit
    function depositToken(uint256 _amount, IERC20 _tokenAddress) public payable onlyPayer {
        require(_amount > 0, "Cannot deposit 0 tokens.");
        /// @notice do we need to track balances locally like an ERC20 contract?
        SafeERC20.safeTransferFrom(_tokenAddress, msg.sender, address(this), _amount);
        tokenContractAddress = _tokenAddress;

        emit Deposit(msg.sender, _amount);
    }

    /// @dev   Transfer from this smart contract to the payee
    /// @param withdrawAmount The amount to withdraw for the client
    function withdrawETH(uint256 withdrawAmount) public onlyFreeflowOrPayer nonReentrant {
        uint256 freeflowShare = (withdrawAmount * 100) / freeflowCut;
        uint256 devShare = withdrawAmount - freeflowShare;
        
        payable(freeflow).transfer(freeflowShare);
        payable(payee).transfer(devShare);

        emit DevWithdrawal(payee, devShare);
        emit FreeflowWithdrawal(freeflow, freeflowShare);
    }

    /// @dev   Transfer ERC20 token from this smart contract to the dev
    /// @param _amount The amount to withdraw for the client
    function withdrawERC20(uint256 _amount) public onlyFreeflowOrPayer nonReentrant {
        uint256 freeflowShare = (_amount * 100) / freeflowCut;
        totalAmount -= freeflowShare;
        uint256 devShare = _amount - freeflowShare;
        totalAmount -= devShare;
    
        SafeERC20.safeTransferFrom(tokenContractAddress, address(this), payee, devShare);
        SafeERC20.safeTransferFrom(tokenContractAddress, address(this), freeflow, freeflowShare);

        emit DevWithdrawal(payee, devShare);
        emit FreeflowWithdrawal(freeflow, freeflowShare);
    }

    /// @dev Transfer from this smart contract to the payer
    function refundClientAll() public onlyFreeflow nonReentrant {
        uint256 tempTotalAmount = totalAmount;
        
        if (!isETH) {
            totalAmount = 0;
            SafeERC20.safeTransferFrom(tokenContractAddress, address(this), payer,  tempTotalAmount);
        } else {
            /// @notice require(address(this.balance) == totalAmount);
            payable(payer).transfer(tempTotalAmount);
        }

        emit Refund(payer, tempTotalAmount);
    }

    /// @dev   Refund only a specific amount to the payer
    /// @param _amount The amount to refund
    function refundClientMilestone(uint256 _amount) public onlyFreeflow nonReentrant {
        if (!isETH) {
            totalAmount -= _amount;
            SafeERC20.safeTransferFrom(tokenContractAddress, address(this), payer, _amount);
        } else if (isETH) {
            require(_amount <= address(this).balance, "Cannot refund more than the total amount.");
            payable(payer).transfer(_amount);
        }

        emit Refund(payer, _amount);
    }

    /// @dev   Allows Freeflow to change the percentage that they take of dev proceeds
    /// @param _freeflowCut The new percentage to take of dev proceeds
    function setFreeFlowCut(uint256 _freeflowCut) public onlyFreeflow {
        freeflowCut = _freeflowCut;
    }
}