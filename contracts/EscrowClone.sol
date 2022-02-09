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
    bool public isETH;
    uint256 public totalAmount;
    uint256 public freeflowCut;
    IERC20 public tokenContractAddress;
    address public usdcContractAddress;
    address public usdtContractAddress;

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
    function initialize(address payable _client, address payable _dev, address payable _freeflow, bool _isETH) 
    public initializer {
        client = _client;
        dev = _dev;
        freeflow = _freeflow;
        isETH = _isETH;
        freeflowCut = 15;
        usdcContractAddress = 0x4DBCdF9B62e891a7cec5A2568C3F4FAF9E8Abe2b;
        usdtContractAddress = 0xD9BA894E0097f8cC2BBc9D24D308b98e36dc6D02;
    }

    //////////////////////////////////////////////////
    /////////      DEPOSIT & WITHDRAWALS    //////////
    //////////////////////////////////////////////////

    /// @dev Transfer ETH from the client to this smart contract
    function depositETH() public payable onlyClient {
        require(msg.value > 0, "Cannot deposit 0 ETH.");
        
        totalAmount += msg.value;

        emit Deposit(msg.sender, msg.value);
    }

    /// @dev   Transfer ERC20 token from the client to this smart contract
    /// @param _amount The new amount to deposit
    /// @param _tokenAddress The address of the token to deposit
    function depositERC20(uint256 _amount, address _tokenAddress) public onlyClient {
        require(_amount > 0, "Cannot deposit 0 tokens.");
        require(_tokenAddress == usdcContractAddress || _tokenAddress == usdtContractAddress, "Must be USDC or USDT");

        SafeERC20.safeTransferFrom(IERC20(_tokenAddress), msg.sender, address(this), _amount);
        
        tokenContractAddress = IERC20(_tokenAddress);

        totalAmount += _amount;

        emit Deposit(msg.sender, _amount);
    }

    /// @dev   Transfer from this smart contract to the dev
    function withdrawETH(uint256 _amount) onlyFreeflowOrClient nonReentrant public {
        require(address(this).balance >= _amount, "Trying to withdraw more ETH than in the contract");
        uint256 freeflowShare = _amount / 100 * freeflowCut;
        uint256 devShare = _amount - freeflowShare;
        
        freeflow.transfer(freeflowShare);
        dev.transfer(devShare);

        totalAmount -= (freeflowShare + devShare);

        emit DevWithdrawal(dev, devShare);
        emit FreeflowWithdrawal(freeflow, freeflowShare);
    }

    /// @dev   Transfer ERC20 token from this smart contract to the dev
    /// @param _amount The amount to withdraw for the client
    function withdrawERC20(uint256 _amount) public onlyFreeflowOrClient nonReentrant {
        uint256 contractERC20Balance = tokenContractAddress.balanceOf(address(this));
        require (contractERC20Balance >= _amount, "Trying to withdraw more ERC20s than in the contract");
        uint256 freeflowShare = _amount / 100 * freeflowCut;
        uint256 devShare = _amount - freeflowShare;
        
        totalAmount -= (devShare + freeflowShare);

        SafeERC20.safeApprove(tokenContractAddress, address(this), _amount); 
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
        totalAmount = 0;
        if (!isETH) {
            SafeERC20.safeApprove(tokenContractAddress, address(this), tempTotalAmount); 
            SafeERC20.safeTransferFrom(tokenContractAddress, address(this), client,  tempTotalAmount);
        } else {
            client.transfer(tempTotalAmount);
        }

        emit Refund(client, tempTotalAmount);
    }

    /// @dev   Refund only a specific amount to the client
    /// @param _amount The amount to refund
    function refundClientMilestone(uint256 _amount) public onlyFreeflow nonReentrant {
        totalAmount -= _amount;
        if (!isETH) {
            SafeERC20.safeApprove(tokenContractAddress, address(this), _amount); 
            SafeERC20.safeTransferFrom(tokenContractAddress, address(this), client, _amount);
        } else if (isETH) {
            require(address(this).balance >= _amount, "Cannot refund more than the total amount.");
            client.transfer(_amount);
        }

        emit Refund(client, _amount);
    }
}