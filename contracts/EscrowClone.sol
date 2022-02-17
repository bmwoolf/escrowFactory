// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";


contract EscrowClone is ReentrancyGuard, Initializable {
    using SafeERC20 for IERC20;

    address payable public client;
    address payable public dev;
    address payable public freeflow;
    uint256 public freeflowCut;
    IERC20 public usdcContractAddress;
    IERC20 public usdtContractAddress;

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

    function initialize(address payable _client, address payable _dev, address payable _freeflow) 
    public initializer {
        client = _client;
        dev = _dev;
        freeflow = _freeflow;
        freeflowCut = 15;
        usdcContractAddress = IERC20(0x4DBCdF9B62e891a7cec5A2568C3F4FAF9E8Abe2b);
        //usdtContractAddress = IERC20(0xD9BA894E0097f8cC2BBc9D24D308b98e36dc6D02);
        usdtContractAddress = IERC20(0x13512979ADE267AB5100878E2e0f485B568328a4); // kovan usdt
    }

    //////////////////////////////////////////////////
    /////////      DEPOSIT & WITHDRAWALS    //////////
    //////////////////////////////////////////////////

    /// @dev Transfer ETH from the client to this smart contract
    function depositETH() public payable onlyClient {
        require(msg.value > 0, "Cannot deposit 0 ETH.");
        
        emit Deposit(msg.sender, msg.value);
    }

    /// @dev   Transfer USDT token from the client to this smart contract
    /// @param _amount The new amount to deposit
    function depositUSDT(uint256 _amount) public onlyClient {
        require(_amount > 0, "Cannot deposit 0 tokens.");

        SafeERC20.safeTransferFrom(usdtContractAddress, msg.sender, address(this), _amount);
        
        emit Deposit(msg.sender, _amount);
    }

    /// @dev   Transfer USDC token from the client to this smart contract
    /// @param _amount The new amount to deposit 
    function depositUSDC(uint256 _amount) public onlyClient {
        require(_amount > 0, "Cannot deposit 0 tokens.");

        SafeERC20.safeTransferFrom(usdcContractAddress, msg.sender, address(this), _amount);
        
        emit Deposit(msg.sender, _amount);
    }


    /// @dev   Transfer from this smart contract to the dev
    function withdrawETH(uint256 _amount) onlyFreeflowOrClient nonReentrant public {
        require(address(this).balance >= _amount, "Trying to withdraw more ETH than in the contract");
        uint256 freeflowShare = _amount / 100 * freeflowCut;
        uint256 devShare = _amount - freeflowShare;
        
        freeflow.transfer(freeflowShare);
        dev.transfer(devShare);


        emit DevWithdrawal(dev, devShare);
        emit FreeflowWithdrawal(freeflow, freeflowShare);
    }

    /// @dev   Transfer USDT token from this smart contract to the dev
    /// @param _amount The amount to withdraw for the client
    function withdrawUSDT(uint256 _amount) public onlyFreeflowOrClient nonReentrant {
        uint256 contractUsdtBalance = usdtContractAddress.balanceOf(address(this));
        require (contractUsdtBalance >= _amount, "Trying to withdraw more USDT than in the contract");
        uint256 freeflowShare = _amount / 100 * freeflowCut;
        uint256 devShare = _amount - freeflowShare;
        

        SafeERC20.safeApprove(usdtContractAddress, address(this), _amount); 
        SafeERC20.safeTransferFrom(usdtContractAddress, address(this), dev, devShare);
        SafeERC20.safeTransferFrom(usdtContractAddress, address(this), freeflow, freeflowShare);

        emit DevWithdrawal(dev, devShare);
        emit FreeflowWithdrawal(freeflow, freeflowShare);
    }

    /// @dev   Transfer USDC token from this smart contract to the dev
    /// @param _amount The amount to withdraw for the client
    function withdrawUSDC(uint256 _amount) public onlyFreeflowOrClient nonReentrant {
        uint256 contractUsdcBalance = usdcContractAddress.balanceOf(address(this));
        require (contractUsdcBalance >= _amount, "Trying to withdraw more USDC than in the contract");
        uint256 freeflowShare = _amount / 100 * freeflowCut;
        uint256 devShare = _amount - freeflowShare;
        

        SafeERC20.safeApprove(usdcContractAddress, address(this), _amount); 
        SafeERC20.safeTransferFrom(usdcContractAddress, address(this), dev, devShare);
        SafeERC20.safeTransferFrom(usdcContractAddress, address(this), freeflow, freeflowShare);

        emit DevWithdrawal(dev, devShare);
        emit FreeflowWithdrawal(freeflow, freeflowShare);
    }

    //////////////////////////////////////////////////
    /////////            REFUNDS            //////////
    //////////////////////////////////////////////////

    /// @dev   Refund only a specific amount to the client
    /// @param _amount The amount to refund
    function refundClientMilestoneETH(uint256 _amount) public onlyFreeflow nonReentrant {
        require(address(this).balance >= _amount, "Cannot refund more than the total amount.");
        client.transfer(_amount);

        emit Refund(client, _amount);
    }
    
    /// @dev   Refund a specific amount of USDT to the client
    /// @param _amount The amount to refund
    function refundClientMilestoneUSDT(uint256 _amount) public onlyFreeflow nonReentrant {
        uint256 contractUsdtBalance = usdtContractAddress.balanceOf(address(this));
        require (contractUsdtBalance >= _amount, "Trying to refund more USDT than in the contract");

        SafeERC20.safeApprove(usdtContractAddress, address(this), _amount); 
        SafeERC20.safeTransferFrom(usdtContractAddress, address(this), client, _amount);

        emit Refund(client, _amount);
    }
    
    /// @dev   Refund a specific amount of USDT to the client
    /// @param _amount The amount to refund
    function refundClientMilestoneUSDC(uint256 _amount) public onlyFreeflow nonReentrant {
        uint256 contractUsdcBalance = usdcContractAddress.balanceOf(address(this));
        require (contractUsdcBalance >= _amount, "Trying to refund more USDC than in the contract");

        SafeERC20.safeApprove(usdcContractAddress, address(this), _amount); 
        SafeERC20.safeTransferFrom(usdcContractAddress, address(this), client, _amount);

        emit Refund(client, _amount);
    }
}
