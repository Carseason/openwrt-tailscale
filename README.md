# openwrt-tailscale
github action build IPK

https://openwrt.org/docs/guide-user/services/vpn/tailscale/start 的调用
因为 tailscale 占用了 config/tailscale 和 init.d/tailscale , 故使用 luci-app-tailscaler 作为插件名称