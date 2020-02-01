--[[
    大刀兵-302
	对应monsterid:1~100
]]
local DaDaoBing = class("DaDaoBing", function(params)
    local animal = Character:_create(params)
    return animal
end )

function DaDaoBing:create(params)
    return DaDaoBing.new(params)
end
function DaDaoBing:doAnimationEvent(event)

    local name = event.eventData.name
    local _animalName = self:getNowAniName()
    local _skillData = self:getSkillByAction(_animalName)
    local targets = self:getSelectedTargets(_animalName)

    if name == BATTLE_ANIMATION_EVENT.onAtk0Begin then
        --[[ 去除阴影 ]]
    else
        --[[ 对应技能的攻击次数+1 ]]
        targets = self:getHurtableTargets( { selectedTargets = targets, skill = _skillData })
        if targets ~= nil then
            self:doHurt( { skill = _skillData, targets = targets })

            --[[ 如果是大招，则需要单独处理一些事务，例如击退、震屏 ]]
            if name == BATTLE_ANIMATION_EVENT.onAtk1Done then
                --[[ 处理击退 ]]
                local winWidth = cc.Director:getInstance():getWinSize().width

                local count = self._attackcount[_skillData.skillid]
                for k, v in pairs(targets) do
                    if v:isAlive() == true and not v:isWorldBoss() and not v:isCannotBemoved() then
                        local x, y = v:getPosition()
                        v:setPosition(x +(0 - v:getScaleX()) * 1 / count * 50, y)
                    end
                end
            end
        else
            -- XTHDTOAST("没有攻击目标")
        end
        --[[ if end ]]

    end
end

return DaDaoBing
