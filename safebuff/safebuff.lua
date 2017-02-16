local cwAPI = require("cwapi");
local acutil = require('acutil');

local safeBuff = {};

-- ======================================================
--  Options
-- ======================================================

safeBuff.options = cwAPI.json.load('safebuff','safebuff',true);

if (not safeBuff.options) then 
    safeBuff.options = {};

    safeBuff.options.aspersionMaxPrice = 1200;
    safeBuff.options.blessingMaxPrice  = 1200;
    safeBuff.options.sacramentMaxPrice = 1200;

    safeBuff.options.aspersionClassId = 40201;
	safeBuff.options.blessingClassId  = 40203;
    safeBuff.options.sacramentClassId = 40205;
end

function UPDATE_BUFFSELLER_SLOT_TARGET_SAFEBUFF(ctrlSet, info)
	local skill_slot = GET_CHILD(ctrlSet, "skill_slot", "ui::CSlot");
	local sklObj = GetClassByType("Skill", info.classID);
	ctrlSet:SetUserValue("Type", info.classID);

	--local buycount = GET_CHILD(ctrlSet, "buycount");
	--buycount:SetMaxValue(info.remainCount);

	if (sklObj.ClassID == safeBuff.options.aspersionClassId) then
	    ctrlSet:GetChild("skillname"):SetTextByKey("value", sklObj.Name .. " - Safe Price:{#FF0000} " .. safeBuff.options.aspersionMaxPrice);
	elseif (sklObj.ClassID == safeBuff.options.blessingClassId) then
	    ctrlSet:GetChild("skillname"):SetTextByKey("value", sklObj.Name .. " - Safe Price:{#FF0000} " .. safeBuff.options.blessingMaxPrice);
	elseif (sklObj.ClassID == safeBuff.options.sacramentClassId) then
		ctrlSet:GetChild("skillname"):SetTextByKey("value", sklObj.Name .. " - Safe Price:{#FF0000} " .. safeBuff.options.sacramentMaxPrice);
	else
		ctrlSet:GetChild("skillname"):SetTextByKey("value", sklObj.Name);
	end

	ctrlSet:GetChild("skilllevel"):SetTextByKey("value", info.level);
	ctrlSet:GetChild("remaincount"):SetTextByKey("value", info.remainCount);
	ctrlSet:GetChild("price"):SetTextByKey("value", info.price);
	
	local btn =	ctrlSet:GetChild("btn");
	btn:SetEnable(0);

	SET_SLOT_SKILL_BY_LEVEL(skill_slot, info.classID, info.level);
end


function UPDATE_BUFFSELLER_SLOT_TARGET(ctrlSet, info)
	local skill_slot = GET_CHILD(ctrlSet, "skill_slot", "ui::CSlot");
	local sklObj = GetClassByType("Skill", info.classID);
	ctrlSet:SetUserValue("Type", info.classID);
	--local buycount = GET_CHILD(ctrlSet, "buycount");
	--buycount:SetMaxValue(info.remainCount);

	if (sklObj.ClassID == safeBuff.options.aspersionClassId) then
	    ctrlSet:GetChild("skillname"):SetTextByKey("value", sklObj.Name .. " - Safe Price:{#008000} " .. safeBuff.options.aspersionMaxPrice);
	elseif (sklObj.ClassID == safeBuff.options.blessingClassId) then
	    ctrlSet:GetChild("skillname"):SetTextByKey("value", sklObj.Name .. " - Safe Price:{#008000} " .. safeBuff.options.blessingMaxPrice);
	elseif (sklObj.ClassID == safeBuff.options.sacramentClassId) then
		ctrlSet:GetChild("skillname"):SetTextByKey("value", sklObj.Name .. " - Safe Price:{#008000} " .. safeBuff.options.sacramentMaxPrice);
	else
		ctrlSet:GetChild("skillname"):SetTextByKey("value", sklObj.Name);
	end

	ctrlSet:GetChild("skilllevel"):SetTextByKey("value", info.level);
	ctrlSet:GetChild("remaincount"):SetTextByKey("value", info.remainCount);
	ctrlSet:GetChild("price"):SetTextByKey("value", info.price);

	SET_SLOT_SKILL_BY_LEVEL(skill_slot, info.classID, info.level);
end

-- ======================================================
--  Everytime a buff window is open
-- ======================================================

function safeBuff.checkBuffShop(groupName, sellType, handle) 

    local frame = ui.GetFrame("buffseller_target");
    frame:ShowWindow(1);

    frame:SetUserValue("HANDLE", handle);
    frame:SetUserValue("GROUPNAME", groupName);
    frame:SetUserValue("SELLTYPE", sellType);
    local ctrlsetType = "buffseller_target";
    local ctrlsetUpdateFunc = UPDATE_BUFFSELLER_SLOT_TARGET;
    local ctrlsetUpdateFuncSafeBuff = UPDATE_BUFFSELLER_SLOT_TARGET_SAFEBUFF;

    local titleName = session.autoSeller.GetTitle(groupName);
    local gbox = frame:GetChild("gbox");
    gbox:RemoveAllChild();

    local cnt = session.autoSeller.GetCount(groupName);
    for i = 0 , cnt - 1 do

        local info = session.autoSeller.GetByIndex(groupName, i);
        local sklObj = GetClassByType("Skill", info.classID);
        local createSafeButton = false;

		if (sklObj.ClassID == safeBuff.options.aspersionClassId) then
		    if (info.price > safeBuff.options.aspersionMaxPrice) then
		    	createSafeButton = true;
		    end
		elseif (sklObj.ClassID == safeBuff.options.blessingClassId) then
		    if (info.price > safeBuff.options.blessingMaxPrice) then
		    	createSafeButton = true;
		    end
		elseif (sklObj.ClassID == safeBuff.options.sacramentClassId) then
		    if (info.price > safeBuff.options.sacramentMaxPrice) then
		    	createSafeButton = true;
		    end
		end

		if (createSafeButton) then
	        local ctrlSet = gbox:CreateControlSet(ctrlsetType, "CTRLSET_" .. i,  ui.CENTER_HORZ, ui.TOP, 0, 0, 0, 0);
	        ctrlsetUpdateFuncSafeBuff(ctrlSet, info);
	        ctrlSet:SetUserValue("TYPE", info.classID);
	        ctrlSet:SetUserValue("INDEX", i);
	    else
	        local ctrlSet = gbox:CreateControlSet(ctrlsetType, "CTRLSET_" .. i,  ui.CENTER_HORZ, ui.TOP, 0, 0, 0, 0);
	        ctrlsetUpdateFunc(ctrlSet, info);
	        ctrlSet:SetUserValue("TYPE", info.classID);
	        ctrlSet:SetUserValue("INDEX", i);
		end
    end

    GBOX_AUTO_ALIGN(gbox, 10, 10, 10, true, false);
    frame:ShowWindow(1);
    REGISTERR_LASTUIOPEN_POS(frame);
end

-- ======================================================
--	Commands
-- ======================================================

function safeBuff.checkCommand(words)
	local cmd = table.remove(words,1);
	local msgtitle = 'safeBuff{nl}'..'-----------{nl}';

	if (cmd == 'aspersion') then
		local value = table.remove(words,1);
		safeBuff.options.aspersionMaxPrice = tonumber(value);
		cwAPI.json.save(safeBuff.options,'safebuff');
		return ui.MsgBox(msgtitle.."Aspersion safe price set to "..value);
	end

	if (cmd == 'blessing') then
		local value = table.remove(words,1);
		safeBuff.options.blessingMaxPrice = tonumber(value);
		cwAPI.json.save(safeBuff.options,'safebuff');
		return ui.MsgBox(msgtitle.."Blessing safe price set to "..value);
	end

	if (cmd == 'sacrament') then
		local value = table.remove(words,1);
		safeBuff.options.sacramentMaxPrice = tonumber(value);
		cwAPI.json.save(safeBuff.options,'safebuff');
		return ui.MsgBox(msgtitle.."Sacrament safe price set to "..value);
	end

	if (not cmd) then
		local msgcmd = '';
		local msgcmd = msgcmd .. '/safebuff <aspersion or blessing or sacrament> <value> {nl}'..'Defines the safe price of buff.{nl}';
		CHAT_SYSTEM(msgtitle..msgcmd);
		return ui.MsgBox(msgtitle..msgcmd);
	end

	local msgerr = 'Command not valid.{nl}'..'Type "/safebuff" for help.';
	ui.MsgBox(msgtitle..msgerr);

end

-- ======================================================
--  LOADER
-- ======================================================
local isLoaded = false;

function SAFEBUFF_ON_INIT(addon, frame)
    if not isLoaded then
        -- checking dependences
        if (not cwAPI) then
            ui.SysMsg('[safeBuff] requires cwAPI to run.');
            return false;
        end

        cwAPI.events.on('TARGET_BUFF_AUTOSELL_LIST',safeBuff.checkBuffShop,1);
        acutil.slashCommand('/safebuff',safeBuff.checkCommand);

        cwAPI.json.save(safeBuff.options,'safebuff');
        isLoaded = true;
        cwAPI.util.log('[safeBuff] loaded!');
    end
end
