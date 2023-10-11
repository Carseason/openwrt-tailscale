<template>
    <div id="main">
        <!--  -->
        <h2>Tailscale</h2>
        <div class="cbi-map-descr">
            Tailscale 连接您的设备，以便轻松访问远程资源。<br>
            详情请查看 <a href="https://config.com/" target="_blank">tailscale</a>
        </div>
        <!--  -->
        <div class="cbi-section">
            <h3>服务状态</h3>
            <div class="cbi-section-node">
                <div class="cbi-value cbi-value-last">
                    <label class="cbi-value-title">服务状态</label>
                    <div class="cbi-value-field">
                        <a v-if="running === undefined">加载中...</a>
                        <a v-else-if="running" style="color:green"> 运行中</a>
                        <a v-else style="color:red">未运行</a>
                    </div>
                </div>
                <div class="cbi-value cbi-value-last" v-if="status.AuthURL">
                    <label class="cbi-value-title">验证链接</label>
                    <div class="cbi-value-field">
                        <a :="status.AuthURL" target="_blank">{{ status.AuthURL }}</a>
                    </div>
                </div>
                <div class="cbi-value cbi-value-last">
                    <label class="cbi-value-title">启用</label>
                    <div class="cbi-value-field">
                        <div class="cbi-checkbox">
                            <input name="enabled" type="checkbox" :value="false" v-model="config.enabled">
                            <label></label>
                        </div>
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
            <button class="btn cbi-button cbi-button-apply" @click="onSubmit">保存并应用</button>
        </span>
    </div>
</template>
<script setup lang="ts">
import { ref } from 'vue';
const BASEURL = "/cgi-bin/luci/admin/services/tailscaler"
const running = ref<boolean | undefined>(undefined)
const config = ref<ResponseConfig>({})
const status = ref<ResponseStatus>({})
const getRunning = async () => {
    try {
        const resp = await fetch(`${BASEURL}/running`, {
            method: "GET"
        })
        const res = await resp.json() as ResponseRunning
        if (res) {
            running.value = res.running || false
        }
    } catch (error) {
        console.log(error);
    }
}
const getStatus = async () => {
    try {
        const resp = await fetch(`${BASEURL}/status`, {
            method: "GET"
        })
        const res = await resp.json() as ResponseStatus
        if (res) {
            status.value = res
        }
    } catch (error) {
        console.log(error);
    }
}
const getConfig = async () => {
    try {
        const resp = await fetch(`${BASEURL}/config`, {
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
    setTimeout(() => {
        getRunning()
        getStatus()
    }, 5000)
    try {
        await Promise.all([
            getRunning(),
            getConfig(),
            getStatus(),
        ])
    } catch (error) {
    } finally {
    }
}
getData()
const onSubmit = async () => {
    try {
        const resp = await fetch(`${BASEURL}/config`, {
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
    }

}
</script>
<style lang="scss" scoped></style>