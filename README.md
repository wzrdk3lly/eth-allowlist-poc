### Overview

This repository is a foundry POC for the ETH allowlist implementation, originally created by the yearn team. See [ yearn's README.md](/src/contracts/eth-allowlist/README.md) for details on the allow list. At a high level the eth-allowlist implementation helps mitigate DNS spoofing and man in the middle attacks by validating calldata that a protocol owner has allowListed.

### Objective

The objective is to create an allowlist POC for an fake protocol. In this scenario the fake protocol will be called InvestX. It is a simple dapp, that accepts Fake usd (FUSD) and deposits these tokens into a pool. We will be creating an allowList implementation that prevents malicous calls from beng made to the InvestX dapp. One key thing to note is that, direct smart contract calls are not prevented. This functionality is to be applied to API calls and wallet integration calls.

### Navigating this Repo

- src/contracts/eth-allowlist
  - This is a slightly altered version of the original [eth-allowlist](https://github.com/yearn/eth-allowlist/tree/03f2a9ad5716abd0dbfc6d45885f5d6a04061edc) by the yearn team. All of the contents in the foler allow support for the eth-allowlist.
- src/contracts/InvestX
  - This contains the code for fusd tokens and for the fake protocol that accepts fusd tokens.
  - InvestXImplementation is the cutom implementation contract for the eth allowlist
- test/allowList.t.sol
  - This is the file that holds the allow list test. It performs key operations such as registering a protocol, adding an implementation contract, adding conditions, and validating conditions.
- test/invstX.t.sol
  - This is where all the investx specific test are
- test/investXimplem.t.sol
  - This is where the investX implementation contract test are

### Alterations

The scope of this POC is limited to the eth allowList and the fake protocol. This POC does NOT include the ENS oracle and registry contracts. There were slight alterations made to the allowlist registry to prevent having to configure and deploy an ENS oracle and ENS registry. The assumption was made that the ENS registry and ENS oracle should work as intended.

The changes to support the scope of this POC include:

- Setting a hardcoded protocolOwnerAddress rather than making the call to the ENS Oracle contracts.
- Implementing a timelock ability for reregistering protocols. This will help mitigate protocol takeovers and attackers who attempt to create a new allowList implementation.

### Installation

When you have foundry installed, clone this repo and run `forge build`.

run this commnand `forge test --match-path path/to/test/file`. EX: forge test `forge test --match-path test/allowList.t.sol`

Create developer documentation that includes good descriptions and pictures on how to correctly configure an allow list for their Dapp.

### AllowList Developer Docs

In the past 3 years alone, $150M+ has been extracted due to DNS hijacking and malicious content injection. A solution created by the Yearn team, and supported by the MetaMask team involves creating an onchain calldata AllowList that prevents malicious actors from damaging crypto users in the event of a DNS hijack. In this write-up we have detailed step by step instructions on how this allowList can be implemented.

### AllowList Overview

DNSSEC also known as DNS Security Extensions was designed to protect clients from attack vectors such as cache poisoning, DNS spoofing, etc. When you enable DNSSEC, there is a cryptographic signature generated for your DNS record. When the DNS record is queried, the resolver validates the signature with the DNS, hence preventing MITM attacks and spoofing.

ENS offers the ability to register your DNSSEC on chain to an ENS Oracle. With this onchain representation of a DNS domain, we can generate an AllowList of calldata that this dapp is willing to allow. In the event that a protocol’s DNS has been hijacked, malicious smart contract calls to the protocol’s domain can be flagged or blocked by \*Metamask.

The yearn finance team has prototyped an allow list implementation to ensure that their smart contracts are not vulnerable to MITM attacks. We are going to look at how this implementation works in detail and walk through the steps needed to implement your own allowList.

At a high level we need 4 key things for this implementation:

1. A domain’s DNSSEC signatures
2. Specific calldata that a protocol is designed to send
3. An allowList registry that stores this calldata
4. A \*Metamask integration that checks the allow list registry of the protocol the call originated from.

\*Disclaimer, this feature is not yet incorporated into MetaMask. It’s a potential solution that can be implemented in the future.

When we have these 4 components we can create an allowList for our smart contracts.

Lets take a scenario where a website is spoofed and it redirects a user to a scam website with malicious smart contracts. The user interacts with a malicious smart contract which will likely drain their wallet. The user believes they are interacting with a trusted website, but it has been spoofed/hijacked.

With the proposed allowList implementation, MetaMask can block or deny transactions made to domains that have a registered allowList. MetaMask will be able to cross reference the origin’s domain name with the allow list registry and verify whether the calldata is allowed or not.

To implement this control within your smart contracts, there are a few pre-requisites you need before following this guide:

_You need to use or switch to a hosting provider that allows you to enable DNSSEC for your protocol Domain_

Once you have this prerequisites, you are ready to implement your own allow list.

### Step 1: Register your DNSSEC hash with the DNS Registrar

Follow the [DNS Registrar guide](https://docs.ens.domains/dns-registrar-guide) in order to understand how to:

1. Enable DNSSEC
2. Register your ENS Domain
3. Register the DNSSEC hash to the DNSSEC Oracle smart contract

### Step 2: Register your protocol to the AllowList registry

First you need to register your protocol using the address that has control of your ENS Domain. You can do this by calling [registerProtocol() function](https://github.com/yearn/eth-allowlist/blob/fcb2c52439a3311cc7b95985387ccd29d734ede7/contracts/Registry.sol#L47C1-L73) on the [allow list registry contract](https://etherscan.io/address/0xb39c4EF6c7602f1888E3f3347f63F26c158c0336).

An allowlist will be initialized for your protocol

It’s important to understand that you MUST make this call using the private keys that control your ens domain.

See below for a snippet of the registerProtocol function

```solidity
/**
   * @notice Begin protocol registration
   * @param originName is the domain name for a protocol (ie. "yearn.finance")
   * @dev Only valid protocol owners can begin registration
   * @dev Beginning registration generates a smart contract each protocol can use
   *      to manage their conditions and validation implementation logic
   * @dev Only fully registered protocols appear on the registration list
   */
  function registerProtocol(string memory originName) public {
    // Make sure caller is protocol owner
    address protocolOwnerAddress = protocolOwnerAddressByOriginName(originName);
    require(
      protocolOwnerAddress == msg.sender,
      "Only protocol owners can register protocols"
    );

    // Make sure protocol is not already registered
    bool protocolIsAlreadyRegistered = allowlistAddressByOriginName[
      originName
    ] != address(0);
    require(
      protocolIsAlreadyRegistered == false,
      "Protocol is already registered"
    );

    // Clone, register and initialize allowlist
    address allowlistAddress = IAllowlistFactory(factoryAddress).cloneAllowlist(
      originName,
      protocolOwnerAddress
    );
    allowlistAddressByOriginName[originName] = allowlistAddress;

    // Register protocol
    registeredProtocols.push(originName);
  }
```

### Step 3: Deploy Custom Implementation Contracts to validate targets and parameters against

Now that you have began the registration for your protocol, you will need to create custom integration contracts depending on the logic of your protocol’s smart contracts.

See Yearn’s [custom implementation contracts](https://github.com/yearn/yearn-allowlist/tree/main/contracts/implementations) for reference.

### Step 4: Link the allowlist with your custom implementation contract

To link your allowlist with your custom implementation contracts, you will need to call the `setImplementation(string,address)` function.

```solidity
function setImplementation(
    string memory implementationId,
    address implementationAddress
  ) public onlyOwner {
    // Add implementation ID to the implementationsIds list if it doesn't exist
    bool implementationExists = implementationById[implementationId] !=
      address(0);
    if (!implementationExists) {
      implementationsIds.push(implementationId);
    }

    // Set implementation
    implementationById[implementationId] = implementationAddress;

    // Validate implementation against existing conditions
    validateConditions();
  }
```

### Step 5: Add protocol specific conditions to the allow list

Discover what transactions are possible from your website and add their corresponding conditions to the allow list by calling the `addConditions()` function

```solidity
/**
   * @notice Add multiple conditions with validation
   * @param _conditions The conditions to add
   */
  function addConditions(Condition[] memory _conditions) public onlyOwner {
    for (
      uint256 conditionIdx;
      conditionIdx < _conditions.length;
      conditionIdx++
    ) {
      Condition memory condition = _conditions[conditionIdx];
      addCondition(condition);
    }
  }
```

### Conclusion

After following all the above steps you will now have additional features that can help aid in protecting your users from MITM attacks and DNS spoofing attacks. The intention of the Metamask team is to implement the calldata validation for Dapps who have an allowList implemented.

### Supporting Resources

1. [Understanding the benefits of DNSSEC](https://easydns.com/dns/dnssec/)
2. [Eth allow list created by the yearn team](https://github.com/yearn/eth-allowlist)
3. [Yearn-sdk allow list implementation](https://github.com/yearn/yearn-sdk/blob/546e58381b4c86648eeeabcf929285c5c7110282/src/services/allowlist.ts)
4. [Array manipulation help](https://ethereum.stackexchange.com/questions/130480/why-am-i-getting-index-out-of-bounds-here)

### Important things to Note

- The MM team is working on proposing this solution. New AllowList contracts may be deployed in order to support extended functionalities.
- All of the steps mentioned above can be seen in the [test](./test/) files.
