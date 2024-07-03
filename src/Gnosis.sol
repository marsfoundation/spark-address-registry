// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity >=0.8.0;

library Gnosis {

    /******************************************************************************************************************/
    /*** Token Addresses                                                                                            ***/
    /******************************************************************************************************************/

    address internal constant GNO    = 0x9C58BAcC331c9aa871AFD802DB6379a98e80CEdb;
    address internal constant WETH   = 0x6A023CCd1ff6F2045C3309768eAd9E68F978f6e1;
    address internal constant WSTETH = 0x6C76971f98945AE98dD7d4DFcA8711ebea946eA6;
    address internal constant WXDAI  = 0xe91D153E0b41518A2Ce8Dd3D7944Fa863463a97d;
    address internal constant SXDAI  = 0xaf204776c7245bF4147c2612BF6e5972Ee483701;
    address internal constant USDC   = 0xDDAfbb505ad214D7b80b1f830fcCc89B60fb7A83;
    address internal constant USDCE  = 0x2a22f9c3b484c3629090FeED35F17Ff8F88f76F0;
    address internal constant USDT   = 0x4ECaBa5870353805a9F068101A40E0f32ed605C6;
    address internal constant EURE   = 0xcB444e90D8198415266c6a2724b7900fb12FC56E;

    /******************************************************************************************************************/
    /*** SparkLend - Core Protocol Addresses                                                                        ***/
    /******************************************************************************************************************/

    address internal constant AAVE_ORACLE                      = 0x8105f69D9C41644c6A0803fDA7D03Aa70996cFD9;
    address internal constant ACL_MANAGER                      = 0x86C71796CcDB31c3997F8Ec5C2E3dB3e9e40b985;
    address internal constant EMISSION_MANAGER                 = 0x4d988568b5f0462B08d1F40bA1F5f17ad2D24F76;
    address internal constant INCENTIVES                       = 0x98e6BcBA7d5daFbfa4a92dAF08d3d7512820c30C;
    address internal constant POOL                             = 0x2Dae5307c5E3FD1CF5A72Cb6F698f915860607e0;
    address internal constant POOL_ADDRESSES_PROVIDER          = 0xA98DaCB3fC964A6A0d2ce3B77294241585EAbA6d;
    address internal constant POOL_ADDRESSES_PROVIDER_REGISTRY = 0x49d24798d3b84965F0d1fc8684EF6565115e70c1;
    address internal constant POOL_CONFIGURATOR                = 0x2Fc8823E1b967D474b47Ae0aD041c2ED562ab588;
    address internal constant TREASURY                         = 0xb9E6DBFa4De19CCed908BcbFe1d015190678AB5f;
    address internal constant TREASURY_CONTROLLER              = 0x8220096398c3Dc2644026E8864f5D80Ef613B437;
    address internal constant WETH_GATEWAY                     = 0xBD7D6a9ad7865463DE44B05F04559f65e3B11704;

    /******************************************************************************************************************/
    /*** SparkLend - Reserve Token Addresses                                                                        ***/
    /******************************************************************************************************************/

    address internal constant GNO_ATOKEN            = 0x5671b0B8aC13DC7813D36B99C21c53F6cd376a14;
    address internal constant GNO_STABLE_DEBT_TOKEN = 0x2f589BADbE2024a94f144ef24344aF91dE21a33c;
    address internal constant GNO_DEBT_TOKEN        = 0xd4bAbF714964E399f95A7bb94B3DeaF22d9F575d;

    address internal constant WETH_ATOKEN            = 0x629D562E92fED431122e865Cc650Bc6bdE6B96b0;
    address internal constant WETH_STABLE_DEBT_TOKEN = 0xe21Bf3FB5A2b5Bf7BAE8c6F1696c4B097F5D2f93;
    address internal constant WETH_DEBT_TOKEN        = 0x0aD6cCf9a2e81d4d48aB7db791e9da492967eb84;

    address internal constant WSTETH_ATOKEN            = 0x9Ee4271E17E3a427678344fd2eE64663Cb78B4be;
    address internal constant WSTETH_STABLE_DEBT_TOKEN = 0x0F0e336Ab69D9516A9acF448bC59eA0CE79E4a42;
    address internal constant WSTETH_DEBT_TOKEN        = 0x3294dA2E28b29D1c08D556e2B86879d221256d31;

    address internal constant WXDAI_ATOKEN            = 0xC9Fe2D32E96Bb364c7d29f3663ed3b27E30767bB;
    address internal constant WXDAI_STABLE_DEBT_TOKEN = 0xab1B62A1346Acf534b581684940E2FD781F2EA22;
    address internal constant WXDAI_DEBT_TOKEN        = 0x868ADfDf12A86422524EaB6978beAE08A0008F37;

    address internal constant SXDAI_ATOKEN            = 0xE877b96caf9f180916bF2B5Ce7Ea8069e0123182;
    address internal constant SXDAI_STABLE_DEBT_TOKEN = 0x2cF710377b3576287Be7cf352FF75D4472902789;
    address internal constant SXDAI_DEBT_TOKEN        = 0x1022E390E2457A78E18AEEE0bBf0E96E482EeE19;

    address internal constant USDC_ATOKEN            = 0x5850D127a04ed0B4F1FCDFb051b3409FB9Fe6B90;
    address internal constant USDC_STABLE_DEBT_TOKEN = 0x40BF0Bf6AECeE50eCE10C74E81a52C654A467ae4;
    address internal constant USDC_DEBT_TOKEN        = 0xBC4f20DAf4E05c17E93676D2CeC39769506b8219;

    address internal constant USDCE_ATOKEN            = 0xA34DB0ee8F84C4B90ed268dF5aBbe7Dcd3c277ec;
    address internal constant USDCE_STABLE_DEBT_TOKEN = 0xC5dfde524371F9424c81F453260B2CCd24936c15;
    address internal constant USDCE_DEBT_TOKEN        = 0x397b97b572281d0b3e3513BD4A7B38050a75962b;

    address internal constant USDT_ATOKEN            = 0x08B0cAebE352c3613302774Cd9B82D08afd7bDC4;
    address internal constant USDT_STABLE_DEBT_TOKEN = 0x4cB3F681B5e393947BD1e5cAE84764f5892923C2;
    address internal constant USDT_DEBT_TOKEN        = 0x3A98aBC6F46CA2Fc6c7d06eD02184D63C55e19B2;

    address internal constant EURE_ATOKEN            = 0x6dc304337BF3EB397241d1889cAE7da638e6e782;
    address internal constant EURE_STABLE_DEBT_TOKEN = 0x80F87B8F9c1199e468923D8EE87cEE311690FDA6;
    address internal constant EURE_DEBT_TOKEN        = 0x0b33480d3FbD1E2dBE88c82aAbe191D7473759D5;

    /******************************************************************************************************************/
    /*** SparkLend - Implementation Addresses                                                                       ***/
    /******************************************************************************************************************/

    address internal constant A_TOKEN_IMPL             = 0x856900aa78e856a5df1a2665eE3a66b2487cD68f;
    address internal constant INCENTIVES_IMPL          = 0x764b4AB9bCA18eB633d92368F725765Ebb8f047C;
    address internal constant POOL_CONFIGURATOR_IMPL   = 0x6175ddEc3B9b38c88157C10A01ed4A3fa8639cC6;
    address internal constant POOL_IMPL                = 0xCF86A65779e88bedfF0319FE13aE2B47358EB1bF;
    address internal constant STABLE_DEBT_TOKEN_IMPL   = 0x4370D3b6C9588E02ce9D22e684387859c7Ff5b34;
    address internal constant TREASURY_IMPL            = 0x571501be53711c372cE69De51865dD34B87698D5;
    address internal constant VARIABLE_DEBT_TOKEN_IMPL = 0x0ee554F6A1f7a4Cb4f82D4C124DdC2AD3E37fde1;

    /******************************************************************************************************************/
    /*** SparkLend - Config Engine Addresses                                                                        ***/
    /******************************************************************************************************************/

    address internal constant PROXY_ADMIN               = 0xf76B8262dfd60fb7432C6b55E91f42b6da953647;
    address internal constant CONFIG_ENGINE             = 0x36eddc380C7f370e5f05Da5Bd7F970a27f063e39;
    address internal constant RATES_FACTORY             = 0xe04ba71E46fCd7DBB9334D8FBa13d476f38EB0f8;
    address internal constant TRANSPARENT_PROXY_FACTORY = 0x91277b74a9d1Cc30fA0ff4927C287fe55E307D78;

    /******************************************************************************************************************/
    /*** SparkLend - Data Provider Addresses                                                                        ***/
    /******************************************************************************************************************/

    address internal constant PROTOCOL_DATA_PROVIDER     = 0x2a002054A06546bB5a264D57A81347e23Af91D18;
    address internal constant UI_INCENTIVE_DATA_PROVIDER = 0xA7F8A757C4f7696c015B595F51B2901AC0121B18;
    address internal constant UI_POOL_DATA_PROVIDER      = 0xF028c2F4b19898718fD0F77b9b881CbfdAa5e8Bb;
    address internal constant WALLET_BALANCE_PROVIDER    = 0xd2AeF86F51F92E8e49F42454c287AE4879D1BeDc;

    /******************************************************************************************************************/
    /*** Governance Addresses                                                                                       ***/
    /******************************************************************************************************************/

    address constant AMB_EXECUTOR = 0xc4218C1127cB24a0D6c1e7D25dc34e10f2625f5A;

}
