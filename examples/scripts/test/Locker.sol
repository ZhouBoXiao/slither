/**
 *Submitted for verification at Etherscan.io on 2019-10-18
*/

pragma solidity ^0.5.0;

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
library Set {
    struct Data { mapping(uint => bool) flags; }

    function insert(Data storage self, uint value)
        public
        returns (bool)
    {
        if (self.flags[value]){
            return false; // already there
        }
        self.flags[value] = true;
        return true;
    }

    function remove(Data storage self, uint value)
        public
        returns (bool)
    {
        if (!self.flags[value])
            return false; // not there
        self.flags[value] = false;
        return true;
    }

    function contains(Data storage self, uint value)
        public
        view
        returns (bool)
    {
        return self.flags[value];
    }
}

contract priced {
    // Modifiers can receive arguments:
    modifier costs(uint price) {
        if (msg.value >= price) {
            _;
        }
    }
}
contract Locker is priced{
    IERC20  APIX;
    address receiver;
    uint16 unlockStartYear;
    uint256 unlockStartTime;
    uint256 unlockOffsetTime = 7884000; /* (365*24*60*60)/4 */
    uint256 totalLockedBalance = 0;
    uint256 unlockBalancePerRound = 0;
    uint price;
    uint8 lastRound = 0;
    enum State { Created, Locked, Inactive } // Enum

    struct Voter { // Struct
        uint weight;
        bool voted;
        address delegate;
        uint vote;
    }
    using Set for Set.Data; // this is the crucial change
    /**
     * @dev Emitted when the locked 'value' tokens is set
     *
     * Note that `value` may be zero.
     */
    event Lock(uint256 value);
    mapping(bool => uint) public mapp;
    /**
     * @dev Emitted when the unlocked and moved 'value' tokens to (`receiver`)
     *
     * Note that `value` may be zero.
     */
    event Unlock(uint256 value, address receiver);


    constructor (address _APIX, address _receiver, uint256 _unlockStartTime, uint16 _unlockStartYear) public {
        APIX = IERC20(_APIX);
        receiver = _receiver;
        unlockStartTime = _unlockStartTime;
        unlockStartYear = _unlockStartYear;
    }


    function getLockedBalance() external view returns (uint256) {
        return APIX.balanceOf(address(this));
    }


    function getTotalLockedBalance() external view returns (uint256) {
        return totalLockedBalance;
    }

    function getNextRound() external view returns (uint8) {
        return lastRound + 1;
    }

    function _getNextRoundTime() internal view returns (uint256) {
        return unlockStartTime + unlockOffsetTime * (lastRound + 1);
    }
    function getNextRoundTime() external view returns (uint256) {
        return _getNextRoundTime();
    }

    function _getNextUnlockToken() internal view returns (uint256) {
        uint8 round = lastRound + 1;
        uint256 unlockAmount;

        if(round < 4) {
            unlockAmount = unlockBalancePerRound;
        }
        else {
            unlockAmount = APIX.balanceOf(address(this));
        }

        return unlockAmount;
    }
    function getNextUnlockToken() external view returns (uint256) {
        return _getNextUnlockToken();
    }


    function getLockInfo() external view returns (uint256 initLockedToken, uint256 balance, uint16 unlockYear, uint8 nextRound, uint256 nextRoundUnlockAt, uint256 nextRoundUnlockToken) {
        initLockedToken = totalLockedBalance;
        balance = APIX.balanceOf(address(this));
        nextRound = lastRound + 1;
        nextRoundUnlockAt = _getNextRoundTime();
        nextRoundUnlockToken = _getNextUnlockToken();
        unlockYear = unlockStartYear;
    }



    function initLockedBalance() public returns (uint256) {
        require(totalLockedBalance == 0, "Locker: There is no token stored");

        totalLockedBalance = APIX.balanceOf(address(this));
        unlockBalancePerRound = totalLockedBalance / 4;

        emit Lock (totalLockedBalance);

        return totalLockedBalance;
    }


    function unlock(uint8 round) public returns (bool) {

        require(totalLockedBalance > 0, "Locker: There is no locked token");



        require(round == lastRound + 1, "Locker: The round value is incorrect");


       // require(round <= 4, "Locker: The round value has exceeded the executable range");



        require(block.timestamp >= _getNextRoundTime(), "Locker: It's not time to unlock yet");



        uint256 amount = _getNextUnlockToken();
        require(amount > 0, 'Locker: There is no unlockable token');
        require(APIX.transfer(receiver, amount));

        emit Unlock(amount, receiver);


        lastRound = round;
        return true;
    }
}