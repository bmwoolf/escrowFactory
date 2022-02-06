// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";


contract EscrowClone is ReentrancyGuard, Initializable {
    using SafeERC20 for IERC20;

    address public client;
    address payable public dev;
    address payable public freeflow;
    bool public isETH;
    uint256 public totalAmount;
    uint256 public freeflowCut = 15;
    IERC20 public tokenContractAddress;

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
    function initialize(address _client, address payable _dev, address payable _freeflow, bool _isETH) public payable initializer {
        client = _client;
        dev = _dev;
        freeflow = _freeflow;
        isETH = _isETH;
        freeflowCut = 15;
    }

    //////////////////////////////////////////////////
    /////////      DEPOSIT & WITHDRAWALS    //////////
    //////////////////////////////////////////////////

    /// @dev Transfer ETH from the client to this smart contract
    function depositETH() public payable onlyClient {
        require(msg.value > 0, "Cannot deposit 0 ETH.");

        isETH = true;
        totalAmount += msg.value;

        emit Deposit(msg.sender, msg.value);
    }

    /// @dev   Transfer ERC20 token from the client to this smart contract
    /// @param _amount The new amount to deposit
    /// @param _tokenAddress The address of the token to deposit
    function depositToken(uint256 _amount, IERC20 _tokenAddress) public onlyClient {
        require(_amount > 0, "Cannot deposit 0 tokens.");
        
        /// @notice do we need to track balances locally like an ERC20 contract?
        SafeERC20.safeTransferFrom(IERC20(_tokenAddress), msg.sender, address(this), _amount);
        tokenContractAddress = _tokenAddress;

        totalAmount += _amount;

        emit Deposit(msg.sender, _amount);
    }

    /// @dev   Transfer from this smart contract to the dev
    // function withdrawETH(uint256 withdrawAmount) public onlyFreeflowOrClient nonReentrant {
    function withdrawETH() onlyFreeflowOrClient nonReentrant public payable {
        require(address(this).balance >= msg.value, "Trying to withdraw more ETH than in the contract");
        uint256 freeflowShare = msg.value / 100 * freeflowCut;
        uint256 devShare = msg.value - freeflowShare;
        
        freeflow.transfer(freeflowShare);
        dev.transfer(devShare);

        emit DevWithdrawal(dev, devShare);
        emit FreeflowWithdrawal(freeflow, freeflowShare);
    }

    /// @dev   Transfer ERC20 token from this smart contract to the dev
    /// @param _amount The amount to withdraw for the client
    function withdrawERC20(uint256 _amount) public onlyFreeflowOrClient nonReentrant {
        uint256 contractERC20Balance = IERC20(tokenContractAddress).balanceOf(address(this));
        require (contractERC20Balance >= _amount, "Trying to withdraw more ERC20s than in the contract");
        uint256 freeflowShare = _amount / 100 * freeflowCut;
        totalAmount -= freeflowShare;
        uint256 devShare = _amount - freeflowShare;
        totalAmount -= devShare;

        SafeERC20.safeApprove(IERC20(tokenContractAddress), address(this), _amount); 
        SafeERC20.safeTransferFrom(IERC20(tokenContractAddress), address(this), dev, devShare);
        SafeERC20.safeTransferFrom(IERC20(tokenContractAddress), address(this), freeflow, freeflowShare);

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
            SafeERC20.safeApprove(IERC20(tokenContractAddress), address(this), tempTotalAmount); 
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
            SafeERC20.safeApprove(IERC20(tokenContractAddress), address(this), _amount); 
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