// SPDX-License-Identifier: MIT
// EPSProxy Contracts v1.0.0 (epsproxy/eps-contracts/contracts/ERC721Proxied.sol)

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Proxiable.sol";

/**
 * Contract module which allows children to implement proxied delivery
 * on minting calls
 */
abstract contract ERC20Proxied is Context, ERC20, Proxiable {

  /**
  * @dev Returns the proxied address details (nominator address, delivery address) for a passed proxy address.  
  * Call this to view the details for any given proxy address. 
  */
  function _getAddresses(address _receivedAddress) internal virtual view returns (address _nominator, address _delivery, bool _isProxied){
    return (getAddresses(_receivedAddress));
  }

  /**
  * @dev Returns if a given address is a proxy or not:
  */
  function _proxyRecordExists(address _receivedAddress) internal virtual view returns (bool _isProxied){
    return (proxyRecordExists(_receivedAddress));
  }

  /**
  * @dev call safemint after determining the delivery address.
  */
  function _mintProxied(address _account, uint256 _amount) internal virtual {
    address nominator;
    address delivery;
    bool isProxied;
    (nominator, delivery, isProxied) = getAddresses(_account);
    _mint(delivery, _amount);
  }

  /**
  * @dev call safemint after determining the delivery address IF we have been passed a bool indicating
  * that a proxied address is in use. This fuction should be used in conjunction with an off-chain call
  * to _proxyRecordExists that determines if a proxy address is in use. This saves gas for anyone who is
  * NOT using a proxy as we do not needlessly check for proxy details.
  */
  function _MintProxiedSwitch(address _account, uint256 _amount, bool _isProxied) internal virtual {
    if (_isProxied) {
      _mintProxied(_account, _amount);
    }
    else {
      _mint(_account, _amount);
    }
  }
}