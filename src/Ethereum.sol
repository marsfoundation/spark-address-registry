// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity >=0.8.0;

library Ethereum {

    /******************************************************************************************************************/
    /*** Token Addresses                                                                                            ***/
    /******************************************************************************************************************/

    address internal constant DAI    = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address internal constant GNO    = 0x6810e776880C02933D47DB1b9fc05908e5386b96;
    address internal constant MKR    = 0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2;
    address internal constant RETH   = 0xae78736Cd615f374D3085123A210448E74Fc6393;
    address internal constant SDAI   = 0x83F20F44975D03b1b09e64809B757c47f942BEeA;
    address internal constant SUSDE  = 0x9D39A5DE30e57443BfF2A8307A4256c8797A3497;
    address internal constant USDC   = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address internal constant USDE   = 0x4c9EDD5852cd905f086C759E8383e09bff1E68B3;
    address internal constant USDT   = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address internal constant WBTC   = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address internal constant WEETH  = 0xCd5fE23C85820F7B72D0926FC9b05b43E359b7ee;
    address internal constant WETH   = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address internal constant WSTETH = 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0;

    /******************************************************************************************************************/
    /*** MakerDAO Addresses                                                                                         ***/
    /******************************************************************************************************************/

    address internal constant PAUSE_PROXY = 0xBE8E3e3618f7474F8cB1d074A26afFef007E98FB;
    address internal constant POT         = 0x197E90f9FAD81970bA7976f33CbD77088E5D7cf7;
    address internal constant VAT         = 0x35D1b3F3D7966A1DFe207aa4514C12a259A0492B;
    address internal constant CHIEF       = 0x0a3f6849f78076aefaDf113F5BED87720274dDC0;

    /******************************************************************************************************************/
    /*** SparkDAO Addresses                                                                                         ***/
    /******************************************************************************************************************/

    address internal constant SPARK_PROXY = 0x3300f198988e4C9C63F75dF86De36421f06af8c4;

    /******************************************************************************************************************/
    /*** Morpho Addresses                                                                                           ***/
    /******************************************************************************************************************/

    address internal constant MORPHO_DEFAULT_IRM  = 0x870aC11D48B15DB9a138Cf899d20F13F79Ba00BC;
    address internal constant MORPHO_SUSDE_ORACLE = 0x5D916980D5Ae1737a8330Bf24dF812b2911Aae25;
    address internal constant MORPHO_USDE_ORACLE  = 0xaE4750d0813B5E37A51f7629beedd72AF1f9cA35;
    address internal constant MORPHO_VAULT_DAI_1  = 0x73e65DBD630f90604062f6E02fAb9138e713edD9;

    /******************************************************************************************************************/
    /*** SparkLend - Core Protocol Addresses                                                                        ***/
    /******************************************************************************************************************/

    address internal constant AAVE_ORACLE                      = 0x8105f69D9C41644c6A0803fDA7D03Aa70996cFD9;
    address internal constant ACL_MANAGER                      = 0xdA135Cd78A086025BcdC87B038a1C462032b510C;
    address internal constant DAI_TREASURY                     = 0x856900aa78e856a5df1a2665eE3a66b2487cD68f;
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
    /*** SparkLend - Reserve Token Addresses                                                                        ***/
    /******************************************************************************************************************/

    address internal constant DAI_ATOKEN             = 0x4DEDf26112B3Ec8eC46e7E31EA5e123490B05B8B;
    address internal constant DAI_STABLE_DEBT_TOKEN  = 0xfe2B7a7F4cC0Fb76f7Fc1C6518D586F1e4559176;
    address internal constant DAI_DEBT_TOKEN         = 0xf705d2B7e92B3F38e6ae7afaDAA2fEE110fE5914;

    address internal constant GNO_ATOKEN             = 0x7b481aCC9fDADDc9af2cBEA1Ff2342CB1733E50F;
    address internal constant GNO_STABLE_DEBT_TOKEN  = 0xbf13910620722D4D4F8A03962894EB3335Bf4FaE;
    address internal constant GNO_DEBT_TOKEN         = 0x57a2957651DA467fCD4104D749f2F3684784c25a;

    address internal constant RETH_ATOKEN             = 0x9985dF20D7e9103ECBCeb16a84956434B6f06ae8;
    address internal constant RETH_STABLE_DEBT_TOKEN  = 0xa9a4037295Ea3a168DC3F65fE69FdA524d52b3e1;
    address internal constant RETH_DEBT_TOKEN         = 0xBa2C8F2eA5B56690bFb8b709438F049e5Dd76B96;

    address internal constant SDAI_ATOKEN             = 0x78f897F0fE2d3B5690EbAe7f19862DEacedF10a7;
    address internal constant SDAI_STABLE_DEBT_TOKEN  = 0xEc6C6aBEd4DC03299EFf82Ac8A0A83643d3cB335;
    address internal constant SDAI_DEBT_TOKEN         = 0xaBc57081C04D921388240393ec4088Aa47c6832B;

    address internal constant USDC_ATOKEN             = 0x377C3bd93f2a2984E1E7bE6A5C22c525eD4A4815;
    address internal constant USDC_STABLE_DEBT_TOKEN  = 0x887Ac022983Ff083AEb623923789052A955C6798;
    address internal constant USDC_DEBT_TOKEN         = 0x7B70D04099CB9cfb1Db7B6820baDAfB4C5C70A67;

    address internal constant USDT_ATOKEN             = 0xe7dF13b8e3d6740fe17CBE928C7334243d86c92f;
    address internal constant USDT_STABLE_DEBT_TOKEN  = 0x0Dae62F953Ceb2E969fB4dE85f3F9074fa920776;
    address internal constant USDT_DEBT_TOKEN         = 0x529b6158d1D2992E3129F7C69E81a7c677dc3B12;

    address internal constant WBTC_ATOKEN             = 0x4197ba364AE6698015AE5c1468f54087602715b2;
    address internal constant WBTC_STABLE_DEBT_TOKEN  = 0x4b29e6cBeE62935CfC92efcB3839eD2c2F35C1d9;
    address internal constant WBTC_DEBT_TOKEN         = 0xf6fEe3A8aC8040C3d6d81d9A4a168516Ec9B51D2;

    address internal constant WEETH_ATOKEN            = 0x3CFd5C0D4acAA8Faee335842e4f31159fc76B008;
    address internal constant WEETH_STABLE_DEBT_TOKEN = 0x5B1F8aF3E6C0BF4d20e8e5220a4e4A3A8fA6Dc0A;
    address internal constant WEETH_DEBT_TOKEN        = 0xc2bD6d2fEe70A0A73a33795BdbeE0368AeF5c766;

    address internal constant WETH_ATOKEN             = 0x59cD1C87501baa753d0B5B5Ab5D8416A45cD71DB;
    address internal constant WETH_STABLE_DEBT_TOKEN  = 0x3c6b93D38ffA15ea995D1BC950d5D0Fa6b22bD05;
    address internal constant WETH_DEBT_TOKEN         = 0x2e7576042566f8D6990e07A1B61Ad1efd86Ae70d;

    address internal constant WSTETH_ATOKEN            = 0x12B54025C112Aa61fAce2CDB7118740875A566E9;
    address internal constant WSTETH_STABLE_DEBT_TOKEN = 0x9832D969a0c8662D98fFf334A4ba7FeE62b109C2;
    address internal constant WSTETH_DEBT_TOKEN        = 0xd5c3E3B566a42A6110513Ac7670C1a86D76E13E6;

    /******************************************************************************************************************/
    /*** SparkLend - Auxiliary Protocol Addresses                                                                   ***/
    /******************************************************************************************************************/

    address internal constant CAP_AUTOMATOR      = 0x2276f52afba7Cf2525fd0a050DF464AC8532d0ef;
    address internal constant FREEZER_MOM        = 0x237e3985dD7E373F2ec878EC1Ac48A228Cf2e7a3;
    address internal constant KILL_SWITCH_ORACLE = 0x909A86f78e1cdEd68F9c2Fe2c9CD922c401abe82;

    /******************************************************************************************************************/
    /*** SparkLend - Emergency Spells                                                                               ***/
    /******************************************************************************************************************/

    address internal constant SPELL_FREEZE_ALL       = 0x9e2890BF7f8D5568Cc9e5092E67Ba00C8dA3E97f;
    address internal constant SPELL_FREEZE_DAI       = 0xa2039bef2c5803d66E4e68F9E23a942E350b938c;
    address internal constant SPELL_PAUSE_ALL        = 0x425b0de240b4c2DC45979DB782A355D090Dc4d37;
    address internal constant SPELL_PAUSE_DAI        = 0xCacB88e39112B56278db25b423441248cfF94241;
    address internal constant SPELL_REMOVE_MULTISIG  = 0xE47AB4919F6F5459Dcbbfbe4264BD4630c0169A9;

    /******************************************************************************************************************/
    /*** SparkLend - Implementation Addresses                                                                       ***/
    /******************************************************************************************************************/

    address internal constant A_TOKEN_IMPL             = 0x6175ddEc3B9b38c88157C10A01ed4A3fa8639cC6;
    address internal constant DAI_TREASURY_IMPL        = 0xF1E57711Eb5F897b415de1aEFCB64d9BAe58D312;
    address internal constant INCENTIVES_IMPL          = 0x0ee554F6A1f7a4Cb4f82D4C124DdC2AD3E37fde1;
    address internal constant POOL_CONFIGURATOR_IMPL   = 0xF7b656C95420194b79687fc86D965FB51DA4799F;
    address internal constant POOL_IMPL                = 0x5aE329203E00f76891094DcfedD5Aca082a50e1b;
    address internal constant STABLE_DEBT_TOKEN_IMPL   = 0x026a5B6114431d8F3eF2fA0E1B2EDdDccA9c540E;
    address internal constant TREASURY_IMPL            = 0xF1E57711Eb5F897b415de1aEFCB64d9BAe58D312;
    address internal constant VARIABLE_DEBT_TOKEN_IMPL = 0x86C71796CcDB31c3997F8Ec5C2E3dB3e9e40b985;

    /******************************************************************************************************************/
    /*** SparkLend - Config Engine Addresses                                                                        ***/
    /******************************************************************************************************************/

    address internal constant CONFIG_ENGINE             = 0x3254F7cd0565aA67eEdC86c2fB608BE48d5cCd78;
    address internal constant PROXY_ADMIN               = 0x883A82BDd3d07ae6ACfD151020faD350df25087e;
    address internal constant RATES_FACTORY             = 0xfE57e187EF6285e90d7049e6a21571aa47cF11a2;
    address internal constant TRANSPARENT_PROXY_FACTORY = 0x777803CbDD89D5D5Bc1DdD2151B51b0B07F6bf37;

    /******************************************************************************************************************/
    /*** SparkLend - Data Provider Addresses                                                                        ***/
    /******************************************************************************************************************/

    address internal constant PROTOCOL_DATA_PROVIDER     = 0xFc21d6d146E6086B8359705C8b28512a983db0cb;
    address internal constant UI_INCENTIVE_DATA_PROVIDER = 0xA7F8A757C4f7696c015B595F51B2901AC0121B18;
    address internal constant UI_POOL_DATA_PROVIDER      = 0xF028c2F4b19898718fD0F77b9b881CbfdAa5e8Bb;
    address internal constant WALLET_BALANCE_PROVIDER    = 0xd2AeF86F51F92E8e49F42454c287AE4879D1BeDc;

    /******************************************************************************************************************/
    /*** SparkLend - Library Addresses                                                                              ***/
    /******************************************************************************************************************/

    address internal constant BORROW_LOGIC      = 0x4662C88C542F0954F8CccCDE4542eEc32d7E7e9a;
    address internal constant BRIDGE_LOGIC      = 0x2C54924711E479E639032704146b865E12f0C6D1;
    address internal constant EMODE_LOGIC       = 0x2Ad00613A66D71Ff2B0607fB3C4632C47a50DADe;
    address internal constant FLASH_LOAN_LOGIC  = 0x7f44e1c1dE70059D7cc483378BEFeE2a030CE247;
    address internal constant LIQUIDATION_LOGIC = 0x6aEa92693C527bC2c7B3171C6f2598d67d619088;
    address internal constant POOL_LOGIC        = 0x1761a0f74032963B6Ad0774C5EBF4586c0bD7604;
    address internal constant SUPPLY_LOGIC      = 0x46256841e36b7557BB8e4c706beD38b17A9EB2c1;

    /******************************************************************************************************************/
    /*** L2 Forwarders                                                                                              ***/
    /******************************************************************************************************************/

    address internal constant DSR_FORWARDER_OPTIMISM = 0x4042127DecC0cF7cc0966791abebf7F76294DeF3;
    address internal constant DSR_FORWARDER_BASE     = 0x8Ed551D485701fe489c215E13E42F6fc59563e0e;
    address internal constant DSR_FORWARDER_ARBITRUM = 0x7F36E7F562Ee3f320644F6031e03E12a02B85799;

    /******************************************************************************************************************/
    /*** Multisigs                                                                                                  ***/
    /******************************************************************************************************************/

    address internal constant MULTISIG_FREEZER = 0x44efFc473e81632B12486866AA1678edbb7BEeC3;
    address internal constant MULTISIG_REWARDS = 0x8076807464DaC94Ac8Aa1f7aF31b58F73bD88A27;

    /******************************************************************************************************************/
    /*** User Action Addresses                                                                                      ***/
    /******************************************************************************************************************/

    address internal constant USER_ACTIONS_PSM_VARIANT1 = 0x52d298Ff9e77E71C2EB1992260520E7b15257d99;

}
