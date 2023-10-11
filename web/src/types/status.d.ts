export interface Root {
    Version: string
    BackendState: string
    AuthURL: string
    TailscaleIPs: string[]
    Self: Self
    Health: string[]
    MagicDNSSuffix: string
    CurrentTailnet: any
    CertDomains: any
    Peer: Peer
    User: any
}

export interface Self {
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

export interface Peer {
    "nodekey:7d135be80d0899f5e2d7c879762a8c4a8c8e1ef197deb1ef87c66454b83aed2b": Nodekey7d135be80d0899f5e2d7c879762a8c4a8c8e1ef197deb1ef87c66454b83aed2b
}

export interface ResponseStatus {
    ID: string
    PublicKey: string
    HostName: string
    DNSName: string
    OS: string
    UserID: number
    TailscaleIPs: any
    Addrs: any
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
