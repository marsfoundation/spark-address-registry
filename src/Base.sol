// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity >=0.8.0;

library Base {

    /******************************************************************************************************************/
    /*** Token Addresses                                                                                            ***/
    /******************************************************************************************************************/

    address internal constant USDC = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;

    /******************************************************************************************************************/
    /*** Bridging Addresses                                                                                         ***/
    /******************************************************************************************************************/

    address internal constant CCTP_TOKEN_MESSENGER = 0x1682Ae6375C4E4A97e4B583BC394c861A46D8962;

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
