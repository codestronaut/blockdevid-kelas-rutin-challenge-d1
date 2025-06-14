// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title CampusCredit
 * @dev ERC-20 token for transaction on campus
 */
contract CampusCredit is ERC20, ERC20Burnable, Pausable, AccessControl {
    // Role Definitions
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // [Feature]: Credits
    mapping(address => uint256) public dailySpendingLimit;
    mapping(address => uint256) public lastSpendingReset;
    mapping(address => uint256) public spentToday;

    // [Feature]: Merchants
    mapping(address => bool) public isMerchant;
    mapping(address => string) public merchantName;

    constructor(uint256 _initialSupply) ERC20("Campus Credit", "CCR") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);

        // Initial treasury minting (n CCR).
        _mint(msg.sender, _initialSupply * 10**decimals());
    }

    /**
     * @dev Pause all token transfers
     * Use case: Emergency / maintenance
     */
    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    /**
     * @dev Mint new tokens.
     * Use case: Top-up student balance.
     */
    function mint(address _to, uint256 _amount) public onlyRole(MINTER_ROLE) {
        uint256 amount = _amount * 10**decimals();

        // @dev Minting limits (if the student daily spending limit has been set).
        // Students will receive a number of CCR according to their remaining daily limit.
        if (dailySpendingLimit[_to] > 0) {
            require(
                spentToday[_to] + amount <= dailySpendingLimit[_to],
                "Exceeds daily spending limit, can't receive extra CCR."
            );
        }

        dailySpendingLimit[_to] += amount;
        _mint(_to, amount);
    }

    /**
     * @dev Register merchant.
     * Use case: Kafetaria, Bookstore, Laundry.
     */
    function registerMerchant(address _merchant, string memory _name)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(!isMerchant[_merchant], "Merchant already registered.");
        isMerchant[_merchant] = true;
        merchantName[_merchant] = _name;
    }

    /**
     * @dev Set daily spending limit for student.
     * Use case: Parental control / self-control.
     */
    function setDailyLimit(address _student, uint256 _limit)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        uint256 limit = _limit * 10**decimals();

        require(limit > 0, "Limit should be greater than 0.");
        dailySpendingLimit[_student] = limit;
    }

    /**
     * @dev Transfer with spending limit check.
     */
    function transferWithLimit(address _to, uint256 _amount) public {
        require(_amount > 0, "Amount should be greater than 0.");
        uint256 amount = _amount * 10**decimals();

        // Ensure the transfer amount not exceed the daily spending limit.
        require(
            spentToday[msg.sender] + amount <= dailySpendingLimit[msg.sender],
            "Exceeds daily spending limit."
        );

        // Reset today's spending if today is new day.
        if (block.timestamp > lastSpendingReset[msg.sender] + 1 days) {
            lastSpendingReset[msg.sender] = block.timestamp;
            spentToday[msg.sender] = 0;
        }

        // Update today's spending.
        spentToday[msg.sender] += amount;

        // Transfer to desired address.
        bool success = transfer(_to, amount);
        require(success, "Transfer failed.");
    }

    function _update(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20) {
        require(!paused(), "Token transfers paused.");
        super._update(from, to, amount);
    }

    /**
     * @dev Cashback mechanism to encourage usage.
     */
    uint256 public cashbackPercentage = 2; // Cashback is set to 2%.

    function transferWithCashback(address _merchant, uint256 _amount) public {
        require(_amount > 0, "Amount should be greater than 0.");
        
        // Cashback calculation.
        uint256 cashback = (_amount * cashbackPercentage) / 100;

        // Transfer to desired address.
        transferWithLimit(_merchant, _amount - cashback);

        // Get the cashback.
        _mint(msg.sender, cashback * 10**decimals());
    }
}
