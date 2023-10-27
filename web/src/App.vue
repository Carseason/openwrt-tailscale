<template>
    <div id="main">
        <!--  -->
        <h2>Tailscale</h2>
        <div class="cbi-map-descr">
            Tailscale 连接您的设备，以便轻松访问远程资源。<br>
            详情请查看 <a href="https://tailscale.com" target="_blank">tailscale</a>
        </div>
        <!--  -->
        <div class="cbi-section">
            <h3>服务状态</h3>
            <div class="cbi-section-node">
                <div class="cbi-value cbi-value-last">
                    <label class="cbi-value-title">启用</label>
                    <div class="cbi-value-field">
                        <div class="cbi-checkbox">
                            <input name="enabled" type="checkbox" :value="false" v-model="config.enabled">
                            <label></label>
                        </div>
                    </div>
                </div>
                <div class="cbi-value cbi-value-last">
                    <label class="cbi-value-title">服务状态</label>
                    <div class="cbi-value-field">
                        <a v-if="loading">加载中...</a>
                        <template v-else>
                            <a v-if="status?.BackendState" style="color:green"> {{ status?.BackendState }}</a>
                            <a v-else style="color:red">未运行</a>
                        </template>
                    </div>
                </div>
                <div class="cbi-value cbi-value-last" v-if="status?.Self?.ID">
                    <label class="cbi-value-title">当前节点</label>
                    <div class="cbi-value-field">
                        <a>
                            {{ status?.Self?.ID }}
                            <template v-if="status?.Self?.HostName">
                                （{{ status.Self.HostName }}）
                            </template>
                        </a>
                    </div>
                </div>
                <div class="cbi-value cbi-value-last" v-if="status?.AuthURL">
                    <label class="cbi-value-title">验证绑定</label>
                    <div class="cbi-value-field">
                        <a :href="status.AuthURL" target="_blank">{{ status.AuthURL }}</a>
                    </div>
                </div>
                <div class="cbi-value cbi-value-last" v-if="user?.DisplayName">
                    <label class="cbi-value-title">已绑定用户</label>
                    <div class="cbi-value-field">
                        <a href="https://login.tailscale.com/admin/machines/" target="_blank">{{ user.DisplayName }}</a>
                        <br />
                        <a @click="onLogout" style="color:green">注销登录并解除绑定</a>
                    </div>
                </div>
            </div>
        </div>
        <!--  -->
        <div class="cbi-section">
            <h3>全局设置</h3>
            <div class="cbi-section-node">
                <!--  -->
                <div class="cbi-value">
                    <label class="cbi-value-title">允许组网</label>
                    <div class="cbi-value-field">
                        <div class="cbi-checkbox">
                            <input name="acceptroutes" type="checkbox" :value="false" v-model="config.acceptRoutes">
                            <label></label>
                        </div>
                    </div>
                </div>
                <!--  -->
                <div class="cbi-value">
                    <label class="cbi-value-title">设备名称</label>
                    <div class="cbi-value-field">
                        <div>
                            <input type="text" class="cbi-input-text" name="hostname" v-model.trim="config.hostname"
                                placeholder="例如: iStoreOS">
                        </div>
                        <div class="cbi-value-description">
                            留空则使用设备的名称
                        </div>
                    </div>
                </div>
                <!--  -->
                <div class="cbi-value">
                    <label class="cbi-value-title">公开网段</label>
                    <div class="cbi-value-field">
                        <div>
                            <input type="text" class="cbi-input-text" name="advertiseroutes" placeholder="IP地址,多个使用,分开"
                                v-model.trim="config.advertiseRoutes">
                        </div>
                        <div class="cbi-value-description">
                            允许被访问的网段 <code>192.168.100.0/24</code>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!--  -->
        <div class="cbi-section">
            <h3>自定义服务器</h3>
            <div class="cbi-section-descr">
                使用
                <a href="https://github.com/juanfont/headscale" target="_blank">headscale</a>
                部署私有服务器
            </div>
            <div class="cbi-section-node">
                <!--  -->
                <div class="cbi-value">
                    <label class="cbi-value-title">服务器地址</label>
                    <div class="cbi-value-field">
                        <div>
                            <input type="text" class="cbi-input-text" name="loginserver" v-model.trim="config.loginServer"
                                placeholder="server 服务器地址,留空则不使用">
                        </div>
                    </div>
                </div>
                <!--  -->
                <div class="cbi-value">
                    <label class="cbi-value-title">令牌</label>
                    <div class="cbi-value-field">
                        <div>
                            <input type="password" class="cbi-input-password" name="authkey" v-model.trim="config.authkey"
                                placeholder="自定义令牌,留空则不使用">
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!--  -->
        <span class="cbi-page-actions control-group">
            <button class="btn cbi-button cbi-button-apply" @click="onSubmit" :disabled="disabled">保存并应用</button>
        </span>
    </div>
</template>
<script setup lang="ts">
import { ref } from 'vue';
const BASEURL = "/cgi-bin/luci/admin/services/tailscaler"
const loading = ref(true)
const disabled = ref(false)
const config = ref<ResponseConfig>({})
const status = ref<ResponseStatus>({})
const user = ref<ResponseStatusUser>({})
const userID = ref<number>()
const request = (input: string, init?: RequestInit | undefined) => {
    const uri = `${BASEURL}${input}`
    return fetch(uri, init)
}
const getStatus = async () => {
    try {
        const resp = await request("/status", {
            method: "GET"
        })
        const res = await resp.json() as ResponseStatus
        if (res) {
            status.value = res
            if (res.Self) {
                userID.value = res.Self.UserID
            }
            if (res?.User) {
                if (userID.value) {
                    const userid = userID.value
                    for (const key in res.User) {
                        if (Object.prototype.hasOwnProperty.call(res.User, key)) {
                            const element = res.User[key];
                            if (element.ID === userid) {
                                user.value = element
                                break
                            }
                        }
                    }
                }
                if (!user.value?.ID) {
                    for (const key in res.User) {
                        if (Object.prototype.hasOwnProperty.call(res.User, key)) {
                            const element = res.User[key];
                            if (element) {
                                user.value = element
                                break
                            }
                        }
                    }
                }
            } else {
                user.value = {}
            }
        } else {
            status.value = {}
        }
    } catch (error) {
        // 拿不到数据则认为程序没启动
        console.log(error);
        status.value = {}
        user.value = {}
    }
}
const getConfig = async () => {
    try {
        const resp = await request("/config", {
            method: "GET"
        })
        const res = await resp.json() as ResponseConfig
        if (res) {
            config.value = res
        }
    } catch (error) {
        console.log(error);
    }
}
const getData = async () => {
    try {
        await Promise.all([
            getConfig(),
            getStatus(),
        ])
    } catch (error) {
    } finally {
        loading.value = false
    }
}
const getInterval = async () => {
    setInterval(() => {
        getStatus()
    }, 5000)
}
getInterval()
getData()
const onSubmit = async () => {
    try {
        const resp = await request("/config", {
            method: "POST",
            headers: {
                'Content-Type': 'application/json;charset=utf-8'
            },
            body: JSON.stringify(config.value),
        })
        if (resp) {

        }
    } catch (error) {
        console.log(error);
    } finally {
        location.reload()
    }

}
const onLogout = async () => {
    if (!confirm("是否注销当前登录并且解绑当前设备？")) {
        return
    }
    try {
        const resp = await request("/logout", {
            method: "POST",
            headers: {
                'Content-Type': 'application/json;charset=utf-8'
            },
        })
        if (resp) {
        }
    } catch (error) {
        console.log(error);
    } finally {
        location.reload()
    }
}
</script>
<style lang="scss" scoped></style>