// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity >=0.8.0;

library XLayer {

    /*******************************************************************************************************************

    ███████╗██████╗  █████╗ ██████╗ ██╗  ██╗     █████╗ ██╗   ██╗████████╗██╗  ██╗ ██████╗ ██████╗ ███████╗██████╗
    ██╔════╝██╔══██╗██╔══██╗██╔══██╗██║ ██╔╝    ██╔══██╗██║   ██║╚══██╔══╝██║  ██║██╔═══██╗██╔══██╗██╔════╝██╔══██╗
    ███████╗██████╔╝███████║██████╔╝█████╔╝     ███████║██║   ██║   ██║   ███████║██║   ██║██████╔╝█████╗  ██║  ██║
    ╚════██║██╔═══╝ ██╔══██║██╔══██╗██╔═██╗     ██╔══██╗██║   ██║   ██║   ██╔══██║██║   ██║██╔══██╗██╔══╝  ██║  ██║
    ███████║██║     ██║  ██║██║  ██║██║  ██╗    ██║  ██║╚██████╔╝   ██║   ██║  ██║╚██████╔╝██║  ██║███████╗██████╔╝
    ╚══════╝╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝    ╚═╝  ╚═╝ ╚═════╝    ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═════╝

    /******************************************************************************************************************/
    /*** Governance Relay addresses                                                                                 ***/
    /******************************************************************************************************************/

    address internal constant SPARK_EXECUTOR = 0xCF5af6F53ceC74B791cb4182aC778ca9CD323510;  // spark-gov-relay/Executor.sol@5c16676 (v1.0.1)
    address internal constant SPARK_RECEIVER = 0x4bd50B9c00Ae19e8B59723F27645C7A5cCe7a4A0;  // xchain-helpers/OptimismReceiver.sol@1e362bf (v1.2.0)

    /******************************************************************************************************************/
    /*** Spark PAU Core addresses                                                                                   ***/
    /******************************************************************************************************************/

    address internal constant SPARK_BEACON                     = 0x5612697F3F8c393A860ac0C9cf5b315c248cB0a0;  // diamond-pau/Beacon.sol@cbf71b2 (v1.14.0)
    address internal constant SPARK_PAU_FACTORY                = 0x0B33b8974eDe2985ac9E41931314337C01543fFE;  // diamond-pau/PauFactory.sol@cbf71b2 (v1.14.0)
    address internal constant SPARK_ADMINISTERED_AGENT_FACTORY = 0x039bC8CAe7A5b2B981E5ED98B840C76c7FBacDAc;  // pau-administered-agent/AdministeredAgentFactory.sol@bfaaf70 (v1.0.0)
    address internal constant SPARK_DEFAULT_PAU_ASSEMBLER      = 0xaCae58f96C959A792FaeaEc72CA870c2E36B3C80;  // pau-assemblers/DefaultPauAssembler.sol@d7d6f08 (v1.0.0)

    /******************************************************************************************************************/
    /*** Spark PAU Facets addresses                                                                                 ***/
    /******************************************************************************************************************/

    address internal constant AAVE_FACET           = 0xc8C8930F28622D240fF380bC8b2224119b477249;  // diamond-pau/AAVEFacet.sol@cbf71b2 (v1.14.0)
    address internal constant CCTP_FACET           = 0x4a966353B421dF6ddd08E432A1E55B884Cb92D4E;  // diamond-pau/CCTPFacet.sol@cbf71b2 (v1.14.0)
    address internal constant ERC4626_FACET        = 0x3fC45da74c30644172620520F6bAf6783aec11F2;  // diamond-pau/ERC4626Facet.sol@cbf71b2 (v1.14.0)
    address internal constant LAYER_ZERO_FACET     = 0x936D542661734F2D9a96A75fF27B1BC1D2B5dfB5;  // diamond-pau/LayerZeroFacet.sol@cbf71b2 (v1.14.0)
    address internal constant SPARK_VAULT_FACET    = 0x3a35fF0B4D6375f8F3692562d378C1e5Ed482053;  // diamond-pau/SparkVaultFacet.sol@cbf71b2 (v1.14.0)
    address internal constant TRANSFER_ASSET_FACET = 0xF0830c3B800a36ff3F3E9229e0443CD5b7779e0D;  // diamond-pau/TransferAssetFacet.sol@cbf71b2 (v1.14.0)
    address internal constant UNISWAP_V4_FACET     = 0x5d694339037c551D71825bf9B812D4350972369e;  // diamond-pau/UniswapV4Facet.sol@cbf71b2 (v1.14.0)

    /******************************************************************************************************************/
    /*** Spark Liquidity Layer addresses                                                                            ***/
    /******************************************************************************************************************/

    address internal constant ALM_CONTROLLER      = 0xf9187C99Ee842beABE8e2e346d958315BFc9331f;  // spark-alm-controller/ForeignController.sol@984ec54 (v1.10.0)
    address internal constant ALM_PROXY           = 0x83A914C361bB729EB6BEBC8C7bA993667A0E6Df8;  // spark-alm-controller/ALMProxy.sol@984ec54 (v1.10.0)
    address internal constant ALM_PROXY_FREEZABLE = 0x9449ed367C60ea757544fd990B57e1C2D0Ec3A94;  // diamond-pau/ALMProxyFreezable.sol@a84fe96 (v1.12.0)
    address internal constant ALM_RATE_LIMITS     = 0x7F7E2286983994c4403Cf2B86758cE0e7bA666a8;  // spark-alm-controller/RateLimits.sol@984ec54 (v1.10.0)

    /******************************************************************************************************************/
    /*** Spark Vault V2 addresses                                                                                   ***/
    /******************************************************************************************************************/

    address internal constant SPARK_VAULT_V2_IMPL   = 0xdCe929A335C75a1676EF5957A4D7a3b928C48820;  // spark-vaults-v2/SparkVault.sol@0a686ba (v1.0.1)
    address internal constant SPARK_VAULT_V2_SPUSDC = 0xf90E63079D97a0A1f479b2b168457F420CAFf6ba;  // openzeppelin-contracts/ERC1967Proxy.sol@c64a1edb (v5.4.0)
    address internal constant SPARK_VAULT_V2_SPUSDT = 0xc358c90D32375721Cb3924320Fdc2F8B694347Ca;  // openzeppelin-contracts/ERC1967Proxy.sol@c64a1edb (v5.4.0)

    /******************************************************************************************************************/
    /*** Spark SPUSDC Seggregated PAU addresses                                                                     ***/
    /******************************************************************************************************************/

    address internal constant SPUSDC_PAU_ACCESS_CONTROLS    = 0x30271Ae5d90B34f0f8BAA840AaE63a7DBF347e84;  // diamond-pau/AccessControls.sol@cbf71b2 (v1.14.0)
    address internal constant SPUSDC_PAU_ADMINISTERED_AGENT = 0x79b4055Eda153f739B5EA63C9B647c1a095059f5;  // pau-administered-agent/AdministeredAgent.sol@bfaaf70 (v1.0.0)
    address internal constant SPUSDC_PAU_ALM_PROXY          = 0xe6D5d041Fc5e7fDD0A53C13e78a1cc7e4ffCb667;  // diamond-pau/ALMProxy.sol@cbf71b2 (v1.14.0)
    address internal constant SPUSDC_PAU_CONTROLLER         = 0x8d19d306cA6075f74B26B150383379aedB0250f6;  // diamond-pau/Controller.sol@cbf71b2 (v1.14.0)
    address internal constant SPUSDC_PAU_RATELIMITS         = 0xBC3Ea763532aA0dec71449414b85ca66c6dD63e2;  // diamond-pau/RateLimits.sol@cbf71b2 (v1.14.0)

    /******************************************************************************************************************/
    /*** Spark Intents addresses                                                                                    ***/
    /******************************************************************************************************************/

    address internal constant SPARK_SAVINGS_INTENTS = 0x5bCD2f30FA1Bf675d5d6E793DAD7DdD487D21865;  // spark-savings-intents/SavingsVaultIntents.sol@d9045fc (v1.0.0)

    /*******************************************************************************************************************

    ███████╗██████╗  █████╗ ██████╗ ██╗  ██╗    ███╗   ███╗ █████╗ ███╗   ██╗ █████╗  ██████╗ ███████╗██████╗
    ██╔════╝██╔══██╗██╔══██╗██╔══██╗██║ ██╔╝    ████╗ ████║██╔══██╗████╗  ██║██╔══██╗██╔════╝ ██╔════╝██╔══██╗
    ███████╗██████╔╝███████║██████╔╝█████╔╝     ██╔████╔██║███████║██╔██╗ ██║███████║██║  ███╗█████╗  ██╔══██╗
    ╚════██║██╔═══╝ ██╔══██║██╔══██╗██╔═██╗     ██║╚██╔╝██║██╔══██║██║╚██╗██║██╔══██║██║   ██║██╔══╝  ██║  ██║
    ███████║██║     ██║  ██║██║  ██║██║  ██╗    ██║ ╚═╝ ██║██║  ██║██║ ╚████║██║  ██║╚██████╔╝███████╗██████╔╝
    ╚══════╝╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝    ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═════╝

    /******************************************************************************************************************/
    /*** Multisig addresses                                                                                         ***/
    /******************************************************************************************************************/

    // Operational Multisigs
    address internal constant ALM_RELAYER_MULTISIG = 0x8a25A24EDE9482C4Fc0738F99611BE58F1c839AB;
    address internal constant PAU_GRANTOR_MULTISIG = 0x4B61A0E48dd1e300f64090C60F414c1aC6CbC514;

    // Emergency Multisigs
    address internal constant ALM_BACKSTOP_RELAYER_MULTISIG = 0x9330edE0Fc6E3E0D47Ebf3C145efd569796aC7F5;
    address internal constant ALM_FREEZER_MULTISIG          = 0x90D8c80C028B4C09C0d8dcAab9bbB057F0513431;

    /*******************************************************************************************************************

    ███████╗██╗  ██╗████████╗███████╗██████╗ ███╗   ██╗ █████╗ ██╗
    ██╔════╝╚██╗██╔╝╚══██╔══╝██╔════╝██╔══██╗████╗  ██║██╔══██╗██║
    █████╗   ╚███╔╝    ██║   █████╗  ██████╔╝██╔██╗ ██║███████║██║
    ██╔══╝   ██╔██╗    ██║   ██╔══╝  ██╔══██╗██║╚██╗██║██╔══██║██║
    ███████╗██╔╝ ██╗   ██║   ███████╗██║  ██║██║ ╚████║██║  ██║███████╗
    ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝

    /******************************************************************************************************************/
    /*** Token addresses                                                                                            ***/
    /******************************************************************************************************************/

    address internal constant USDT0 = 0x779Ded0c9e1022225f8E0630b35a9b54bE713736;

}
