// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.13;

library Gnosis {

    /******************************************************************************************************************/
    /*** Core Protocol Addresses                                                                                    ***/
    /******************************************************************************************************************/

    address internal constant AAVE_ORACLE                      = 0x8105f69D9C41644c6A0803fDA7D03Aa70996cFD9;
    address internal constant ACL_MANAGER                      = 0x86C71796CcDB31c3997F8Ec5C2E3dB3e9e40b985;
    address internal constant EMISSION_MANAGER                 = 0xf09e48dd4CA8e76F63a57ADd428bB06fee7932a4;
    address internal constant INCENTIVES                       = 0x98e6BcBA7d5daFbfa4a92dAF08d3d7512820c30C;
    address internal constant POOL                             = 0x2Dae5307c5E3FD1CF5A72Cb6F698f915860607e0;
    address internal constant POOL_ADDRESSES_PROVIDER          = 0xA98DaCB3fC964A6A0d2ce3B77294241585EAbA6d;
    address internal constant POOL_ADDRESSES_PROVIDER_REGISTRY = 0x49d24798d3b84965F0d1fc8684EF6565115e70c1;
    address internal constant POOL_CONFIGURATOR                = 0x2Fc8823E1b967D474b47Ae0aD041c2ED562ab588;
    address internal constant TREASURY                         = 0xb9E6DBFa4De19CCed908BcbFe1d015190678AB5f;
    address internal constant TREASURY_CONTROLLER              = 0x8220096398c3Dc2644026E8864f5D80Ef613B437;
    address internal constant WETH_GATEWAY                     = 0xBD7D6a9ad7865463DE44B05F04559f65e3B11704;

    /******************************************************************************************************************/
    /*** Data Provider Addresses                                                                                    ***/
    /******************************************************************************************************************/

    address internal constant PROTOCOL_DATA_PROVIDER     = 0x2a002054A06546bB5a264D57A81347e23Af91D18;
    address internal constant UI_INCENTIVE_DATA_PROVIDER = 0xA7F8A757C4f7696c015B595F51B2901AC0121B18;
    address internal constant UI_POOL_DATA_PROVIDER      = 0xF028c2F4b19898718fD0F77b9b881CbfdAa5e8Bb;
    address internal constant WALLET_BALANCE_PROVIDER    = 0xd2AeF86F51F92E8e49F42454c287AE4879D1BeDc;

    /******************************************************************************************************************/
    /*** Implementation Addresses                                                                                   ***/
    /******************************************************************************************************************/

    address internal constant A_TOKEN_IMPL             = 0x856900aa78e856a5df1a2665eE3a66b2487cD68f;
    address internal constant INCENTIVES_IMPL          = 0x764b4AB9bCA18eB633d92368F725765Ebb8f047C;
    address internal constant POOL_CONFIGURATOR_IMPL   = 0x6175ddEc3B9b38c88157C10A01ed4A3fa8639cC6;
    address internal constant POOL_IMPL                = 0xa8fC41696F2a230b03F77d258Db39069e9e55F56;
    address internal constant STABLE_DEBT_TOKEN_IMPL   = 0x4370D3b6C9588E02ce9D22e684387859c7Ff5b34;
    address internal constant TREASURY_IMPL            = 0x571501be53711c372cE69De51865dD34B87698D5;
    address internal constant VARIABLE_DEBT_TOKEN_IMPL = 0x0ee554F6A1f7a4Cb4f82D4C124DdC2AD3E37fde1;

}
