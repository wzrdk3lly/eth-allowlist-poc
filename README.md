### Overview

This repository is a WIP of an POC for the ETH allowlist implementation, originally created by the yearn team.

### Objective

The objective is to create an allowlist POC for an protocol. In this scenario the fake protocol will be called InvestX. It is a simple dapp, that accepts Fake usd (FUSD) and deposits these tokens into a pool.

The Allowlist will need to verify the following rules:

- InvestX only allows approvals for the token FUSD with the spender being the investXpool ONLY
- InvestX only allows deposits into the FUSD-Pool address

### Alterations

The scope of this POC is limited to the eth allowList and the fake protocol. This POC does NOT include the ENS oracle and registry contracts. There were slight alterations made to the allowlist registry to prevent having to configure and deploy an ENS oracle and ENS registry. The assumption was made that the ENS registry and ENS oracle should work as intended.

The changes to support the scope of this POC include:

- setting a hardcoded protocolOwnerAddress rather than making the call to ENS contracts.

### Installation

When you have foundry installed, clone this repo and run `forge build`.

### Tips:

- The paramaters are to be the parameters of the method you select. in an approve function you have the params(spender, amount). The spender param should corelate to your deployed implementation contract. In our case we want to validate that the spender is the investX smart contract adddress.
