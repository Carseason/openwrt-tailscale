local http = require "luci.http"
module("luci.controller.tailscale", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/tailscale") then
        return
    end
	entry({"admin", "services", "tailscale"},	cbll("tailscale_template"), _("Tailscale"), 21).dependent = true
    entry({"admin", "services", "tailscale", "status"}, call("tailscale_status"))
	entry({"admin", "services", "tailscale", "config"}, call("tailscale_config"))
	entry({"admin", "services", "tailscale", "log"}, 	call("tailscale_log"))
end

function tailscale_template()
    luci.template.render("tailscale/main")
end

function tailscale_status()
	local sys  = require "luci.sys"
	local uci  = require "luci.model.uci".cursor()
	-- 是否在运行
	local running = (sys.call("pidof tailscale >/dev/null") == 0),
	local resp = {
		running = running,
	}
	luci.http.prepare_content("application/json")
	luci.http.write_json(resp)
end

function getTailscaleConfig()
    local uci  				= 	require "luci.model.uci".cursor()
    local enable   			= 	uci:get_first("tailscale", "tailscale", "enable")
    local acceptRoutes  	= 	uci:get_first("tailscale", "tailscale", "acceptRoutes")
    local hostname   		= 	uci:get_first("tailscale", "tailscale", "hostname")
    local advertiseRoutes   = 	uci:get_first("tailscale", "tailscale", "advertiseRoutes")
    local loginServer  		= 	uci:get_first("tailscale", "tailscale", "loginServer")
    local authkey   		= 	uci:get_first("tailscale", "tailscale", "authkey")
    local result 			= 	{
        enable    			= 	(enable == "1"),
		acceptRoutes 		= 	(acceptRoutes == "1"),
		advertiseRoutes		=	advertiseRoutes,
		hostname			=	hostname,
		loginServer			=	loginServer,
		authkey				=	authkey,
    }
    return result
end

function submitTailscaleConfig(req)
	local uci = require "luci.model.uci".cursor()
	-- enable
	if req.enabled ~= nil then
		uci:set("tailscale","@tailscale[0]","enabled",req.enabled)
	end
	-- login server url
	if req.loginServer ~= nil then
		uci:set("tailscale","@tailscale[0]","loginServer",req.loginServer)
	end
	-- authkey
	if req.authkey ~= nil then
		uci:set("tailscale","@tailscale[0]","authkey",req.authkey)
	end
	-- hostname
	if req.hostname ~= nil then
		uci:set("tailscale","@tailscale[0]","hostname",req.hostname)
	end
	-- acceptRoutes
	if req.acceptRoutes ~= nil then
		uci:set("tailscale","@tailscale[0]","acceptRoutes",req.acceptRoutes)
	end
	-- advertiseRoutes
	if req.acceptRoutes ~= nil then
		uci:set("tailscale","@tailscale[0]","advertiseRoutes",req.advertiseRoutes)
	end
	uci:commit("tailscale")  
end

function tailscale_config()
	local http = require "luci.http"
	http.prepare_content("application/json")
	local method = http.getenv("REQUEST_METHOD")
	if method == "post" or method == "POST" then
		local content = http.content()
		local jsonc = require "luci.jsonc"
		local json_parse = jsonc.parse
		local req = json_parse(content)
		if req == nil or next(req) == nil then
			luci.http.write_json({
				error =  "invalid request"
			})
			return 
		end
		submitTailscaleConfig(req)
	end
	local response = getTailscaleConfig()
    luci.http.write_json(response)
end

function tailscale_log()
	local http = require "luci.http" 
    local fs   = require "nixio.fs"
    local data = fs.readfile("/tmp/tailscaler.log")
    http.prepare_content("text/plain;charset=utf-8")
    http.write(data)
end