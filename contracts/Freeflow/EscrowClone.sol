// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import {SafeERC20} from './utils/SafeERC20.sol';
import {IERC20} from "./utils/IERC20.sol";
import "./utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract EscrowClone is ReentrancyGuard, Initializable {
    using SafeERC20 for IERC20;

    address public client;
    address public dev;
    address public freeflow;
    uint256 public totalAmount;
    uint256 public freeflowCut = 15;
    IERC20 public tokenContractAddress;
    bool isETH = false;

    event Deposit(address client, uint256 amount);
    event DevWithdrawal(address dev, uint256 amount);
    event FreeflowWithdrawal(address dev, uint256 amount);
    event Refund(address client, uint256 amount);

    modifier onlyClient() {
        require(msg.sender == client);
        _;
    }

    modifier onlyDev() {
        require(msg.sender == dev);
        _;
    }

    modifier onlyFreeflow() {
        require(msg.sender == freeflow);
        _;
    }

    modifier onlyFreeflowOrClient() {
        require(msg.sender == freeflow || msg.sender == client, "Only the freeflow account or client can withdraw the funds.");
        _;
    }

    /// @notice Need to make it so this can only ever be called once
    function initialize(address payable _freeflow, address payable _dev, address _client) public payable initializer {
        freeflow = _freeflow;
        dev = _dev;
        client = _client;
    }

    //////////////////////////////////////////////////
    /////////      DEPOSIT & WITHDRAWALS    //////////
    //////////////////////////////////////////////////

    /// @dev Transfer ETH from the client to this smart contract
    function depositETH() public payable onlyClient {
        require(msg.value > 0, "Cannot deposit 0 ETH.");

        isETH = true;
        totalAmount += msg.value;
        /// TODO switch to transferFrom
        payable(address(this)).transfer(msg.value);

        emit Deposit(msg.sender, msg.value);
    }

    /// @dev   Transfer ERC20 token from the client to this smart contract
    /// @param _amount The new amount to deposit
    /// @param _tokenAddress The address of the token to deposit
    function depositToken(uint256 _amount, IERC20 _tokenAddress) public payable onlyClient {
        require(_amount > 0, "Cannot deposit 0 tokens.");
        
        /// @notice do we need to track balances locally like an ERC20 contract?
        SafeERC20.safeTransferFrom(_tokenAddress, msg.sender, address(this), _amount);
        tokenContractAddress = _tokenAddress;

        emit Deposit(msg.sender, _amount);
    }

    /// @dev   Transfer from this smart contract to the dev
    /// @param withdrawAmount The amount to withdraw for the client
    function withdrawETH(uint256 withdrawAmount) public onlyFreeflowOrClient nonReentrant {
        uint256 freeflowShare = (withdrawAmount * 100) / freeflowCut;
        uint256 devShare = withdrawAmount - freeflowShare;
        
        payable(freeflow).transfer(freeflowShare);
        payable(dev).transfer(devShare);

        emit DevWithdrawal(dev, devShare);
        emit FreeflowWithdrawal(freeflow, freeflowShare);
    }

    /// @dev   Transfer ERC20 token from this smart contract to the dev
    /// @param _amount The amount to withdraw for the client
    function withdrawERC20(uint256 _amount) public onlyFreeflowOrClient nonReentrant {
        uint256 freeflowShare = (_amount * 100) / freeflowCut;
        totalAmount -= freeflowShare;
        uint256 devShare = _amount - freeflowShare;
        totalAmount -= devShare;
    
        SafeERC20.safeTransferFrom(tokenContractAddress, address(this), dev, devShare);
        SafeERC20.safeTransferFrom(tokenContractAddress, address(this), freeflow, freeflowShare);

        emit DevWithdrawal(dev, devShare);
        emit FreeflowWithdrawal(freeflow, freeflowShare);
    }


    //////////////////////////////////////////////////
    /////////            REFUNDS            //////////
    //////////////////////////////////////////////////

    /// @dev Transfer from this smart contract to the client
    function refundClientAll() public onlyFreeflow nonReentrant {
        uint256 tempTotalAmount = totalAmount;
        
        if (!isETH) {
            totalAmount = 0;
            SafeERC20.safeTransferFrom(tokenContractAddress, address(this), client,  tempTotalAmount);
        } else {
            /// @notice require(address(this.balance) == totalAmount);
            payable(client).transfer(tempTotalAmount);
        }

        emit Refund(client, tempTotalAmount);
    }

    /// @dev   Refund only a specific amount to the client
    /// @param _amount The amount to refund
    function refundClientMilestone(uint256 _amount) public onlyFreeflow nonReentrant {
        if (!isETH) {
            totalAmount -= _amount;
            SafeERC20.safeTransferFrom(tokenContractAddress, address(this), client, _amount);
        } else if (isETH) {
            require(_amount <= address(this).balance, "Cannot refund more than the total amount.");
            payable(client).transfer(_amount);
        }

        emit Refund(client, _amount);
    }

    /// @dev   Allows Freeflow to change the percentage that they take of dev proceeds
    /// @param _freeflowCut The new percentage to take of dev proceeds
    function setFreeFlowCut(uint256 _freeflowCut) public onlyFreeflow {
        freeflowCut = _freeflowCut;
    }
}