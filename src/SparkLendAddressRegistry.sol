// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.13;

library SparkLendAddressRegistry {

    /******************************************************************************************************************/
    /*** Actor Addresses                                                                                            ***/
    /******************************************************************************************************************/

    address internal constant ADMIN    = 0xBE8E3e3618f7474F8cB1d074A26afFef007E98FB;
    address internal constant DEPLOYER = 0xd1236a6A111879d9862f8374BA15344b6B233Fbd;

    /******************************************************************************************************************/
    /*** Core Protocol Addresses                                                                                    ***/
    /******************************************************************************************************************/

    address internal constant AAVE_ORACLE                      = 0x8105f69D9C41644c6A0803fDA7D03Aa70996cFD9;
    address internal constant ACL_MANAGER                      = 0xdA135Cd78A086025BcdC87B038a1C462032b510C;
    address internal constant DAI_TREASURY                     = 0x856900aa78e856a5df1a2665eE3a66b2487cD68f;  // Deprecated?
    address internal constant EMISSION_MANAGER                 = 0xf09e48dd4CA8e76F63a57ADd428bB06fee7932a4;
    address internal constant INCENTIVES                       = 0x4370D3b6C9588E02ce9D22e684387859c7Ff5b34;
    address internal constant POOL                             = 0xC13e21B648A5Ee794902342038FF3aDAB66BE987;
    address internal constant POOL_ADDRESSES_PROVIDER          = 0x02C3eA4e34C0cBd694D2adFa2c690EECbC1793eE;
    address internal constant POOL_ADDRESSES_PROVIDER_REGISTRY = 0x03cFa0C4622FF84E50E75062683F44c9587e6Cc1;
    address internal constant POOL_CONFIGURATOR                = 0x542DBa469bdE58FAeE189ffB60C6b49CE60E0738;
    address internal constant TREASURY                         = 0xb137E7d16564c81ae2b0C8ee6B55De81dd46ECe5;
    address internal constant TREASURY_CONTROLLER              = 0x92eF091C5a1E01b3CE1ba0D0150C84412d818F7a;
    address internal constant WETH_GATEWAY                     = 0xBD7D6a9ad7865463DE44B05F04559f65e3B11704;

    /******************************************************************************************************************/
    /*** Reserve Addresses                                                                                          ***/
    /******************************************************************************************************************/

    address internal constant DAI_ATOKEN            = 0x4DEDf26112B3Ec8eC46e7E31EA5e123490B05B8B;
    address internal constant DAI_IRM               = 0x113dc45c524404F91DcbbAbB103506bABC8Df0FE;
    address internal constant DAI_ORACLE            = 0xAed0c38402a5d19df6E4c03F4E2DceD6e29c1ee9;
    address internal constant DAI_STABLE_DEBT_TOKEN = 0xfe2B7a7F4cC0Fb76f7Fc1C6518D586F1e4559176;
    address internal constant DAI                   = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address internal constant DAI_DEBT_TOKEN        = 0xf705d2B7e92B3F38e6ae7afaDAA2fEE110fE5914;

    address internal constant SDAI_ATOKEN            = 0x78f897F0fE2d3B5690EbAe7f19862DEacedF10a7;
    address internal constant SDAI_IRM               = 0xeC4cf692c18E62159a39704Aa1Db82ca2306fF90;
    address internal constant SDAI_ORACLE            = 0xb9E6DBFa4De19CCed908BcbFe1d015190678AB5f;
    address internal constant SDAI_STABLE_DEBT_TOKEN = 0xEc6C6aBEd4DC03299EFf82Ac8A0A83643d3cB335;
    address internal constant SDAI                   = 0x83F20F44975D03b1b09e64809B757c47f942BEeA;
    address internal constant SDAI_DEBT_TOKEN        = 0xaBc57081C04D921388240393ec4088Aa47c6832B;

    address internal constant USDC_ATOKEN            = 0x377C3bd93f2a2984E1E7bE6A5C22c525eD4A4815;
    address internal constant USDC_IRM               = 0x4d988568b5f0462B08d1F40bA1F5f17ad2D24F76;
    address internal constant USDC_ORACLE            = 0x98e6BcBA7d5daFbfa4a92dAF08d3d7512820c30C;
    address internal constant USDC_STABLE_DEBT_TOKEN = 0x887Ac022983Ff083AEb623923789052A955C6798;
    address internal constant USDC                   = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address internal constant USDC_DEBT_TOKEN        = 0x7B70D04099CB9cfb1Db7B6820baDAfB4C5C70A67;

    address internal constant WBTC_ATOKEN            = 0x4197ba364AE6698015AE5c1468f54087602715b2;
    address internal constant WBTC_IRM               = 0xf2812d7a07573322D4Db3C31239C837081D8294E;
    address internal constant WBTC_ORACLE            = 0x230E0321Cf38F09e247e50Afc7801EA2351fe56F;
    address internal constant WBTC_STABLE_DEBT_TOKEN = 0x4b29e6cBeE62935CfC92efcB3839eD2c2F35C1d9;
    address internal constant WBTC                   = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address internal constant WBTC_DEBT_TOKEN        = 0xf6fEe3A8aC8040C3d6d81d9A4a168516Ec9B51D2;

    address internal constant WETH_ATOKEN            = 0x59cD1C87501baa753d0B5B5Ab5D8416A45cD71DB;
    address internal constant WETH_IRM               = 0x764b4AB9bCA18eB633d92368F725765Ebb8f047C;
    address internal constant WETH_ORACLE            = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
    address internal constant WETH_STABLE_DEBT_TOKEN = 0x3c6b93D38ffA15ea995D1BC950d5D0Fa6b22bD05;
    address internal constant WETH                   = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address internal constant WETH_DEBT_TOKEN        = 0x2e7576042566f8D6990e07A1B61Ad1efd86Ae70d;

    address internal constant WSTETH_ATOKEN            = 0x12B54025C112Aa61fAce2CDB7118740875A566E9;
    address internal constant WSTETH_IRM               = 0x0D56700c90a690D8795D6C148aCD94b12932f4E3;
    address internal constant WSTETH_ORACLE            = 0xA9F30e6ED4098e9439B2ac8aEA2d3fc26BcEbb45;
    address internal constant WSTETH_STABLE_DEBT_TOKEN = 0x9832D969a0c8662D98fFf334A4ba7FeE62b109C2;
    address internal constant WSTETH                   = 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0;
    address internal constant WSTETH_DEBT_TOKEN        = 0xd5c3E3B566a42A6110513Ac7670C1a86D76E13E6;

    /******************************************************************************************************************/
    /*** Data Provider Addresses                                                                                    ***/
    /******************************************************************************************************************/

    address internal constant PROTOCOL_DATA_PROVIDER     = 0xFc21d6d146E6086B8359705C8b28512a983db0cb;
    address internal constant UI_INCENTIVE_DATA_PROVIDER = 0xA7F8A757C4f7696c015B595F51B2901AC0121B18;
    address internal constant UI_POOL_DATA_PROVIDER      = 0xF028c2F4b19898718fD0F77b9b881CbfdAa5e8Bb;
    address internal constant WALLET_BALANCE_PROVIDER    = 0xd2AeF86F51F92E8e49F42454c287AE4879D1BeDc;

    /******************************************************************************************************************/
    /*** Implementation Addresses                                                                                   ***/
    /******************************************************************************************************************/

    address internal constant A_TOKEN_IMPL             = 0x6175ddEc3B9b38c88157C10A01ed4A3fa8639cC6;
    address internal constant DA_TREASURY_IMPL         = 0xF1E57711Eb5F897b415de1aEFCB64d9BAe58D312;  // Deprecated?
    address internal constant INCENTIVES_IMPL          = 0x0ee554F6A1f7a4Cb4f82D4C124DdC2AD3E37fde1;
    address internal constant POOL_CONFIGURATOR_IMPL   = 0xF7b656C95420194b79687fc86D965FB51DA4799F;
    address internal constant POOL_IMPL                = 0x8115366Ca7Cf280a760f0bC0F6Db3026e2437115;
    address internal constant STABLE_DEBT_TOKEN_IMPL   = 0x026a5B6114431d8F3eF2fA0E1B2EDdDccA9c540E;
    address internal constant TREASURY_IMPL            = 0xF1E57711Eb5F897b415de1aEFCB64d9BAe58D312;
    address internal constant VARIABLE_DEBT_TOKEN_IMPL = 0x86C71796CcDB31c3997F8Ec5C2E3dB3e9e40b985;

}
