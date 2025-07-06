import { EndpointId } from '@layerzerolabs/lz-definitions'
import { ExecutorOptionType } from '@layerzerolabs/lz-v2-utilities'
import { TwoWayConfig, generateConnectionsConfig } from '@layerzerolabs/metadata-tools'
import { OAppEnforcedOption, OmniPointHardhat } from '@layerzerolabs/toolbox-hardhat'

const celoContract: OmniPointHardhat = {
    eid: EndpointId.CELO_V2_TESTNET,
    contractName: 'MyOApp',
}

const baseContract: OmniPointHardhat = {
    eid: EndpointId.BASESEP_V2_TESTNET,
    contractName: 'MyOApp',
}

// For this example's simplicity, we will use the same enforced options values for sending to all chains
// For production, you should ensure `gas` is set to the correct value through profiling the gas usage of calling OApp._lzReceive(...) on the destination chain
// To learn more, read https://docs.layerzero.network/v2/concepts/applications/oapp-standard#execution-options-and-enforced-settings
const EVM_ENFORCED_OPTIONS: OAppEnforcedOption[] = [
    {
        msgType: 1,
        optionType: ExecutorOptionType.LZ_RECEIVE,
        gas: 80000,
        value: 0,
    },
]

//
// const DEFAULT_EDGE_CONFIG: OAppEdgeConfig = {
//     // Gas can be profiled and enforced based on your contract's needs
//     enforcedOptions: [
//         {
//             msgType: 1,
//             optionType: ExecutorOptionType.LZ_RECEIVE,
//             gas: 100_000,
//             value: 0,
//         },
//         {
//             msgType: 2,
//             optionType: ExecutorOptionType.LZ_RECEIVE,
//             gas: 100_000,
//             value: 0,
//         },
//         {
//             msgType: 2,
//             optionType: ExecutorOptionType.COMPOSE,
//             index: 0,
//             gas: 100_000,
//             value: 0,
//         },
//     ],
// }

// To connect all the above chains to each other, we need the following pathways:
// Optimism <-> Arbitrum

// With the config generator, pathways declared are automatically bidirectional
// i.e. if you declare A,B there's no need to declare B,A
const pathways: TwoWayConfig[] = [
    [
        celoContract, // Chain A contract
        baseContract, // Chain B contract
        [['LayerZero Labs'], []], // [ requiredDVN[], [ optionalDVN[], threshold ] ]
        [1, 1], // [A to B confirmations, B to A confirmations]
        [EVM_ENFORCED_OPTIONS, EVM_ENFORCED_OPTIONS], // Chain B enforcedOptions, Chain A enforcedOptions
    ],
]

export default async function () {
    // Generate the connections config based on the pathways
    const connections = await generateConnectionsConfig(pathways)
    // ideal only only one pathway is defined, but you can define multiple pathways
    //     const connections = [
    //     {
    //         from: celoContract,
    //         to: baseContract,
    //         config: DEFAULT_EDGE_CONFIG,
    //     },
    // ]

    return {
        contracts: [{ contract: celoContract }, { contract: baseContract }],
        connections,
    }
}
