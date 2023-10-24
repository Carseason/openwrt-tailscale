local http = require "luci.http"
module("luci.controller.tailscaler", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/tailscaler") then
        return
    end
	entry({"admin", "services", "tailscaler"},				call("tailscale_template"), _("Tailscale"), 21).dependent = true
	entry({"admin", "services", "tailscaler", "config"}, 	call("tailscale_config"))
	entry({"admin", "services", "tailscaler", "status"}, 	call("tailscale_status"))
	entry({"admin", "services", "tailscaler", "logout"}, 	call("tailscale_logout"))
end

function tailscale_template()
    luci.template.render("tailscaler/main")
end


function getTailscaleConfig()
    local uci  				= 	require "luci.model.uci".cursor()
    local enabled   		= 	uci:get_first("tailscaler", "settings", "enabled")
    local acceptRoutes  	= 	uci:get_first("tailscaler", "settings", "acceptRoutes")
    local hostname   		= 	uci:get_first("tailscaler", "settings", "hostname")
    local advertiseRoutes   = 	uci:get_first("tailscaler", "settings", "advertiseRoutes")
    local loginServer  		= 	uci:get_first("tailscaler", "settings", "loginServer")
    local authkey   		= 	uci:get_first("tailscaler", "settings", "authkey")
    local result 			= 	{
        enabled    			= 	(enabled == "1"),
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
	-- enabled
	if req.enabled ~= nil then
		uci:set("tailscaler","@settings[0]","enabled",req.enabled)
	end
	-- login server url
	if req.loginServer ~= nil then
		uci:set("tailscaler","@settings[0]","loginServer",req.loginServer)
	end
	-- authkey
	if req.authkey ~= nil then
		uci:set("tailscaler","@settings[0]","authkey",req.authkey)
	end
	-- hostname
	if req.hostname ~= nil then
		uci:set("tailscaler","@settings[0]","hostname",req.hostname)
	end
	-- acceptRoutes
	if req.acceptRoutes ~= nil then
		uci:set("tailscaler","@settings[0]","acceptRoutes",req.acceptRoutes)
	end
	-- advertiseRoutes
	if req.acceptRoutes ~= nil then
		uci:set("tailscaler","@settings[0]","advertiseRoutes",req.advertiseRoutes)
	end
	uci:commit("tailscaler")  
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
		if req.enabled == true then
			luci.util.exec("/etc/init.d/tailscaler start")
		else
			luci.util.exec("/etc/init.d/tailscaler stop")
		end
	end
	local response = getTailscaleConfig()
    luci.http.write_json(response)
end

function tailscale_status()
	local sys  = require "luci.sys"
	local http = require "luci.http" 
    -- http.prepare_content("text/plain;charset=utf-8")
	http.prepare_content("application/json")
	local text = sys.exec("tailscale status --json")
    http.write(text)
end

function tailscale_logout()
	local sys  = require "luci.sys"
	local http = require "luci.http" 
	http.prepare_content("application/json")
	local text = sys.exec("tailscale logout")
    http.write(text)
end