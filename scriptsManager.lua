ScriptsManager = {}

local scriptsManagerWindow
local scriptsManagerPanel
local scriptsManagerButton
local scriptsManagerEvents = {}

function ScriptsManager.init()
  connect(g_game, { onGameStart = ScriptsManager.online,
					onGameEnd = ScriptsManager.offline})
					
  scriptsManagerButton = modules.client_topmenu.addLeftButton('scriptsManagerButton', 'Scripts Manager', 'scriptsManager.png', ScriptsManager.popupMenu)

  scriptsManagerWindow = g_ui.displayUI('scriptsManager.otui')
  scriptsManagerWindow:hide()

  scriptsManagerPanel = scriptsManagerWindow:getChildById('scriptsPanel')
  for id = 1, 20 do
  	local scriptBox = g_ui.createWidget('ScriptBox', scriptsManagerPanel)
  	scriptBox.scriptId = id
  	scriptBox:setId('script_' .. id)
  	scriptBox:getChildById('numberId'):setText('#'..id)
  	if id == 1 then
  		scriptBox:addAnchor(AnchorTop, 'parent', AnchorTop)
  	end
  end

  ScriptsManager.load()
end

function ScriptsManager.terminate()
	disconnect(g_game, { onGameStart = ScriptsManager.online,
						 onGameEnd = ScriptsManager.offline})
					   
	scriptsManagerButton:destroy()
	scriptsManagerButton = nil
	scriptsManagerWindow:destroy()
	scriptsManagerWindow = nil
	scriptsManagerPanel:destroy()
	scriptsManagerPanel = nil

	for i,v in pairs(scriptsManagerEvents) do
		removeEvent(v)
	end
	scriptsManagerEvents = {}
end

function ScriptsManager.popupMenu()
	local scriptsManagerPopup = g_ui.createWidget('PopupMenu')
	scriptsManagerPopup:addOption("Scripts Manager", function () ScriptsManager.show() end)

	scriptsManagerPopup:addSeparator()

	for i,v in pairs(scriptsManagerPanel:getChildren()) do
		if v.scriptId then
			local status = v:getChildById('statusCheck')
			local listas = v:getChildById('listasText'):getText()
			if listas ~= '' then
				scriptsManagerPopup:addOption(listas, function() status:setChecked(not status:isChecked()) end, status:isChecked() and 'On' or 'Off')
			end
		end
	end

	scriptsManagerPopup:display(g_window.getMousePosition())
end

function ScriptsManager.online()
  
end

function ScriptsManager.offline()  
  
end

function ScriptsManager.show()
	scriptsManagerWindow:show()
end

function ScriptsManager.hide()
	scriptsManagerWindow:hide()
end

function ScriptsManager.save()
	local patch = "/scriptsManager/default.otml"
	local file = g_configs.load(patch)
	
	if not file then
		file = g_configs.create(patch)
	end

	local obj = {}
	for i,v in pairs(scriptsManagerPanel:getChildren()) do
		if v.scriptId then
			obj[v.scriptId] = {listas = v:getChildById('listasText'):getText(), script = v:getChildById('scriptText'):getText()}
		end
	end
	file:setNode('scripts', obj)
	file:save()
end

function ScriptsManager.load()
	if not g_resources.directoryExists("/scriptsManager") then
		g_resources.makeDir("/scriptsManager")
	end
	local patch = "/scriptsManager/default.otml"
	local file = g_configs.load(patch)
	if file then
		local obj = file:getNode('scripts')
		if obj then			
			for i,v in pairs(scriptsManagerPanel:getChildren()) do
				if v.scriptId then
					local sObj = obj[tostring(v.scriptId)]
					if sObj then
						v:getChildById('listasText'):setText(sObj.listas)
						v:getChildById('scriptText'):setText(sObj.script)
					end
				end
			end
		end
	end
end

-- window handlers
function ScriptsManager.close()
	ScriptsManager.save()
	ScriptsManager.hide()
end

function ScriptsManager.scriptBoxSet(widget, option)	
	local id = widget:getParent().scriptId
	local listasWidget = scriptsManagerPanel:getChildById('script_' .. id):getChildById('listasText')
	local scriptWidget = scriptsManagerPanel:getChildById('script_' .. id):getChildById('scriptText')
	local listas = listasWidget:getText()
	local script = scriptWidget:getText()
	if option == true then
		if script ~= '' then
			local ret = loadstring("return " .. script)
			if type(ret) == "function" then
				scriptsManagerEvents[id] = ret()
			else
				displayErrorBox("Scripts Manager", "Error script #".. id .." could not be run.")
				option = false
			end

			if scriptsManagerEvents[id] == nil then
				option = false
			end
		else
			option = false
			displayErrorBox("Script Manager", "Error script #".. id .." is empty.")
		end
	else
		listasWidget:enable()
		scriptWidget:enable()
		if scriptsManagerEvents[id] then
			removeEvent(scriptsManagerEvents[id])
			scriptsManagerEvents[id] = nil
		end
	end

	widget:setChecked(option)
end