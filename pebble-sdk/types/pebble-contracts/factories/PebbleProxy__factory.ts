/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import { Signer, utils, Contract, ContractFactory, Overrides } from "ethers";
import type { Provider, TransactionRequest } from "@ethersproject/providers";
import type { PromiseOrValue } from "../common";
import type { PebbleProxy, PebbleProxyInterface } from "../PebbleProxy";

const _abi = [
  {
    inputs: [
      {
        internalType: "address",
        name: "_implementation",
        type: "address",
      },
    ],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "address",
        name: "previousAdmin",
        type: "address",
      },
      {
        indexed: false,
        internalType: "address",
        name: "newAdmin",
        type: "address",
      },
    ],
    name: "AdminChanged",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "beacon",
        type: "address",
      },
    ],
    name: "BeaconUpgraded",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "implementation",
        type: "address",
      },
    ],
    name: "Upgraded",
    type: "event",
  },
  {
    stateMutability: "payable",
    type: "fallback",
  },
  {
    inputs: [],
    name: "getImplementation",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    stateMutability: "payable",
    type: "receive",
  },
] as const;

const _bytecode =
  "0x604060808152346102235761042490813803918261001c81610228565b938492833960209384918101031261022357516001600160a01b03811692838203610223578251916001600160401b03908284018281118582101761020d57808652600096878652823b156101b3577f360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc80546001600160a01b031916821790557fbc7cd75a20ee27fd9adebab32041f755214dbc6bffa90cc0225b39da2e5c2d3b8880a28451158015906101ac575b6100de575b855161010290816103228239f35b8551946060860186811085821117610198578752602786527f416464726573733a206c6f772d6c6576656c2064656c65676174652063616c6c85870152660819985a5b195960ca1b86880152518791829190845af4913d15610187573d90811161017357610167959661015985601f19601f85011601610228565b91825281943d92013e61024d565b508038808080806100d0565b634e487b7160e01b87526041600452602487fd5b50915061016793945060609161024d565b634e487b7160e01b89526041600452602489fd5b50866100cb565b865162461bcd60e51b815260048101869052602d60248201527f455243313936373a206e657720696d706c656d656e746174696f6e206973206e60448201526c1bdd08184818dbdb9d1c9858dd609a1b6064820152608490fd5b634e487b7160e01b600052604160045260246000fd5b600080fd5b6040519190601f01601f191682016001600160401b0381118382101761020d57604052565b919290156102af5750815115610261575090565b3b1561026a5790565b60405162461bcd60e51b815260206004820152601d60248201527f416464726573733a2063616c6c20746f206e6f6e2d636f6e74726163740000006044820152606490fd5b8251909150156102c25750805190602001fd5b6040519062461bcd60e51b82528160208060048301528251908160248401526000935b828510610308575050604492506000838284010152601f80199101168101030190fd5b84810182015186860160440152938101938593506102e556fe608060405260043610156025575b3615601b575b60196080565b005b60216080565b6013565b6000803560e01c63aaf10f4214603a5750600d565b34607d5780600319360112607d577f360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc546001600160a01b03166080908152602090f35b80fd5b507f360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc54600090819081906001600160a01b0316368280378136915af43d82803e1560c8573d90f35b3d90fdfea2646970667358221220bc9af02f86d5c8dd7ca1c1576fac07ad80fa754a6b964c9b1a3c33ccb1432a3b64736f6c63430008110033";

type PebbleProxyConstructorParams =
  | [signer?: Signer]
  | ConstructorParameters<typeof ContractFactory>;

const isSuperArgs = (
  xs: PebbleProxyConstructorParams
): xs is ConstructorParameters<typeof ContractFactory> => xs.length > 1;

export class PebbleProxy__factory extends ContractFactory {
  constructor(...args: PebbleProxyConstructorParams) {
    if (isSuperArgs(args)) {
      super(...args);
    } else {
      super(_abi, _bytecode, args[0]);
    }
  }

  override deploy(
    _implementation: PromiseOrValue<string>,
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<PebbleProxy> {
    return super.deploy(
      _implementation,
      overrides || {}
    ) as Promise<PebbleProxy>;
  }
  override getDeployTransaction(
    _implementation: PromiseOrValue<string>,
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): TransactionRequest {
    return super.getDeployTransaction(_implementation, overrides || {});
  }
  override attach(address: string): PebbleProxy {
    return super.attach(address) as PebbleProxy;
  }
  override connect(signer: Signer): PebbleProxy__factory {
    return super.connect(signer) as PebbleProxy__factory;
  }

  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): PebbleProxyInterface {
    return new utils.Interface(_abi) as PebbleProxyInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): PebbleProxy {
    return new Contract(address, _abi, signerOrProvider) as PebbleProxy;
  }
}
