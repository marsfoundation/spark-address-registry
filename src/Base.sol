// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity >=0.8.0;

library Base {

    /******************************************************************************************************************/
    /*** Token Addresses                                                                                            ***/
    /******************************************************************************************************************/

    address internal constant CBBTC = 0xcbB7C0000aB88B473b1f5aFd9ef808440eed33Bf;
    address internal constant SKY   = 0x60e3c701e65DEE30c23c9Fb78c3866479cc0944a;
    address internal constant SUSDS = 0x5875eEE11Cf8398102FdAd704C9E96607675467a;
    address internal constant USDC  = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;
    address internal constant USDS  = 0x820C137fa70C8691f0e44Dc420a5e53c168921Dc;

    /******************************************************************************************************************/
    /*** Bridging Addresses                                                                                         ***/
    /******************************************************************************************************************/

    address internal constant CCTP_TOKEN_MESSENGER = 0x1682Ae6375C4E4A97e4B583BC394c861A46D8962;

    address internal constant SKY_GOV_RELAY = 0xdD0BCc201C9E47c6F6eE68E4dB05b652Bb6aC255;
    address internal constant TOKEN_BRIDGE  = 0xee44cdb68D618d58F75d9fe0818B640BD7B8A7B7;

    /******************************************************************************************************************/
    /*** PSM Addresses                                                                                              ***/
    /******************************************************************************************************************/

    address internal constant PSM3 = 0x1601843c5E9bC251A3272907010AFa41Fa18347E;

    /******************************************************************************************************************/
    /*** Spark Liquidity Layer Addresses                                                                            ***/
    /******************************************************************************************************************/

    address internal constant ALM_CONTROLLER  = 0x5F032555353f3A1D16aA6A4ADE0B35b369da0440;
    address internal constant ALM_PROXY       = 0x2917956eFF0B5eaF030abDB4EF4296DF775009cA;
    address internal constant ALM_RATE_LIMITS = 0x983eC82E45C61a42FDDA7B3c43B8C767004c8A74;

    address internal constant ALM_FREEZER = 0x90D8c80C028B4C09C0d8dcAab9bbB057F0513431;
    address internal constant ALM_RELAYER = 0x8a25A24EDE9482C4Fc0738F99611BE58F1c839AB;

    /******************************************************************************************************************/
    /*** Aave Addresses                                                                                             ***/
    /******************************************************************************************************************/

    address internal constant ATOKEN_USDC = 0x4e65fE4DbA92790696d040ac24Aa414708F5c0AB;

    /******************************************************************************************************************/
    /*** Morpho Addresses                                                                                           ***/
    /******************************************************************************************************************/

    address internal constant MORPHO_DEFAULT_IRM = 0x46415998764C29aB2a25CbeA6254146D50D22687;
    address internal constant MORPHO_VAULT_SUSDC = 0x7BfA7C4f149E7415b73bdeDfe609237e29CBF34A;

    /******************************************************************************************************************/
    /*** Governance Relay Addresses                                                                                 ***/
    /******************************************************************************************************************/

    address internal constant SPARK_EXECUTOR = 0xF93B7122450A50AF3e5A76E1d546e95Ac1d0F579;
    address internal constant SPARK_RECEIVER = 0xfda082e00EF89185d9DB7E5DcD8c5505070F5A3B;

    /******************************************************************************************************************/
    /*** SSR Oracle Addresses                                                                                       ***/
    /******************************************************************************************************************/

    address internal constant SSR_AUTH_ORACLE            = 0x65d946e533748A998B1f0E430803e39A6388f7a1;
    address internal constant SSR_RECEIVER               = 0x212871A1C235892F86cAB30E937e18c94AEd8474;
    address internal constant SSR_BALANCER_RATE_PROVIDER = 0x49aF4eE75Ae62C2229bb2486a59Aa1a999f050f0;

    /******************************************************************************************************************/
    /*** DSR Oracle Addresses (Legacy)                                                                              ***/
    /******************************************************************************************************************/

    address internal constant DSR_AUTH_ORACLE            = 0x2Dd2a2Fe346B5704380EfbF6Bd522042eC3E8FAe;
    address internal constant DSR_RECEIVER               = 0xaDEAf02Ddb5Bed574045050B8096307bE66E0676;
    address internal constant DSR_BALANCER_RATE_PROVIDER = 0xeC0C14Ea7fF20F104496d960FDEBF5a0a0cC14D0;

}
