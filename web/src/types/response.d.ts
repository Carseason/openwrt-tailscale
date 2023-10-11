declare interface ResponseRunning {
    running?: boolean
}
declare interface ResponseConfig {
    enabled?: boolean
    acceptRoutes?: boolean
    hostname?: string
    advertiseRoutes?: string
    loginServer?: string
    authkey?: string
}

// 
declare interface ResponseStatus {
    Version?: string
    BackendState?: string
    AuthURL?: string
    TailscaleIPs?: string[]
    Self?: ResponseStatusSelf
    Health?: string[]
    MagicDNSSuffix?: string
}

declare interface ResponseStatusSelf {
    ID: string
    PublicKey: string
    HostName: string
    DNSName: string
    OS: string
    UserID: number
    TailscaleIPs: string[]
    Addrs: string[]
    CurAddr: string
    Relay: string
    RxBytes: number
    TxBytes: number
    Created: string
    LastWrite: string
    LastSeen: string
    LastHandshake: string
    Online: boolean
    KeepAlive: boolean
    ExitNode: boolean
    ExitNodeOption: boolean
    Active: boolean
    PeerAPIURL: any
    InNetworkMap: boolean
    InMagicSock: boolean
    InEngine: boolean
}



