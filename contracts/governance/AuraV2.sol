// SPDX-License-Identifier: MIT

// File: contracts/interfaces/IPair.sol
pragma solidity >=0.5.0;

interface ISoulSwapPair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);
    function token1() external view returns (address);
    
    function getReserves() external view returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);
    function price1CumulativeLast() external view returns (uint256);
    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);
    function burn(address to) external returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out, 
        uint256 amount1Out, 
        address to, 
        bytes calldata data
    ) external;

    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// File: contracts/interfaces/IEnchant.sol

pragma solidity ^0.8.7;

interface IEnchant {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
}

// File: contracts/interfaces/IERC20.sol

pragma solidity ^0.8.4;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // EIP 2612
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

// File: contracts/interfaces/ISummoner.sol

pragma solidity ^0.8.7;

interface ISummoner {
    function userInfo(uint pid, address owner) external view returns (uint, uint);
}

// File: @openzeppelin/contracts/utils/Context.sol

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol

pragma solidity ^0.8.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: contracts/governance/SoulAura.sol
pragma solidity ^0.8.7;

contract SoulAuraV2 is Ownable {

    ISummoner summoner = ISummoner(0xce6ccbB1EdAD497B4d53d829DF491aF70065AB5B);

    IEnchant enchant = IEnchant(0x6a1a8368D607c7a808F7BbA4F7aEd1D9EbDE147a);
    IERC20 soul = IERC20(0xe2fb177009FF39F52C0134E8007FA0e4BaAcBd07);
    IERC20 seance = IERC20(0x124B06C5ce47De7A6e9EFDA71a946717130079E6);

    // SOULSWAP PAIRS
    ISoulSwapPair soulFtm = ISoulSwapPair(0xa2527Af9DABf3E3B4979d7E0493b5e2C6e63dC57);
    ISoulSwapPair soulUsdc = ISoulSwapPair(0xC0A301f1E5E0Fe37a31657e8F60a41b14d01B0Ef);
    ISoulSwapPair soulUsdt = ISoulSwapPair(0xE27Cc06a7F34892BC17a5474303b91b2C9F3F21A);
    ISoulSwapPair seanceFtm = ISoulSwapPair(0x8542bEAC34282aFe5Bb6951Eb6DCE0B3783b7faB);
    ISoulSwapPair seanceUsdc = ISoulSwapPair(0x98C678d3C7ebeD4a36B84666700d8b5b5Ddc1f79);
    ISoulSwapPair enchantFtm = ISoulSwapPair(0xb4d6Ff768F409e4D102BAD80f9A8ac105453ccdD);
    ISoulSwapPair enchantUsdc = ISoulSwapPair(0x6c6f32008262666CA4acEd0a824c4945AB96e5F3);

    // SOULSWAP FARMS
    uint soulFtmPid = 1;
    uint soulUsdcPid = 22;
    uint soulUsdtPid = 28;
    uint seanceFtmPid = 10;
    uint seanceUsdcPid = 7;
    uint enchantFtmPid = 24;
    uint enchantUsdcPid = 29;

    function name() public pure returns (string memory) { return "SoulAura"; }
    function symbol() public pure returns (string memory) { return "AURA"; }
    function decimals() public pure returns (uint8) { return 18; }

    /* ====== STRUCTS ====== */
        
    struct Pairs {
        uint pid; // pool id in Summoner
        string pair; // pair name
        address lpAddress; // in ten-thousandths ( 5000 = 0.5% )
        uint reserveIndex; // token0 vs. token1
        uint rate; // power per reserve asset
    }

    Pairs[] public pairs;

    // gets the total voting power = twice the reserves in the LPs + enchanted seance + soul balance.
    function totalSupply() public view returns (uint) {

        // SOUL | SOUL-FTM + SOUL-USDC + SOUL-USDT
        (, uint totalSoulFtm, ) = soulFtm.getReserves();
        (, uint totalSoulUsdc, ) = soulUsdc.getReserves();
        (, uint totalSoulUsdt, ) = soulUsdt.getReserves();

        uint totalSoul = soul.totalSupply() + totalSoulFtm + totalSoulUsdc + totalSoulUsdt;
        
        // SEANCE | SEANCE-FTM + SEANCE-USDC + ENCHANTED SEANCE
        ( uint totalSeanceFtm, , ) = seanceFtm.getReserves();
        ( , uint totalSeanceUsdc, ) = seanceUsdc.getReserves();
        uint enchantedSeance = seance.balanceOf(address(enchant)); // enchanted

        uint totalSeance = enchantedSeance + totalSeanceFtm + totalSeanceUsdc;

        // ENCHANT | ENCHANT-FTM + ENCHANT-USDC
        ( , uint totalEnchantFtm, ) = enchantFtm.getReserves();
        ( , uint totalEnchantUsdc, ) = enchantUsdc.getReserves();
        
        uint totalEnchant = totalEnchantFtm + totalEnchantUsdc;
  
        return totalSoul + totalSeance + totalEnchant;
    }

    function balanceOf(address member) public view returns (uint) {
        ( uint memberLiquidity, ) = pooledPower(member);
        ( uint memberEnchanted, ) = enchantedPower(member);
        ( uint memberSoul, ) = soulPower(member);

        return memberLiquidity + memberEnchanted + memberSoul;
    }

    // gets: member's pooled power
    function pooledPower(address member) public view returns (uint raw, uint formatted) {
        ( uint soulPooled, ) = pooledSoul(member);
        ( uint seancePooled, ) = pooledSeance(member);
        ( uint enchantPooled, ) = pooledEnchant(member);

        uint power = soulPooled + seancePooled + enchantPooled;

        return (power, fromWei(power));

    }

    // gets: member's pooled SOUL power
    function pooledSoul(address member) public view returns (uint raw, uint formatted) {
        // total | LP tokens
        uint lp_total =  
              soulFtm.totalSupply() 
            + soulUsdc.totalSupply()
            + soulUsdt.totalSupply();

        // total | pooled SOUL
        uint lp_totalSoul =
              soul.balanceOf(address(soulFtm)) 
            + soul.balanceOf(address(soulUsdc))
            + soul.balanceOf(address(soulUsdt));

        // member | SOUL LP balance
        uint lp_walletBalance =
              soulFtm.balanceOf(member)
            + soulUsdc.balanceOf(member)
            + soulUsdt.balanceOf(member);

        // member | staked LP balance
        (uint staked_soulFtm, ) = summoner.userInfo(soulFtmPid, member);
        (uint staked_soulUsdc, ) = summoner.userInfo(soulUsdcPid, member);
        (uint staked_soulUsdt, ) = summoner.userInfo(soulUsdtPid, member);

        uint lp_stakedBalance = staked_soulFtm + staked_soulUsdc + staked_soulUsdt;

        // member | lp balance
        uint lp_balance = 
              lp_walletBalance 
            + lp_stakedBalance;

        // LP voting power is 2X the members' SOUL share in the LP pool.
        uint lp_power =
              lp_totalSoul 
            * lp_balance 
            / lp_total * 2;

        return (lp_power, fromWei(lp_power));

    }

    // gets: member's pooled power
    function pooledSeance(address member) public view returns (uint raw, uint formatted) {
        // total | LP tokens
        uint lp_total =  
              seanceFtm.totalSupply() 
            + seanceUsdc.totalSupply();

        // total | pooled SEANCE
        uint lp_totalSeance =
              seance.balanceOf(address(seanceFtm)) 
            + seance.balanceOf(address(seanceUsdc));

        // member | SEANCE LP balance
        uint lp_walletBalance =
              seanceFtm.balanceOf(member)
            + seanceUsdc.balanceOf(member);

        // member | staked LP balance
        (uint staked_seanceFtm, ) = summoner.userInfo(seanceFtmPid, member);
        (uint staked_seanceUsdc, ) = summoner.userInfo(seanceUsdcPid, member);

        uint lp_stakedBalance = staked_seanceFtm + staked_seanceUsdc;

        // member | lp balance
        uint lp_balance = 
              lp_walletBalance 
            + lp_stakedBalance;

        // LP voting power is 2X the members' SEANCE share in the LP pool.
        uint lp_power = 
              lp_totalSeance 
            * lp_balance 
            / lp_total * 2;

        return (lp_power, fromWei(lp_power));

    }

    // gets: member's pooled ENCHANT power
    function pooledEnchant(address member) public view returns (uint raw, uint formatted) {
        
        // total | LP tokens
        uint lp_total =  
              enchantFtm.totalSupply() 
            + enchantUsdc.totalSupply();

        // total | pooled ENCHANT
        uint lp_totalEnchant =
              enchant.balanceOf(address(enchantFtm)) 
            + enchant.balanceOf(address(enchantUsdc));

        // member | ENCHANT LP balance
        uint lp_walletBalance =
              enchantFtm.balanceOf(member)
            + enchantUsdc.balanceOf(member);

        // member | staked LP balance
        (uint staked_enchantFtm, ) = summoner.userInfo(enchantFtmPid, member);
        (uint staked_enchantUsdc, ) = summoner.userInfo(enchantUsdcPid, member);

        uint lp_stakedBalance = staked_enchantFtm + staked_enchantUsdc;
        // member | lp balance
        uint lp_balance = 
              lp_walletBalance 
            + lp_stakedBalance;

        // LP voting power is 2X the members' ENCHANT share in the LP pool.
        uint lp_power = lp_totalEnchant * lp_balance / lp_total * 2;

        return (lp_power, fromWei(lp_power));

    }

    // gets: member's enchanted power
    function enchantedPower(address member) public view returns (uint raw, uint formatted) {
        uint enchant_total = enchant.totalSupply();
        uint enchant_balance = enchant.balanceOf(member);
        uint enchant_totalSeance = seance.balanceOf(address(enchant));

        // enchanted voting power is the members' enchanted SEANCE share.
        uint enchanted_power = enchant_totalSeance * enchant_balance / enchant_total;

        return (enchanted_power, fromWei(enchanted_power));
    }

    // gets: member's SOUL power
    function soulPower(address member) public view returns (uint raw, uint formatted) {
        // soul power is the members' SOUL balance.
        uint soul_power = soul.balanceOf(member);
        return (soul_power, fromWei(soul_power));
    }

    /* ====== POLICY FUNCTIONS ====== */

    /**
        @notice adds LP to AURA
        @param _pid string
        @param _pair string
        @param _lpAddress address
        @param _rate uint
     */

    function addRecipient( 
        uint _pid, 
        string memory _pair, 
        address _lpAddress, 
        uint _reserveIndex, 
        uint _rate 
        ) external onlyOwner() {
        require( _lpAddress != address(0) );
        pairs.push( Pairs({
            pid: _pid,                      // pid
            pair: _pair,                    // pair name
            lpAddress: _lpAddress,          // lpAddress
            reserveIndex: _reserveIndex,    // token0 vs. token1
            rate: _rate
        }));
    }

    /**
        @notice removes LP (rate) from AURA
        @param _index uint
        @param _rate address
     */
    function updateRate( uint _index, uint _rate ) external onlyOwner() {
        require( _rate == pairs[ _index ].rate );
        pairs[ _index ].rate = 0;
    }

    // disables ERC20 functionality.
    function allowance(address, address) public pure returns (uint) { return 0; }
    function transfer(address, uint) public pure returns (bool) { return false; }
    function approve(address, uint) public pure returns (bool) { return false; }
    function transferFrom(address, address, uint) public pure returns (bool) { return false; }

    // conversion helper functions
    function toWei(uint intNum) public pure returns (uint bigInt) { return intNum * 10**18; }
    function fromWei(uint bigInt) public pure returns (uint intNum) { return bigInt / 10**18; }
}
