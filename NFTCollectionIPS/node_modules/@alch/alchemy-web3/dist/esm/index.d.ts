import Web3 from "web3";
import { Log, LogsOptions, Transaction } from "web3-core";
import { Subscription } from "web3-core-subscriptions";
import { BlockHeader, Eth, Syncing } from "web3-eth";
import { AssetTransfersParams, AssetTransfersResponse, GetNftMetadataParams, GetNftMetadataResponse, GetNftsParams, GetNftsParamsWithoutMetadata, GetNftsResponse, GetNftsResponseWithoutMetadata, PrivateTransactionPreferences, TokenAllowanceParams, TokenAllowanceResponse, TokenBalancesResponse, TokenMetadataResponse, TransactionReceiptsParams, TransactionReceiptsResponse } from "./alchemy-apis/types";
import { AlchemyWeb3Config, PendingTransactionsOptions, PendingTransactionsOptionsHashesOnly, Provider, TransactionsOptions, Web3Callback } from "./types";
export * from "./alchemy-apis/types";
export interface AlchemyWeb3 extends Web3 {
    alchemy: AlchemyMethods;
    eth: AlchemyEth;
    setWriteProvider(provider: Provider | null | undefined): void;
}
export interface AlchemyMethods {
    getTokenAllowance(params: TokenAllowanceParams, callback?: Web3Callback<TokenAllowanceResponse>): Promise<TokenAllowanceResponse>;
    getTokenBalances(address: string, contractAddresses?: string[], callback?: Web3Callback<TokenBalancesResponse>): Promise<TokenBalancesResponse>;
    getTokenMetadata(address: string, callback?: Web3Callback<TokenMetadataResponse>): Promise<TokenMetadataResponse>;
    getAssetTransfers(params: AssetTransfersParams, callback?: Web3Callback<AssetTransfersResponse>): Promise<AssetTransfersResponse>;
    getNftMetadata(params: GetNftMetadataParams, callback?: Web3Callback<GetNftMetadataResponse>): Promise<GetNftMetadataResponse>;
    getNfts(params: GetNftsParamsWithoutMetadata, callback?: Web3Callback<GetNftsResponseWithoutMetadata>): Promise<GetNftsResponseWithoutMetadata>;
    getNfts(params: GetNftsParams, callback?: Web3Callback<GetNftsResponse>): Promise<GetNftsResponse>;
    getTransactionReceipts(params: TransactionReceiptsParams, callback?: Web3Callback<TransactionReceiptsResponse>): Promise<TransactionReceiptsResponse>;
}
/**
 * Same as Eth, but with `subscribe` allowing more types.
 */
export interface AlchemyEth extends Eth {
    subscribe(type: "logs", options?: LogsOptions, callback?: (error: Error, log: Log) => void): Subscription<Log>;
    subscribe(type: "syncing", callback?: (error: Error, result: Syncing) => void): Subscription<Syncing>;
    subscribe(type: "newBlockHeaders", callback?: (error: Error, blockHeader: BlockHeader) => void): Subscription<BlockHeader>;
    subscribe(type: "pendingTransactions", callback?: (error: Error, transactionHash: string) => void): Subscription<string>;
    subscribe(type: "alchemy_fullPendingTransactions", callback?: (error: Error, transaction: Transaction) => void): Subscription<Transaction>;
    subscribe(type: "alchemy_filteredFullPendingTransactions", options?: TransactionsOptions, callback?: (error: Error, transaction: Transaction) => void): Subscription<Transaction>;
    subscribe(type: "alchemy_pendingTransactions", options?: PendingTransactionsOptionsHashesOnly, callback?: (error: Error, transactionHash: string) => void): Subscription<string>;
    subscribe(type: "alchemy_pendingTransactions", options?: PendingTransactionsOptions, callback?: (error: Error, transaction: Transaction) => void): Subscription<Transaction>;
    subscribe(type: "pendingTransactions" | "logs" | "syncing" | "newBlockHeaders" | "alchemy_fullPendingTransactions" | "alchemy_filteredFullPendingTransactions" | "alchemy_pendingTransactions", options?: null | LogsOptions | TransactionsOptions, callback?: (error: Error, item: Log | Syncing | BlockHeader | string | Transaction) => void): Subscription<Log | BlockHeader | Syncing | string | Transaction>;
    getMaxPriorityFeePerGas(callback?: (error: Error, fee: string) => void): Promise<string>;
    sendPrivateTransaction(tx: string, maxBlockNumber?: string, preferences?: PrivateTransactionPreferences, callback?: (error: Error, hash: string) => void): Promise<string>;
    cancelPrivateTransaction(txHash: string, callback?: (error: Error, result: boolean) => void): Promise<boolean>;
}
export declare function createAlchemyWeb3(alchemyUrl: string, config?: AlchemyWeb3Config): AlchemyWeb3;
