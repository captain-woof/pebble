/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import {
  Signer,
  utils,
  Contract,
  ContractFactory,
  BigNumberish,
  Overrides,
} from "ethers";
import type { Provider, TransactionRequest } from "@ethersproject/providers";
import type { PromiseOrValue } from "../common";
import type {
  PebbleDelegatee,
  PebbleDelegateeInterface,
} from "../PebbleDelegatee";

const _abi = [
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_delegateFeesBasis",
        type: "uint256",
      },
    ],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  {
    stateMutability: "payable",
    type: "fallback",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_groupId",
        type: "uint256",
      },
      {
        internalType: "address",
        name: "_groupParticipant",
        type: "address",
      },
      {
        internalType: "address[]",
        name: "_penultimateKeysFor",
        type: "address[]",
      },
      {
        internalType: "uint256[]",
        name: "_penultimateKeysXUpdated",
        type: "uint256[]",
      },
      {
        internalType: "uint256[]",
        name: "_penultimateKeysYUpdated",
        type: "uint256[]",
      },
      {
        internalType: "uint256",
        name: "_timestampForWhichUpdatedKeysAreMeant",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "_groupParticipantDelegatorNonce",
        type: "uint256",
      },
      {
        internalType: "bytes",
        name: "_signatureFromGroupParticipant",
        type: "bytes",
      },
    ],
    name: "acceptGroupInviteForDelegator",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_groupId",
        type: "uint256",
      },
      {
        internalType: "address",
        name: "_groupParticipant",
        type: "address",
      },
      {
        internalType: "address[]",
        name: "_penultimateKeysFor",
        type: "address[]",
      },
      {
        internalType: "uint256[]",
        name: "_penultimateKeysXUpdated",
        type: "uint256[]",
      },
      {
        internalType: "uint256[]",
        name: "_penultimateKeysYUpdated",
        type: "uint256[]",
      },
      {
        internalType: "uint256",
        name: "_timestampForWhichUpdatedKeysAreMeant",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "_groupParticipantDelegatorNonce",
        type: "uint256",
      },
      {
        internalType: "uint8",
        name: "_signatureFromGroupParticipant_v",
        type: "uint8",
      },
      {
        internalType: "bytes32",
        name: "_signatureFromGroupParticipant_r",
        type: "bytes32",
      },
      {
        internalType: "bytes32",
        name: "_signatureFromGroupParticipant_s",
        type: "bytes32",
      },
    ],
    name: "acceptGroupInviteForDelegator",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "addFunds",
    outputs: [],
    stateMutability: "payable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    name: "addressToFundsMapping",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_groupCreator",
        type: "address",
      },
      {
        internalType: "address[]",
        name: "_groupParticipantsOtherThanCreator",
        type: "address[]",
      },
      {
        internalType: "uint256",
        name: "_initialPenultimateSharedKeyForCreatorX",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "_initialPenultimateSharedKeyForCreatorY",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "_initialPenultimateSharedKeyFromCreatorX",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "_initialPenultimateSharedKeyFromCreatorY",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "_groupCreatorDelegatorNonce",
        type: "uint256",
      },
      {
        internalType: "bytes",
        name: "_signatureFromDelegator",
        type: "bytes",
      },
    ],
    name: "createGroupForDelegator",
    outputs: [
      {
        internalType: "uint256",
        name: "groupId",
        type: "uint256",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_groupCreator",
        type: "address",
      },
      {
        internalType: "address[]",
        name: "_groupParticipantsOtherThanCreator",
        type: "address[]",
      },
      {
        internalType: "uint256",
        name: "_initialPenultimateSharedKeyForCreatorX",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "_initialPenultimateSharedKeyForCreatorY",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "_initialPenultimateSharedKeyFromCreatorX",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "_initialPenultimateSharedKeyFromCreatorY",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "_groupCreatorDelegatorNonce",
        type: "uint256",
      },
      {
        internalType: "uint8",
        name: "_signatureFromDelegator_v",
        type: "uint8",
      },
      {
        internalType: "bytes32",
        name: "_signatureFromDelegator_r",
        type: "bytes32",
      },
      {
        internalType: "bytes32",
        name: "_signatureFromDelegator_s",
        type: "bytes32",
      },
    ],
    name: "createGroupForDelegator",
    outputs: [
      {
        internalType: "uint256",
        name: "groupId",
        type: "uint256",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "delegateFeesBasis",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "pebbleProxy",
    outputs: [
      {
        internalType: "contract Pebble",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_groupId",
        type: "uint256",
      },
      {
        internalType: "address",
        name: "_sender",
        type: "address",
      },
      {
        internalType: "bytes",
        name: "_encryptedMessage",
        type: "bytes",
      },
      {
        internalType: "uint256",
        name: "_senderDelegatorNonce",
        type: "uint256",
      },
      {
        internalType: "uint8",
        name: "_signatureFromSender_v",
        type: "uint8",
      },
      {
        internalType: "bytes32",
        name: "_signatureFromSender_r",
        type: "bytes32",
      },
      {
        internalType: "bytes32",
        name: "_signatureFromSender_s",
        type: "bytes32",
      },
    ],
    name: "sendMessageInGroupForDelegator",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_groupId",
        type: "uint256",
      },
      {
        internalType: "address",
        name: "_sender",
        type: "address",
      },
      {
        internalType: "bytes",
        name: "_encryptedMessage",
        type: "bytes",
      },
      {
        internalType: "uint256",
        name: "_senderDelegatorNonce",
        type: "uint256",
      },
      {
        internalType: "bytes",
        name: "_signatureFromSender",
        type: "bytes",
      },
    ],
    name: "sendMessageInGroupForDelegator",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint16",
        name: "_delegateFeesBasisNew",
        type: "uint16",
      },
    ],
    name: "setDelegateFeesBasis",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_value",
        type: "uint256",
      },
    ],
    name: "withdrawFunds",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "withdrawFunds",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    stateMutability: "payable",
    type: "receive",
  },
] as const;

const _bytecode =
  "0x60803461006357601f610e5e38819003918201601f19168301916001600160401b03831184841017610068578084926020946040528339810103126100635751600080546001600160a01b03191633179055600255604051610ddf908161007f8239f35b600080fd5b634e487b7160e01b600052604160045260246000fdfe608060408181526004908136101561002d575b505050361561002557610023610bfd565b005b610023610bfd565b600092833560e01c9081630d5399d514610a1e57508063155dd5ee1461097b57806324600fc3146108dd57806325ccdaf7146107a85780632958cdf6146106ab5780632ba511341461068c5780635ed1945c14610664578063670c7ded146104c057806378f3689b14610383578063a26759cb1461036c578063bae5043514610279578063c097d03d146102415763ec18284d03610012573461022057826003196101403682011261023d576100e1610b16565b9267ffffffffffffffff604435818111610239576101029036908801610b80565b93906064358381116102355761011b9036908a01610b80565b9093608435908111610231576101349036908b01610b80565b92909961013f610b70565b5a9b60018060a01b0396878c541696873b1561022d578c998e978b978d519e8f9c8d9b8c9a63ec18284d60e01b8c528035908c01521660248a015260448901610140905261014489019061019292610c31565b90848883030160648901526101a692610c9b565b918583030160848601526101b992610c9b565b9060a43560a484015260c43560c484015260ff1660e483015261010480359083015261012480359083015203925af1908115610224575061020c575b5050610209913a905a900302903390610d62565b80f35b61021590610bb1565b6102205782386101f5565b8280fd5b513d84823e3d90fd5b8c80fd5b8780fd5b8680fd5b8480fd5b5080fd5b83823461023d57602036600319011261023d5760209181906001600160a01b03610269610b2c565b1681526001845220549051908152f35b503461022057826003199260a08436011261023d57610296610b16565b926044359467ffffffffffffffff95868111610239576102b99036908501610b42565b939096608435908111610368576102d39036908301610b42565b9790975a9860018060a01b03938489541693843b156103645789968b948894610329610340948c519d8e9b8c9a8b9963bae5043560e01b8b528035908b015216602489015260a0604489015260a4880191610c7a565b926064356064870152858403016084860152610c7a565b03925af1908115610224575061020c575050610209913a905a900302903390610d62565b8980fd5b8580fd5b838060031936011261038057610209610bfd565b80fd5b5082903461023d576101409283600319360112610220576103a2610b2c565b9360243567ffffffffffffffff8111610239576103c460209136908501610b80565b6103cf949194610b70565b9487895a9760ff61040e60018060a01b039586865416978d519b8c9a8b998a986378f3689b60e01b8a5216908801526024870152610144860191610c31565b9160443560448501526064356064850152608435608485015260a43560a485015260c43560c48501521660e483015261010480359083015261012480359083015203925af19384156104b5579361047c575b50602093610476913a905a900302903390610d62565b51908152f35b9092506020813d82116104ad575b8161049760209383610bdb565b810103126104a85751916020610460565b600080fd5b3d915061048a565b8351903d90823e3d90fd5b509034610220576020806003193601126106605781359261ffff84168094036102395784548151632b393ee960e21b81526001600160a01b039091169083818681855afa908115610629578791610633575b5082519063248a9ca360e01b8252858201528381602481855afa9081156106295790849188916105fa575b506044845180948193632474521560e21b8352898301523360248301525afa9081156105f05786916105ba575b50156105795750505060025580f35b5162461bcd60e51b815291820152601e60248201527f504542424c452044454c4547415445453a204e4f5420414e2041444d494e0000604482015260649150fd5b90508281813d83116105e9575b6105d18183610bdb565b8101031261036857518015158103610368573861056a565b503d6105c7565b82513d88823e3d90fd5b82819392503d8311610622575b6106118183610bdb565b810103126104a8578390513861053d565b503d610607565b83513d89823e3d90fd5b90508381813d8311610659575b61064a8183610bdb565b810103126104a8575138610512565b503d610640565b8380fd5b83823461023d578160031936011261023d57905490516001600160a01b039091168152602090f35b83823461023d578160031936011261023d576020906002549051908152f35b5082903461023d576003196101003682018113610660576106ca610b2c565b9467ffffffffffffffff92602435848111610235576106ec9036908401610b80565b91909460e4359081116102315791878961078289946107116020989736908901610b42565b9061074b5a9c60018060a01b0398898954169a519d8e9c8d9b8c9a6314ac66fb60e11b8c5216908a01526024890152610104880191610c31565b9260443560448701526064356064870152608435608487015260a43560a487015260c43560c48701528584030160e4860152610c7a565b03925af19384156104b5579361047c5750602093610476913a905a900302903390610d62565b50346102205761010036600319011261022057826107c4610b16565b9167ffffffffffffffff90604435828111610660576107e69036908701610b80565b92606435818111610368576107fe9036908901610b80565b608493919335838111610231576108189036908b01610b80565b92909360e4359081116108d9576108329036908c01610b42565b9a905a9b60018060a01b0396878c541696873b1561022d578c998e978b978d519e8f9c8d9b8c9a6325ccdaf760e01b8c528035908c01521660248a015260448901610100905261010489019061088792610c31565b9060031988830301606489015261089d92610c9b565b906003198683030160848701526108b392610c9b565b9060a43560a485015260c43560c48501526003198483030160e485015261034092610c7a565b8880fd5b50346102205782600319360112610220573383526001602052808320549182156109285750828080610209948180953382526001602052812055335af1610922610cbf565b50610cff565b6020608492519162461bcd60e51b8352820152602860248201527f504542424c452044454c4547415445453a204445504f5349544f5220484153206044820152674e4f2046554e445360c01b6064820152fd5b50346102205760203660031901126102205781359182156109c25750828080610209948194338352600160205282206109b5828254610d55565b9055335af1610922610cbf565b6020608492519162461bcd60e51b8352820152603160248201527f504542424c452044454c4547415445453a2056414c5545204d5553542042452060448201527047524541544552205448414e205a45524f60781b6064820152fd5b84929150346102205760e036600319011261022057610a3b610b16565b9160443567ffffffffffffffff811161023957610a5b9036908701610b42565b95906084359060ff8216809203610235575a9760018060a01b038089541694853b15610364578794610ab78b9795879589958795630d5399d560e01b87528035908701528d16602486015260e0604486015260e4850191610c7a565b906064356064840152608483015260a43560a483015260c43560c483015203925af1908115610b0d5750610afa575b5061020991923a905a900302903390610d62565b91610b0761020993610bb1565b91610ae6565b513d85823e3d90fd5b602435906001600160a01b03821682036104a857565b600435906001600160a01b03821682036104a857565b9181601f840112156104a85782359167ffffffffffffffff83116104a857602083818601950101116104a857565b60e4359060ff821682036104a857565b9181601f840112156104a85782359167ffffffffffffffff83116104a8576020808501948460051b0101116104a857565b67ffffffffffffffff8111610bc557604052565b634e487b7160e01b600052604160045260246000fd5b90601f8019910116810190811067ffffffffffffffff821117610bc557604052565b3360005260016020526040600020805490348201809211610c1b5755565b634e487b7160e01b600052601160045260246000fd5b9190808252602080920192916000805b838210610c5057505050505090565b9091929394853560018060a01b038116809103610220578152830194830193929160010190610c41565b908060209392818452848401376000828201840152601f01601f1916010190565b81835290916001600160fb1b0383116104a85760209260051b809284830137010190565b3d15610cfa573d9067ffffffffffffffff8211610bc55760405191610cee601f8201601f191660200184610bdb565b82523d6000602084013e565b606090565b15610d0657565b60405162461bcd60e51b815260206004820152602160248201527f504542424c452044454c4547415445453a205749544844524157204641494c456044820152601160fa1b6064820152608490fd5b91908203918211610c1b57565b9091612710600254820204019160018060a01b0380921660005260016020526040600020610d91848254610d55565b9055166000526001602052604060002090815401905556fea26469706673582212209315a0f4eceea12d0f78e4bdc6fc372df0e3555efa2bf6755d77356b7690cf9164736f6c63430008110033";

type PebbleDelegateeConstructorParams =
  | [signer?: Signer]
  | ConstructorParameters<typeof ContractFactory>;

const isSuperArgs = (
  xs: PebbleDelegateeConstructorParams
): xs is ConstructorParameters<typeof ContractFactory> => xs.length > 1;

export class PebbleDelegatee__factory extends ContractFactory {
  constructor(...args: PebbleDelegateeConstructorParams) {
    if (isSuperArgs(args)) {
      super(...args);
    } else {
      super(_abi, _bytecode, args[0]);
    }
  }

  override deploy(
    _delegateFeesBasis: PromiseOrValue<BigNumberish>,
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<PebbleDelegatee> {
    return super.deploy(
      _delegateFeesBasis,
      overrides || {}
    ) as Promise<PebbleDelegatee>;
  }
  override getDeployTransaction(
    _delegateFeesBasis: PromiseOrValue<BigNumberish>,
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): TransactionRequest {
    return super.getDeployTransaction(_delegateFeesBasis, overrides || {});
  }
  override attach(address: string): PebbleDelegatee {
    return super.attach(address) as PebbleDelegatee;
  }
  override connect(signer: Signer): PebbleDelegatee__factory {
    return super.connect(signer) as PebbleDelegatee__factory;
  }

  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): PebbleDelegateeInterface {
    return new utils.Interface(_abi) as PebbleDelegateeInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): PebbleDelegatee {
    return new Contract(address, _abi, signerOrProvider) as PebbleDelegatee;
  }
}
