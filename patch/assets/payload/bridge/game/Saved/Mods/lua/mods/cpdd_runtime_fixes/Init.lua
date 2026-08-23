local Loader = assert(LOMModLoader, "LOMModLoader is required")

local VERSION = "1.0.1"
local STATIC_AUDIT_ID = "build-2044036-all-modules-20260823-release"
local CIRCUIT_BREAKER_TIPS_ID = 6427242
local CIRCUIT_BREAKER_TEXT = "If the server is too crowded, it will enter a circuit-breaker state, temporarily preventing new accounts that have not created a character on the current server from queuing. Please choose another server that is not under a circuit-breaker to experience the game."

local aggregateOverrides = {
    [74905303409152] = "Explore",
    [466331174441472] = "Archive",
    [501378376016640] = "Style",
    [514572247120128] = "Puppets",
    [527972545072640] = "Story",
    [625210604657664] = "Contacts",
    [712484608544768] = "Easy Win",
    [774126247610880] = "Gear",
    [774126784481024] = "Artifacts",
    [866415967995648] = "Warfront",
    [866622663296512] = "Dark City",
    [884214580905472] = "Advance",
    [933074128867328] = "Arts",
    [989630258218752] = "Talents",
    [1020416583796224] = "Skip",
    [1020416583796480] = "Review",
    [936784443737600] = "Beyonder Rating",
    [936990870604032] = "Reward Preview",
    [1271036247030528] = "Claimed",
    [620129389936640] = "Use",
    [1073124154021632] = "Auto-Dismantle Settings",
    [1073124154089984] = "In Use",
    [1073124154205952] = "My Builds",
    [1073124154228480] = "Auto-Dismantle Confirmation",
    [1073124154229760] = "Official Recommended Build",
    [1271036247052800] = "Recommended Builds",
    [1271036247235584] = "Equipment Builds",
    [211107843337216] = "The sealing chains of the \"Door\" domain coil around your heart to ward off fatal damage. A single hit cannot reduce your HP by more than 25% of Max HP.",
    [211107843655936] = [=[When a class combat skill enters cooldown, the cooldown is immediately refunded. If it is a charged skill, all charge counts are refunded. Each individual skill can trigger this refund at most once. {CheckStar(Type="sealed",ID=2085021)=1?The refunded skill deals <Yellow>*f**</> less damage and healing.}{CheckStar(Type="sealed",ID=2085021)=3?The refunded skill additionally gains <Yellow>*f**</> damage and healing.}]=],
    [211107844315392] = "Miss Justice witnessed your fall and watched you rise again. A will that has been seen will not be easily extinguished. Damage taken is reduced by 30%, and damage dealt is increased by 40%.",
    [286012073289984] = "\"The pure-white one sleeping within the crimson cocoon, the divine child who governs rebirth and corruption, the final possibility at the end of days.\"",
    [286012610526208] = "\"Woof, woof!\"",
    [1240251532052225] = "Mr. Fool has grafted onto you a destiny from the future, allowing you to wield the power of higher Sequences. As your strength grows, the variety and power of the skills you learn will continue to increase. Skills are divided into three categories: Combat Skills, Special Skills, and Acting Skills. You can equip up to four Combat Skills or Acting Skills at the same time. Special Skills do not need to be equipped and include Basic Attack, Crowd-Control Break, and Finisher Skills.",
}

local splitOverrides = {
    buffappear = {
        [1253512780450048] = "Fear",
    },
    buffdata = {
        [1253512780450048] = "Fear",
    },
    debug = {
        [1169950433818880] = "Enter the Dream",
    },
    monsterskill = {
        [1271036247082752] = "Projection",
    },
    skill = {
        [1240389776443904] = "Purifying Slash",
    },
    skill1 = {
        [1240389776521984] = "Star Strike",
    },
    skill2 = {
        [611398258279936] = "Beacon of History",
    },
    skill3 = {
        [998771022409216] = "Nebula Slash",
    },
    spellfield = {
        [1068726107518720] = "Tip",
    },
}

local stringConstOverrides = {
    BAG_AUTO_AUTO_RESOLVE_TITLE = "Auto-Dismantle Confirmation",
    BAG_AUTO_DECOMPOSE_TITLE = "Auto-Dismantle Settings",
    DIALOGUE_SKIP = "Skip",
    EQUIPMENT_PLAN_APPLY_CURRENT_PLAN = "Apply Build",
    FASHION_APPEARANCE = "Appearance",
    FASHION_DYE_MY_PLAN = "My Builds",
    GUILD_CARGO_HUB_REWARD_COMPLETE = "Claimed",
    GVG_HONOR_CLAIMED_TEXT = "Claimed",
    ITEM_GOT = "Claimed",
    MONTH_CARD_MAIN_PAGE_TODAY_RECEIVED_LABEL = "(Claimed Today)",
    FAMILY_INVITE_SHARE_TEAM = "Party Channel",
    FAMILY_INVITE_SHARE_WORLD = "World Channel",
    FAMILY_MEMBER_COUNT_FMT = "Current Family Members: %s/14",
    FAMILY_MEMBER_FMT = "Family Members (%d/%d)",
    ONE_CLICK_IN_USE = "In Use",
    ONE_CLICK_RECOMMEND_PLAN = "Official Recommended Build",
    ONE_CLICK_SHARE_RECOMMEND_PLAN = "Recommended Builds",
    ONE_CLICK_TITLE = "One-Click Assist",
    ONE_CLICK_USE = "Use",
    MAP_PVP_LAST_HUNT_DRAGON_BOSS_BELONG_FORMAT = "<Green>%s</> Team Affiliation",
    MAP_PVP_LAST_HUNT_DRAGON_BOSS_NAME = "Dragon Projection",
    MAP_PVP_LAST_HUNT_DRAGON_BOSS_NOT_BELONG_FORMAT = "<Red>%s</> Team Affiliation",
    PVP_LAST_HUNT_ACTIVE_TIME_FORMAT = "Activating %M:%S",
    PVP_LAST_HUNT_ACTIVITY_NOT_OPEN_TEXT = "Use <Highlight>Seed of Sighs</> to activate Power of Sighs, start the Sighs Quest, and complete it to receive rich rewards.",
    PVP_LAST_HUNT_ACTIVITY_OPEN_FORMAT = "Starts in %H hours %M minutes",
    PVP_LAST_HUNT_ACTIVITY_OPEN_TEXT = "Event Start Time",
    PVP_LAST_HUNT_ACTIVITY_REWARD_PREVIEW_FORMAT = "Quest Rewards",
    PVP_LAST_HUNT_BOSS_BUTTON_DESC = "Go",
    PVP_LAST_HUNT_BOSS_CONTENT_DESC = "Royal City Dragon Description Placeholder",
    PVP_LAST_HUNT_BOSS_DETAIL_CONDITION_TITLE = "Refresh Status",
    PVP_LAST_HUNT_BOSS_DETAIL_CONTENT = "Defeat elite monsters to earn abundant rewards",
    PVP_LAST_HUNT_BOSS_DETAIL_NOT_SPAWNED = "Target has not appeared yet",
    PVP_LAST_HUNT_BOSS_DETAIL_SPAWNED = "Target has appeared",
    PVP_LAST_HUNT_BOSS_DETAIL_TITLE = "Hunt Target",
    PVP_LAST_HUNT_BOSS_DRAGON_FORMAT = "Dragon appears in %M:%S",
    PVP_LAST_HUNT_BOSS_SECOND_TITLE = "Defeat the Royal City Dragon",
    PVP_LAST_HUNT_BOSS_TAG_NAME = "Royal City Guardian",
    PVP_LAST_HUNT_BOSS_TITLE = "Slay the Dragon",
    PVP_LAST_HUNT_CAMP_SUBMIT_FORMAT = "%s Submission Point",
    PVP_LAST_HUNT_CHAT_BUTTON_TEXT = "Go",
    PVP_LAST_HUNT_CHAT_TITLE = "Horn",
    PVP_LAST_HUNT_CROSS_SERVER_SCORE_TITLE = "Military Merit",
    PVP_LAST_HUNT_DETAIL_MY_DATA_TAB = "My Data",
    PVP_LAST_HUNT_DETAIL_RANK_TAB = "Ranking",
    PVP_LAST_HUNT_FIGHT_ASSISTANT_FORMAT = "%s was defeated by %s at %s. Support needed!",
    PVP_LAST_HUNT_FIGHT_KILL_RESULT_FORMAT = "%s successfully hunted %s at %s!",
    PVP_LAST_HUNT_GUILD_ACTIVITY_DESC_TIPS = "Final Hunt Dragon Raid <Highlight>[Team Auction]</>: %d/%d (this Friday) at 19:10",
    PVP_LAST_HUNT_GUILD_NAME_FORMAT = "<Enemy_Name>%s</> Club",
    PVP_LAST_HUNT_HIGHER_DETAIL_CONTENT = "Advanced quest area containing many out-of-control monsters",
    PVP_LAST_HUNT_HIGHER_DETAIL_NOT_OPENED_TITLE = "Currently Closed",
    PVP_LAST_HUNT_HIGHER_DETAIL_OPENED_TIME = "Open daily: 19:00-21:00\nAdditional hours: Saturday and Sunday, 14:00-16:00",
    PVP_LAST_HUNT_HIGHER_DETAIL_TITLE_NAME = "Advanced · Tide",
    PVP_LAST_HUNT_HUD_PROGRESS_CURRENCY_FORMAT = "<Highlight>%s</>/%s",
    PVP_LAST_HUNT_HUD_PROGRESS_FORMAT = "<Highlight>%d</>/%d",
    PVP_LAST_HUNT_ITEM_CAN_NOT_USE = "Insufficient Quantity",
    PVP_LAST_HUNT_LACK_USE_ITEM_PROP_COUNT_FORMAT = "Attempts Remaining: %s",
    PVP_LAST_HUNT_MAIN_PROGRESS_TITLE = "Reward Preview",
    PVP_LAST_HUNT_MAP_DETAIL_DESC = "Faction-area teleport entrance",
    PVP_LAST_HUNT_MAP_ITEM_NAME = "Seed of Sighs · Monster Tide Area",
    PVP_LAST_HUNT_MEMBER_COUNT_FORMAT = "(Party Members: %d/%d)",
    PVP_LAST_HUNT_MONSTER_CANCEL_BUTTON_NAME = "Cancel",
    PVP_LAST_HUNT_MONSTER_DROP_REWARD_TEXT = "Chance to drop from defeated <HyperLink stylename=\"Clickable\" u=\"\">minor monsters</>",
    PVP_LAST_HUNT_MONSTER_DROP_REWARD_UNDERLINE_TEXT = "Chance to drop from defeated <HyperLink stylename=\"Underline\" u=\"\">minor monsters</>",
    PVP_LAST_HUNT_MONSTER_RECOMMEND_GROUP = "Group Recommended",
    PVP_LAST_HUNT_MONSTER_RECOMMEND_TEAM = "Party Recommended",
    PVP_LAST_HUNT_MONSTER_SUMMON_BUTTON_NAME = "Go to Summon",
    PVP_LAST_HUNT_MONSTER_SUMMON_LEFT_COUNT_FORMAT = "Summons remaining this week: %d",
    PVP_LAST_HUNT_NOT_OPENED_BUTTON_TEXT = "Available when the event begins",
    PVP_LAST_HUNT_RANK_TAB_GUILD_NAME = "Club",
    PVP_LAST_HUNT_RANK_TAB_PERSONAL_NAME = "Personal",
    PVP_LAST_HUNT_RESURGENCE_TIPS = "Select a respawn point, then click Go",
    PVP_LAST_HUNT_RESURGENCE_TITLE = "Select Respawn Point",
    PVP_LAST_HUNT_REVIVE_BUTTON_NAME = "Go to Respawn",
    PVP_LAST_HUNT_REWARD_PREVIEW_TITLE = "Quest Reward Preview",
    PVP_LAST_HUNT_SCORE_TITLE = "Rank Points",
    PVP_LAST_HUNT_SEND_BUTTON_TITLE = "Send Horn",
    PVP_LAST_HUNT_SEND_CHAT_DEFAULT_TEXT = "Brothers, come help me",
    PVP_LAST_HUNT_SEND_DEFAULT_TIP_TEXT = "Summon up to %d players",
    PVP_LAST_HUNT_SEND_PANEL_TIPS = "Summon up to 14 players",
    PVP_LAST_HUNT_SEND_PANEL_TITLE = "Send Horn",
    PVP_LAST_HUNT_SETTLE_MENT_ASSIST_NUM_TITLE = "Assists",
    PVP_LAST_HUNT_SETTLE_MENT_CANCEL = "Cancel",
    PVP_LAST_HUNT_SETTLE_MENT_KILL_NUM_TITLE = "Kills",
    PVP_LAST_HUNT_SETTLE_MENT_LEAVE = "Teleport Away",
    PVP_LAST_HUNT_SETTLE_MENT_PROGRESS_NUM_TITLE = "Hunt Settlement",
    PVP_LAST_HUNT_SETTLE_MENT_SCORE_NUM_TITLE = "Rank Points",
    PVP_LAST_HUNT_SETTLE_MENT_TITLE = "Hunt Settlement",
    PVP_LAST_HUNT_SUBMIT_CONTENT = "Submit Scarlet Relic materials in exchange for Hunt Vouchers",
    PVP_LAST_HUNT_SUBMIT_REFRESH_DESC = "The Hunting Butler changes position on the map every 30 minutes. More Butlers appear when combat is intense.",
    PVP_LAST_HUNT_SUBMIT_REFRESH_TITLE = "Refresh Rules",
    PVP_LAST_HUNT_SUBMIT_TITLE = "Hunting Butler",
    PVP_LAST_HUNT_SUMMON_AUTHOER_FORMAT = "(Summoned by: %s)",
    PVP_LAST_HUNT_SUMMON_MONSTER_GET_NUM = "Attempts Obtained",
    PVP_LAST_HUNT_SUMMON_MONSTER_LACK_NUM = "No attempts remain this week. Earn Hunt Vouchers to obtain more.",
    PVP_LAST_HUNT_TASK_BUFF_NAME = "Power of Sighs",
    PVP_LAST_HUNT_TASK_COMMIT_TEXT = "Go to Submit",
    PVP_LAST_HUNT_TASK_FINISH_TITLE_TEXT = "Ended",
    PVP_LAST_HUNT_TASK_FRAGMENT_NAME = "Prey Fragment",
    PVP_LAST_HUNT_TASK_NOT_ACTIVE_CONTENT_TEXT = "Use a Seed of Sighs, defeat monsters or plunder players to obtain Prey Fragments, then submit them to the Earl of Order for rewards.",
    PVP_LAST_HUNT_TASK_NOT_ACTIVE_FINISH_TEXT = "The quest has ended. Find the Earl of Order to submit your fragments for rewards.",
    PVP_LAST_HUNT_TASK_NOT_ACTIVE_TEXT = "Inactive",
    PVP_LAST_HUNT_TASK_PROGRESS_TEXT = "Hunt Progress",
    PVP_LAST_HUNT_TASK_PROP_TEXT = "Seed of Sighs",
    PVP_LAST_HUNT_TASK_QUICK_TEAM = "Quick Party",
    PVP_LAST_HUNT_TASK_TITLE_NAME = "Final Hunt",
    PVP_LAST_HUNT_TITLE_DETAIL_NAME = "Details",
    PVP_LAST_HUNT_TITLE_FOLD_NAME = "Collapse",
    PVP_LAST_HUNT_USE_ITEM_NOT_ACTIVITY_OPEN_FORMAT = "Cannot be used outside event hours. Event time: <highlight>%s-%s</>",
    PVP_LAST_HUNT_USE_ITEM_PROP_DESC = "Using Seed of Sighs...",
    PVP_LAST_HUNT_USE_TASK_TEXT_NAME = "Go to Accept Quest",
    RED_PACKET_ALREADY_RECEIVED = "Claimed",
    SECRET_PARTNER_BTN_ALREADY_CHANGE_ACTOR_NAME = "Shifting",
    SECRET_PARTNER_BTN_CHANGE_ACTOR_NAME = "Shift",
    SECRET_PARTNER_CANCEL_CHANGE_ACTOR = "Cancel Shift",
    SECRET_PARTNER_CHANGE_ACTOR_TITLE = "Shift Target",
    SECRET_PARTNER_SKILL_TEXT = "Marionette Skill",
    SECRET_PARTNER_STAR_UP_TEXT_FORMAT = "Sequence %d",
    SKILL_PRESET_TAB_1 = "Recommended Builds",
    TASK_TRACE_DISTANCE = "m",
    TRINITY_ALL_TREASURE_HAVE_CLAIMED = "All Rewards Claimed",
    TEAM_INVITE_SECRET_PARTNER_TITLE = "Illusion Application",
    UIAPPEARANCE_USE = "Use",
    UIAPPEARANCE_USING = "In Use",
}
local visibleTextExactOverrides = {
    ["跳过"] = "Skip",
    ["回顾"] = "Review",
    ["截图"] = "Screenshot",
    ["点击空白区域关闭"] = "Click blank area to close",
    ["男子"] = "Man",
    ["丑人"] = "Ugly Man",
    ["愚者"] = "The Fool",
    ["“愚者”"] = "\"The Fool\"",
    ["塞巴斯蒂安"] = "Sebastian",
    ["寒巴斯蒂安"] = "Sebastian",
    ["非凡评分"] = "Beyonder Rating",
    ["推荐非凡评分"] = "Recommended Beyonder Rating",
    ["奖励预览"] = "Reward Preview",
    ["目标点数"] = "Target Score",
    ["黎明降临"] = "Dawn Arrival",
    ["仲裁烙印"] = "Arbitration Brand",
    ["窥秘凝视"] = "Mystery Pry Gaze",
    ["晨曦守护"] = "Morning Light Protection",
    ["骑士誓约"] = "Knight's Oath",
    ["蝶灵附身"] = "Butterfly Spirit Possession",
    ["丧钟回响"] = "Death Knell Echo",
    ["头狼连爪"] = "Alpha Wolf Claw Combo",
    ["钻头守护"] = "Drill Protection",
    ["未拥有"] = "Not Owned",
    ["推荐方案"] = "Recommended Builds",
    ["官方推荐方案"] = "Official Recommended Build",
    ["我的方案"] = "My Builds",
    ["我要变强"] = "Improve",
    ["要变强"] = "Improve",
    ["已领取"] = "Claimed",
    ["今日已领取"] = "Claimed Today",
    ["奖励已领取"] = "Reward Claimed",
    ["已领取全部奖励"] = "All Rewards Claimed",
    ["使用"] = "Use",
    ["使用中"] = "In Use",
    ["全部重置"] = "Reset All",
    ["装备方案"] = "Equipment Builds",
    ["自动分解"] = "Auto-Dismantle",
    ["获得方式"] = "How to Obtain",
    ["下一级效果"] = "Next-Level Effect",
    ["在目标位置召唤窥秘之眼，对目标造成持续伤害和减速。"] =
        "Summon an Eye of Mystery at the target location, dealing continuous damage and slowing the target.",
    ["感知灵界，观测星空，通过灵性物品启示的命运变化，解读其映射的现实空间异动、事态发展走向与潜在未知危险。"] =
        "Sense the spirit world and observe the stars. Interpret the changes in fate revealed by spiritual items to discern the real-world disturbances they reflect, how events may unfold, and potential unknown dangers.",
    ["占星启示期间，周围的玩家可以获得临时技能来获取占星指引。"] =
        "During Astrological Revelation, nearby players can gain a temporary skill to receive astrological guidance.",
    ["使自身获得武力加4，直觉加2。使用临时技能获取占星指引的玩家也可以获得武力加4，直觉加2。"] =
        "Gain +4 Might and +2 Intuition. Players who use the temporary skill to receive astrological guidance also gain +4 Might and +2 Intuition.",
    ["木桩训练"] = "Training Dummy",
    ["一键辅助"] = "One-Click Assist",
    ["成员列表"] = "Member List",
    ["俱乐部会长"] = "Club President",
    ["正式成员"] = "Full Member",
    ["候补成员"] = "Reserve Member",
    ["可预存"] = "Can Pre-store",
    ["已预存"] = "Pre-stored",
    ["新手"] = "Beginner",
    ["赛季剧情"] = "Season Story",
    ["提交可获得猎杀进度"] = "Submit to earn Hunt Progress",
    ["可获得猎杀进度"] = "Earn Hunt Progress",
    ["当前进度："] = "Current Progress:",
    ["当前进度:"] = "Current Progress:",
    ["击杀"] = "Kills",
    ["助攻"] = "Assists",
    ["排行榜"] = "Leaderboard",
    ["男子：（癫狂）万物的“母亲”，赐予我们新生！"] =
        "Man: (Manically) \"Mother\" of all things, grant us rebirth!",
    ["“愚者”：拿上这个。"] = "\"The Fool\": Take this.",
    ["丑人：（有效期十四年？为什么要签这么久的合同……）"] =
        "Ugly Man: (Valid for fourteen years? Why would I need to sign such a long contract...)",
}
do
    local ok, loaded = pcall(require, "mods.cpdd_runtime_fixes.RuntimeTextCurated")
    if ok and type(loaded) == "table" then
        for source, translation in pairs(loaded) do
            visibleTextExactOverrides[source] = translation
        end
    end
end
do
    local ok, loaded = pcall(require, "mods.cpdd_runtime_fixes.RuntimeQualityFixes")
    if ok and type(loaded) == "table" then
        for source, translation in pairs(loaded) do
            visibleTextExactOverrides[source] = translation
        end
    end
end

do
    local ok, loaded = pcall(require, "mods.cpdd_runtime_fixes.RuntimeFullLiterals")
    if ok and type(loaded) == "table" then
        for source, translation in pairs(loaded) do
            visibleTextExactOverrides[source] = translation
        end
    else
        report("full literal translation map unavailable: " .. tostring(loaded))
    end
end
local curatedIdOverrides = { Aggregate = {}, Split = {} }
do
    local ok, loaded = pcall(require, "mods.cpdd_runtime_fixes.RuntimeIdCurated")
    if ok and type(loaded) == "table" then
        curatedIdOverrides = loaded
    end
end

local curatedContextOverrides = {}
do
    local ok, loaded = pcall(require, "mods.cpdd_runtime_fixes.RuntimeContextCurated")
    if ok and type(loaded) == "table" then
        curatedContextOverrides = loaded
    end
end

local visibleTextReplacements = {
    { "点击空白区域关闭", "Click blank area to close" },
    { "跳过", "Skip" },
    { "推荐非凡评分", "Recommended Beyonder Rating" },
    { "非凡评分", "Beyonder Rating" },
    { "塞巴斯蒂安", "Sebastian" },
    { "寒巴斯蒂安", "Sebastian" },
    { "男子：", "Man: " },
    { "丑人：", "Ugly Man: " },
    { "“愚者”：", "\"The Fool\": " },
    { "愚者", "The Fool" },
    { "（癫狂）", "(Manically) " },
    { "万物的“母亲”", "\"Mother\" of all things" },
    { "赐予我们新生", "grant us rebirth" },
    { "拿上这个", "Take this" },
    { "有效期十四年？为什么要签这么久的合同……", "Valid for fourteen years? Why would I need to sign such a long contract..." },
    {
        "感知灵界，观测星空，通过灵性物品启示的命运变化，解读其映射的现实空间异动、事态发展走向与潜在未知危险。",
        "Sense the spirit world and observe the stars. Interpret the changes in fate revealed by spiritual items to discern the real-world disturbances they reflect, how events may unfold, and potential unknown dangers.",
    },
    {
        "占星启示期间，周围的玩家可以获得临时技能来获取占星指引。",
        "During Astrological Revelation, nearby players can gain a temporary skill to receive astrological guidance.",
    },
    {
        "使自身获得武力加4，直觉加2。使用临时技能获取占星指引的玩家也可以获得武力加4，直觉加2。",
        "Gain +4 Might and +2 Intuition. Players who use the temporary skill to receive astrological guidance also gain +4 Might and +2 Intuition.",
    },
}
local marionetteSkillLocalization = {
    [87303001] = { 286217962784256, 286218768090624, 286218231219712, 514572247120128 },
    [87303002] = { 286217962784512, 286218768090880, 286218231219968, 514572247120128 },
    [87303003] = { 286217962784256, 286218768090624, nil, 514572247120128 },
    [87303004] = { 286217962785024, 286218768091392, 286218231220480, 286219304962304 },
    [87303010] = { 286217962786048, 286218768092416, 286218231221504, 286219304963328 },
    [87303020] = { 286217962786560, 286218768092928, 286218231222016, 286219304963840 },
    [87303030] = { 286217962787840, 286218768094208, 286218231223296, 286219304965120 },
    [87303040] = { 286217962791168, 286218768097536, 286218231226624, 1240250726755840 },
    [87303050] = { 998771022366208, 286218768099840, 286218231228928, 286219304970752 },
    [87303060] = { 286217962794240, 286218768100608, 286218231229696, 286219304971520 },
    [87303070] = { 286217962795264, 286218768101632, 286218231230720, 514572247120128 },
    [87303071] = { 286217962795776 },
    [87303072] = { 286217962796032 },
    [87303080] = { 286217962796288, 286218768102656, 286218231231744, 286219304965120 },
    [87303090] = { 286217962797824, 286218768104192, 286218231233280, 286219304975104 },
    [87303100] = { 286217962798848, 286218231234304, 286218231234304, 514572247120128 },
    [87303110] = { 286217962799360, 286218768105728, 286218231234816, 202518445427712 },
    [87303120] = { 286217962799872, 286218768106240, 286218231235328, 294670189988096 },
    [87303130] = { 286217962800384, 286218768106752, 286218231235840, 286219304977664 },
    [87303140] = { 286217962801152, 286218768107520, 286218231236608, 286219304970752 },
    [87303150] = { 286217962802688, 286218768109056, 286218231238144, 294670189993984 },
    [87303160] = { 998771022396928, 286218768109824, 286218231238912, 286219304980736 },
    [87303170] = { 998771022409216, 286218768110848, 286218231239936, 286219304971520 },
    [87303180] = { 286217962805504, 286218768111872, 286218231240960 },
    [87303190] = { 286217962806016, 286218768112384, 286218231241472 },
    [87303200] = { 998771022398464, 286218768112896, 286218231241984, 286219304965120 },
    [87303210] = { 998771022400000, 286218768113664, 286218231242752, 286219304971520 },
    [87303220] = { 286217962787840, 286218768094208, 286218231223296, 286219304965120 },
    [87303300] = { 286217962808064, 286218768114432, 286218231243520, 294670189988352 },
    [87303310] = { 286217962808576, 286218768114944, 286218231244032, 294670189988096 },
    [87303320] = { 286217962809344, 286218768115712, 286218231244800, 286219304971520 },
    [87303330] = { 286217962810368, 286218768116736, 286218231245824, 286219304971520 },
    [87303340] = { 286217962811136, 286218768117504, 286218231246592, 286219304988416 },
    [87303350] = { 286217962811648, 286218768118016, 286218231247104, 294670189988864 },
    [87303360] = { 286217962812160, 286218768118528, 286218231247616, 1240250995202816 },
    [87303370] = { 286217962812928, 286218768119296, 286218231248384, 286219304970752 },
    [87303380] = { 286217962813440, 286218768119808, 286218231248896, 255362649299968 },
    [87303390] = { 286217962813952, 286218768120320, 286218231249408, 286219304965120 },
    [87303400] = { 286217962814464, 286218768120832, 286218231249920, 282026343139328 },
    [87303410] = { 286217962814976, 286218768121344, 286218231250432, 514572247120128 },
    [87303420] = { 286217962815744, 286218768122112, 286218231251200, 514572247120128 },
    [87303430] = { 286217962816256, 286218768122624, 286218231251712, 514572247120128 },
    [87303440] = { 286217962816768, 286218768123136, 286218231252224, 514572247120128 },
}

local marionetteEnglishNames = {
    [87303350] = "Dawn Arrival",
    [87303360] = "Arbitration Brand",
    [87303370] = "Mystery Pry Gaze",
    [87303380] = "Morning Light Protection",
    [87303390] = "Knight's Oath",
    [87303400] = "Butterfly Spirit Possession",
    [87303410] = "Descending Shadow",
    [87303420] = "Death Knell Echo",
    [87303430] = "Alpha Wolf Claw Combo",
    [87303440] = "Drill Protection",
}

local marionetteSkillIdByIconNumber = {
    [14] = 87303410,
    [20] = 87303350,
    [21] = 87303360,
    [22] = 87303370,
    [23] = 87303380,
    [24] = 87303390,
    [25] = 87303400,
    [31] = 87303420,
    [32] = 87303430,
    [33] = 87303440,
}

local shortMenuLabels = {
    Fashion = "Style",
    Pastime = "Explore",
    Dungeon = "Dungeon",
    PVP = "Arena",
    Equip = "Gear",
    Skill = "Skills",
    Talent = "Talent",
    Promotion = "Pathway",
    Sealed = "Relics",
    SecretPartner = "Puppets",
    Fellow = "Allies",
    Paotuan = "TRPG",
    Guild = "Club",
    Home = "Castle",
    Task = "Quests",
    Family = "Family",
    Qingyuan = "Bonds",
    Achievement = "Awards",
    Strategy = "Guide",
    VideoCreation = "Creator",
    Friend = "Friends",
    ShadowCity = "DarkCity",
    Character = "Profile",
    HomePage = "Home",
    Bag = "Bag",
    Notice = "News",
    Email = "Mail",
    Rank = "Ranking",
    Detach = "Unequip",
    Setting = "Settings",
    QuitGame = "Exit",
}

local directTables = {}
local missingLogged = {}

local function report(message)
    local logger = Log or LaunchLog
    if logger and logger.Info then
        logger.Info("[CPDDRuntimeFix] " .. tostring(message))
    end
end

local inheritedTextOverrides = {}
do
    local ok, loaded = pcall(require, "mods.cpdd_runtime_fixes.RuntimeInheritedText")
    if ok and type(loaded) == "table" then
        inheritedTextOverrides = loaded
    else
        report("Inherited runtime text map unavailable: " .. tostring(loaded))
    end
end

local languageSourceIndex = {}
do
    local ok, loaded = pcall(require, "mods.cpdd_runtime_fixes.LanguageSourceIndex")
    if ok and type(loaded) == "table" then
        languageSourceIndex = loaded
    else
        report("language source index unavailable: " .. tostring(loaded))
    end
end

local function getSymbol(value, environment, name)
    if type(value) == "table" and value[name] ~= nil then
        return value[name]
    end
    if type(environment) == "table" and environment[name] ~= nil then
        return environment[name]
    end
    return rawget(_G, name)
end
local function getNamedWidget(owner, name)
    if owner == nil or type(name) ~= "string" then
        return nil
    end

    local widget = nil
    pcall(function()
        widget = owner[name]
    end)
    if widget ~= nil then
        return widget
    end

    pcall(function()
        if owner.GetWidgetFromName ~= nil then
            widget = owner:GetWidgetFromName(name)
        end
    end)
    if widget ~= nil then
        return widget
    end

    pcall(function()
        local tree = owner.WidgetTree
        if tree ~= nil then
            if tree.FindWidget ~= nil then
                widget = tree:FindWidget(name)
            elseif tree.GetWidgetFromName ~= nil then
                widget = tree:GetWidgetFromName(name)
            end
        end
    end)
    if widget ~= nil then
        return widget
    end
    pcall(function()
        local tree = owner.WidgetTree
        if tree == nil or tree.GetAllWidgets == nil then
            return
        end
        local widgets = {}
        local result = tree:GetAllWidgets(widgets)
        if type(result) == "table" then
            widgets = result
        end
        for _, candidate in pairs(widgets) do
            local candidateName = nil
            if candidate ~= nil and candidate.GetName ~= nil then
                candidateName = tostring(candidate:GetName())
            end
            if candidateName == name then
                widget = candidate
                break
            end
        end
    end)
    return widget
end

local repairLiveString
local hasCjk
local logUnresolvedText

local function walkWidgetDescendants(owner, visited, visitor)
    if owner == nil or visited[owner] then
        return
    end
    visited[owner] = true
    visitor(owner)
    local count = nil
    pcall(function()
        if owner.GetChildrenCount ~= nil then
            count = tonumber(owner:GetChildrenCount())
        end
    end)
    if count ~= nil then
        for index = 0, count - 1 do
            local child = nil
            pcall(function()
                child = owner:GetChildAt(index)
            end)
            walkWidgetDescendants(child, visited, visitor)
        end
    end

    local content = nil
    pcall(function()
        if owner.GetContent ~= nil then
            content = owner:GetContent()
        end
    end)
    walkWidgetDescendants(content, visited, visitor)

    local widgets = {}
    local ok, result = pcall(function()
        return owner.WidgetTree:GetAllWidgets(widgets)
    end)
    if ok then
        if type(result) == "table" then
            widgets = result
        end
        for _, widget in pairs(widgets) do
            walkWidgetDescendants(widget, visited, visitor)
        end
    end
end

local function translateVisibleText(value)
    if type(value) ~= "string" then
        return value
    end

    local ratingValue = value:match("^非凡评分%s*([%d].*)$")
    if ratingValue ~= nil then
        return "Beyonder Rating " .. ratingValue
    end

    local interval, damage, slowPercent, duration = value:match(
        "^在目标位置召唤窥秘之眼链接目标，每([%d%.]+)秒对目标造成([%d%.]+)伤害并使目标减速([%d%.]+)%%。链接最多持续([%d%.]+)秒，目标远离窥秘之眼一定距离后链接会提前断开。$"
    )
    if interval ~= nil then
        return "Summon an Eye of Mystery at the target location to link to the target, dealing "
            .. damage .. " damage every " .. interval .. " seconds and slowing the target by "
            .. slowPercent .. "%. The link lasts up to " .. duration
            .. " seconds and breaks early if the target moves too far from the Eye of Mystery."
    end

    local exact = visibleTextExactOverrides[value]
    if exact ~= nil then
        return exact
    end

    local inherited = inheritedTextOverrides[value]
    if inherited ~= nil then
        return inherited
    end

    local result = value
    for _, replacement in ipairs(visibleTextReplacements) do
        result = result:gsub(replacement[1], function()
            return replacement[2]
        end)
    end
    return result
end

local function translateTextWidget(widget)
    if widget == nil then
        return 0
    end

    local ok, current = pcall(function()
        return widget:GetText()
    end)
    if not ok or current == nil then
        return 0
    end

    local currentText = type(current) == "string" and current or tostring(current)
    local widgetName = "Text"
    pcall(function()
        widgetName = tostring(widget:GetName())
    end)
    local translated = repairLiveString and repairLiveString("WidgetText", widgetName, widgetName, currentText)
        or translateVisibleText(currentText)
    if translated ~= currentText then
        local changed = pcall(function()
            widget:SetText(translated)
        end)
        pcall(function()
            widget.Text = translated
        end)
        pcall(function()
            if widget.SynchronizeProperties ~= nil then
                widget:SynchronizeProperties()
            end
        end)
        pcall(function()
            if widget.InvalidateLayoutAndVolatility ~= nil then
                widget:InvalidateLayoutAndVolatility()
            end
        end)
        return changed and 1 or 0
    end
    if logUnresolvedText then
        logUnresolvedText("widget", currentText, widgetName)
    end
    return 0
end

local function translateViewTextWidgets(view, userWidget)
    local visited = setmetatable({}, { __mode = "k" })
    local repairedCount = 0
    local function translateWidgetTree(owner)
        walkWidgetDescendants(owner, visited, function(widget)
            repairedCount = repairedCount + translateTextWidget(widget)
        end)
    end
    if type(view) == "table" then
        for _, widget in pairs(view) do
            translateWidgetTree(widget)
        end
    end

    if userWidget == nil then
        return repairedCount
    end
    local widgetNames = {
        "Text_Name", "Text_Title", "Text_Power", "Text_PowerName",
        "Text_CEName", "Text_CETitle", "Text_ScoreName", "Text_Rating",
        "RTB_Text", "RTB_Name", "RTB_Title", "Text_lua", "Text2_lua",
        "Text_Recommend", "Text_Extra", "Text_BeStrong", "Text_Reset",
        "Text_Equip", "Text_Tips", "Text_BtnName", "Text_Plan",
        "Text_Content", "TextUsing", "TB_Word",
    }
    for _, name in ipairs(widgetNames) do
        translateWidgetTree(getNamedWidget(userWidget, name))
    end
    translateWidgetTree(userWidget)
    return repairedCount
end

local function translateTableStrings(value, seen)
    if type(value) ~= "table" then
        return value
    end

    seen = seen or {}
    if seen[value] then
        return value
    end
    seen[value] = true

    for key, child in pairs(value) do
        if type(child) == "string" then
            value[key] = translateVisibleText(child)
        elseif type(child) == "table" then
            translateTableStrings(child, seen)
        end
    end
    return value
end

local function applyVisibleTextOverrides(value, environment)
    local module = value
    if type(module) ~= "table" then
        module = getSymbol(value, environment, "TopData")
    end
    if type(module) ~= "table" then
        return value
    end

    translateTableStrings(module)
    return value
end

local function explicitLookup(index, tag)
    local curated = tag
        and curatedIdOverrides.Split
        and curatedIdOverrides.Split[tag]
        or curatedIdOverrides.Aggregate
    if type(curated) == "table" then
        local replacement = curated[index]
            or curated[tonumber(index)]
            or curated[tostring(index)]
        if replacement ~= nil then
            return replacement
        end
    end
    if tag then
        local values = splitOverrides[tag]
        return values and values[index] or nil
    end
    return aggregateOverrides[index]
end

local function getDirectTable(tag)
    local cacheKey = tag or "__aggregate"
    local cached = directTables[cacheKey]
    if cached ~= nil then
        return cached
    end

    local suffix = tag and ("_" .. tag) or ""
    for _, moduleName in ipairs({
        "cpdd_translation.Data.Excel.LanguageData.StringDB_CN_Data" .. suffix,
        "Data.Excel.LanguageData.StringDB_EN_Data" .. suffix,
        "Data.Excel.LanguageData.StringDB_CN_Data" .. suffix,
    }) do
        local ok, module = pcall(require, moduleName)
        if ok and type(module) == "table" then
            local data = module.data or module
            if type(data) == "table" then
                directTables[cacheKey] = data
                report("using direct localization table " .. moduleName)
                return data
            end
        end
    end

    return nil
end

local function directLookup(index, tag)
    local data = getDirectTable(tag)
    return data and data[index] or nil
end

local function contextualSourceLookup(tableName, source)
    if type(tableName) ~= "string" or type(source) ~= "string" then
        return nil
    end
    local normalized = tableName
    if normalized:sub(1, 13) == "LanguageData." then
        normalized = "Data.Excel." .. normalized
    end
    local values = curatedContextOverrides[normalized]
    return type(values) == "table" and values[source] or nil
end

local bit = require("bit")

hasCjk = function(value)
    return type(value) == "string" and value:find("[\228-\233][\128-\191][\128-\191]") ~= nil
end

local function sourceKey(value)
    local hash = bit.tobit(2166136261)
    for index = 1, #value do
        hash = bit.bxor(hash, value:byte(index))
        hash = bit.tobit(
            hash
            + bit.lshift(hash, 1)
            + bit.lshift(hash, 4)
            + bit.lshift(hash, 7)
            + bit.lshift(hash, 8)
            + bit.lshift(hash, 24)
        )
    end
    return tostring(#value) .. ":" .. bit.tohex(hash)
end

local unresolvedTextLogged = {}

local function escapeLogField(value)
    return tostring(value or "")
        :gsub("\\", "\\\\")
        :gsub("\r", "\\r")
        :gsub("\n", "\\n")
        :gsub("\t", "\\t")
end
logUnresolvedText = function(kind, value, context)
    if not hasCjk(value) then
        return
    end
    local identity = tostring(kind) .. "\0" .. value
    if unresolvedTextLogged[identity] then
        return
    end
    unresolvedTextLogged[identity] = true
    report(
        "unresolved localized Chinese [" .. tostring(kind) .. "]\t"
        .. escapeLogField(context) .. "\t" .. escapeLogField(value)
    )
end

local function sourceReference(reference)
    if type(reference) == "number" then
        return nil, reference
    end
    if type(reference) ~= "string" then
        return nil, nil
    end
    local tag, languageId = reference:match("^([A-Za-z0-9_]+):(%d+)$")
    return tag, tag and tonumber(languageId) or nil
end

local function referenceScore(reference, tableName, fieldPath)
    if type(reference) ~= "string" then
        return 0
    end
    local tag = reference:match("^([A-Za-z0-9_]+):")
    if not tag then
        return 0
    end
    local context = (tostring(tableName or "") .. "." .. tostring(fieldPath or "")):lower()
    tag = tag:lower()
    local score = context:find(tag, 1, true) and 100 or 0
    for _, family in ipairs({
        "skill", "buff", "item", "talk", "task", "guide",
        "achievement", "manor", "gossip", "loading",
    }) do
        if context:find(family, 1, true) and tag:sub(1, #family) == family then
            score = score + 50
        end
    end
    if (context:find("dialog", 1, true) or context:find("npc", 1, true))
        and tag:find("talk", 1, true)
    then
        score = score + 25
    end
    return score
end

local function lookupSourceTranslation(sourceReferenceValue, tableName, fieldPath)
    local references = type(sourceReferenceValue) == "table"
        and sourceReferenceValue
        or { sourceReferenceValue }
    local translated, bestScore, conflicting = nil, -1, false
    for _, reference in ipairs(references) do
        local tag, languageId = sourceReference(reference)
        if languageId then
            local candidate = explicitLookup(languageId, tag) or directLookup(languageId, tag)
            if type(candidate) == "string" then
                candidate = translateVisibleText(candidate)
                local score = referenceScore(reference, tableName, fieldPath)
                if score > bestScore then
                    translated, bestScore, conflicting = candidate, score, false
                elseif score == bestScore and translated ~= candidate then
                    conflicting = true
                end
            end
        end
    end
    return conflicting and nil or translated
end

repairLiveString = function(tableName, rowKey, fieldPath, value)
    if not hasCjk(value) then
        return value
    end

    local contextualSource = contextualSourceLookup(tableName, value)
    if type(contextualSource) == "string" then
        return translateVisibleText(contextualSource)
    end

    local languagePrefix = "Data.Excel.LanguageData.StringDB_CN_Data"
    local tag = nil
    local isLanguageTable = false
    if type(tableName) == "string" then
        local start = tableName:find(languagePrefix, 1, true)
        if start then
            isLanguageTable = true
            local suffix = tableName:sub(start + #languagePrefix)
            tag = suffix:sub(1, 1) == "_" and suffix:sub(2) or nil
            if tag == "" then
                tag = nil
            end
        end
    end
    local contextual = isLanguageTable and explicitLookup(rowKey, tag) or nil
    if type(contextual) == "string" and not hasCjk(contextual) then
        return translateVisibleText(contextual)
    end

    local known = translateVisibleText(value)
    if known ~= value then
        return known
    end

    local sourceReferenceValue = languageSourceIndex[sourceKey(value)]
    if sourceReferenceValue ~= nil then
        local translated = lookupSourceTranslation(sourceReferenceValue, tableName, fieldPath)
        if type(translated) == "string" and translated ~= value then
            return translated
        end
    end
    return value
end

local function repairWidgetBlueprintTextData(value, environment, source)
    local module = value
    if type(module) ~= "table" then
        module = getSymbol(value, environment, "TopData")
    end
    if type(module) ~= "table" then
        return value
    end

    local data = module.data or module
    if type(data) ~= "table" then
        return value
    end

    local repairedCount = 0
    for rowKey, row in pairs(data) do
        if type(row) == "table" and type(row.DisplayString) == "string" then
            local repaired = repairLiveString(
                "WidgetBlueprintTextData",
                rowKey,
                "DisplayString",
                row.DisplayString
            )
            if repaired ~= row.DisplayString then
                row.DisplayString = repaired
                repairedCount = repairedCount + 1
            end
        end
    end
    if repairedCount > 0 then
        report("repaired " .. repairedCount .. " cached Blueprint text entries from " .. tostring(source))
    end
    return value
end

local function repairLiveValue(tableName, rowKey, fieldPath, value, depth, seen, maxDepth)
    local valueType = type(value)
    if valueType == "string" then
        return repairLiveString(tableName, rowKey, fieldPath, value)
    end
    if depth >= (maxDepth or 3)
        or seen[value]
        or (valueType ~= "table" and valueType ~= "userdata")
    then
        return value
    end

    local manager = Game and Game.TableDataManager
    if valueType == "userdata" and manager and type(manager.isSpecialUEType) == "function" then
        local ok, special = pcall(manager.isSpecialUEType, manager, value)
        if ok and special then
            return value
        end
    end
    seen[value] = true

    local iterator = valueType == "userdata" and rawget(_G, "ksbcpairs") or pairs
    if type(iterator) ~= "function" then
        return value
    end
    local ok, nextFunction, state, firstKey = pcall(iterator, value)
    if not ok or type(nextFunction) ~= "function" then
        return value
    end

    local entries = {}
    for field, child in nextFunction, state, firstKey do
        entries[#entries + 1] = { field, child }
    end

    local output = value
    for _, entry in ipairs(entries) do
        local field, child = entry[1], entry[2]
        local path = fieldPath == "" and tostring(field) or (fieldPath .. "." .. tostring(field))
        local repaired = repairLiveValue(
            tableName,
            rowKey,
            path,
            child,
            depth + 1,
            seen,
            maxDepth
        )
        if repaired ~= child then
            if output == value then
                output = {}
                for _, originalEntry in ipairs(entries) do
                    output[originalEntry[1]] = originalEntry[2]
                end
                if valueType == "table" then
                    setmetatable(output, getmetatable(value))
                end
            end
            output[field] = repaired
        end
    end
    return output
end

local function repairPickObjectSayTexts(value, environment)
    local module = value
    if type(module) ~= "table" then
        module = getSymbol(value, environment, "TopData")
    end
    if type(module) ~= "table" then
        return value
    end

    local data = module.data or module
    if type(data) ~= "table" then
        return value
    end

    local visited = {}
    local sayActions = 0
    local repairedActions = 0

    local function visit(node, rowKey, fieldPath, depth)
        if type(node) ~= "table" or visited[node] or depth > 12 then
            return
        end
        visited[node] = true

        local isSay = node.FuncName == "Say" and type(node.FuncArgInfos) == "table"
        if isSay then
            sayActions = sayActions + 1
            local repaired = repairLiveValue(
                "PickObjectData",
                rowKey,
                fieldPath .. ".FuncArgInfos",
                node.FuncArgInfos,
                0,
                {},
                8
            )
            if repaired ~= node.FuncArgInfos then
                node.FuncArgInfos = repaired
                repairedActions = repairedActions + 1
            end
        end

        for field, child in pairs(node) do
            if type(child) == "table" and not (isSay and field == "FuncArgInfos") then
                visit(child, rowKey, fieldPath .. "." .. tostring(field), depth + 1)
            end
        end
    end

    for rowKey, row in pairs(data) do
        visit(row, rowKey, tostring(rowKey), 0)
    end

    if sayActions > 0 then
        report(
            "processed PickObjectData Say actions=" .. tostring(sayActions)
            .. " repaired=" .. tostring(repairedActions)
        )
    end
    return value
end

local function applyAggregateOverrides(value, environment)
    local module = value
    if type(module) ~= "table" then
        module = getSymbol(value, environment, "StringDB_CN_Data")
            or getSymbol(value, environment, "StringDB_EN_Data")
    end
    if type(module) ~= "table" then
        return value
    end

    local data = module.data or module
    if type(data) == "table" then
        for key, replacement in pairs(aggregateOverrides) do
            data[key] = replacement
        end
    end
    return value
end

Loader.AfterLoad(
    "Data.Excel.LanguageData.StringDB_CN_Data",
    applyAggregateOverrides,
    1000000,
    "cpdd.runtime-fix.aggregate-cn"
)
Loader.AfterLoad(
    "Data.Excel.LanguageData.StringDB_EN_Data",
    applyAggregateOverrides,
    1000000,
    "cpdd.runtime-fix.aggregate-en"
)

for _, moduleName in ipairs({
    "Data.Excel.WidgetBlueprintTextData",
    "Data.Excel.DialogueTalkData",
    "Data.Excel.DialogueAssetData",
    "Data.Excel.DialogueOptionText",
    "Data.Excel.NpcInfoData",
}) do
    Loader.AfterLoad(
        moduleName,
        applyVisibleTextOverrides,
        1000000,
        "cpdd.runtime-fix.visible-text." .. moduleName:gsub("[^%w]", "-")
    )
end

Loader.AfterLoad(
    "Data.Excel.WidgetBlueprintTextData",
    function(value, environment)
        return repairWidgetBlueprintTextData(value, environment, "loader")
    end,
    1000001,
    "cpdd.runtime-fix.widget-blueprint-source"
)

Loader.AfterLoad(
    "Data.Excel.PickObjectData",
    repairPickObjectSayTexts,
    1000000,
    "cpdd.runtime-fix.pick-object-say-texts"
)

local function fillLocalizedField(row, field, key, tag, force)
    if not force and row[field] ~= nil and row[field] ~= "" then
        return
    end
    local value = explicitLookup(key, tag) or directLookup(key, tag)
    if value ~= nil then
        row[field] = translateVisibleText(value)
    end
end

local function normalizeSkillId(skillId)
    if type(skillId) == "number" then
        return skillId
    end
    local ok, numericId = pcall(tonumber, skillId)
    if ok and type(numericId) == "number" then
        return numericId
    end
    return nil
end

local function getMarionetteSkillLocalizationById(skillId)
    skillId = normalizeSkillId(skillId)
    if skillId == nil then
        return nil, false, nil
    end

    local keys = marionetteSkillLocalization[skillId]
    if keys then
        return keys, true, skillId
    end
    local baseSkillId = skillId - skillId % 10
    keys = marionetteSkillLocalization[baseSkillId]
    if not keys and skillId >= 87303004 and skillId <= 87303009 then
        baseSkillId = 87303004
        keys = marionetteSkillLocalization[87303004]
    end
    return keys, false, keys and baseSkillId or nil
end

local function getMarionetteSkillLocalization(skillId, row)
    local keys, isBaseRow, mappedSkillId = getMarionetteSkillLocalizationById(skillId)
    if keys then
        return keys, isBaseRow, mappedSkillId
    end

    if type(row) ~= "table" then
        return nil, false, nil
    end

    for _, candidate in ipairs({ row.ID, row.InitialSkill, row.InitialSkillID, row.RoleSkillID }) do
        keys, isBaseRow, mappedSkillId = getMarionetteSkillLocalizationById(candidate)
        if keys then
            return keys, isBaseRow, mappedSkillId
        end
    end

    for _, field in ipairs({ "SkillDisplayIcon", "SkillIcon", "IconTexture" }) do
        local icon = row[field]
        if type(icon) == "string" then
            local iconNumber = tonumber(icon:match("SecretPartner_Skill_(%d+)"))
            local iconSkillId = iconNumber and marionetteSkillIdByIconNumber[iconNumber]
            if iconSkillId then
                return marionetteSkillLocalization[iconSkillId], false, iconSkillId
            end
        end
    end

    return nil, false, nil
end

local function repairMarionetteSkillRow(row, skillId)
    local keys, isBaseRow, mappedSkillId = getMarionetteSkillLocalization(skillId, row)
    if type(row) ~= "table" or not keys then
        return row
    end
    fillLocalizedField(row, "Name", keys[1], "skill3", true)
    if marionetteEnglishNames[mappedSkillId]
        and (row.Name == nil or row.Name == "" or hasCjk(row.Name)) then
        row.Name = marionetteEnglishNames[mappedSkillId]
    end
    if isBaseRow then
        fillLocalizedField(row, "BriefDescription", keys[2], "skill3", true)
        fillLocalizedField(row, "SkillDisc", keys[3], "skill3", true)
        fillLocalizedField(row, "Tag", keys[4], nil, true)
    end
    return row
end

local function isMarionetteSkillRow(row, skillId)
    local numericId = normalizeSkillId(skillId)
    if not numericId and type(row) == "table" then
        numericId = normalizeSkillId(row.ID) or normalizeSkillId(row.InitialSkill)
    end
    if numericId and numericId >= 87303000 and numericId < 87304000 then
        return true
    end
    if type(row) == "table" then
        for _, field in ipairs({ "SkillDisplayIcon", "SkillIcon", "IconTexture" }) do
            local icon = row[field]
            if type(icon) == "string" and icon:find("SecretPartner_Skill_", 1, true) then
                return true
            end
        end
    end
    return false
end

Loader.AfterLoad("Framework.Utils.LuaCommon.Managers.TableDataManager", function(value, environment)
    local manager = getSymbol(value, environment, "TableDataManager")
    if type(manager) ~= "table" or manager.__cpddRuntimeFixV1 then
        return value
    end

    manager.__cpddRuntimeFixV1 = true
    local originalGetLangStr = assert(manager.GetLangStr)
    local originalGetLangStrSplit = assert(manager.GetLangStrSplit)
    local originalGetRow = manager.GetRow
    local originalGetAttr = manager.GetAttr

    function manager:GetLangStr(index)
        local replacement = explicitLookup(index, nil) or directLookup(index, nil)
        if replacement ~= nil then
            return translateVisibleText(replacement)
        end

        local ok, result = pcall(originalGetLangStr, self, index)
        if ok and result ~= nil then
            local translated = translateVisibleText(result)
            if translated == result and hasCjk(result) then
                translated = repairLiveString(
                    "LanguageData.StringDB_CN_Data",
                    index,
                    "RawText",
                    result
                )
            end
            if translated == result then
                logUnresolvedText("aggregate-result", result, index)
            end
            return translated
        end

        if type(index) == "string" and hasCjk(index) then
            local translated = repairLiveString(
                "LanguageData.StringDB_CN_Data",
                index,
                "RawText",
                index
            )
            if translated ~= index then
                return translated
            end
            logUnresolvedText("aggregate-key", index, index)
        end

        if not hasCjk(index) and not missingLogged[index] then
            missingLogged[index] = true
            report("unresolved aggregate localization key " .. tostring(index))
        end
        return nil
    end

    function manager:GetLangStrSplit(index, tag)
        local replacement = explicitLookup(index, tag) or directLookup(index, tag)
        if replacement ~= nil then
            return translateVisibleText(replacement)
        end

        local ok, result = pcall(originalGetLangStrSplit, self, index, tag)
        if ok and result ~= nil then
            local translated = translateVisibleText(result)
            if translated == result and hasCjk(result) then
                translated = repairLiveString(
                    "LanguageData.StringDB_CN_Data_" .. tostring(tag or ""),
                    index,
                    "RawText",
                    result
                )
            end
            if translated == result then
                logUnresolvedText("split-result", result, tostring(tag) .. ":" .. tostring(index))
            end
            return translated
        end

        if type(index) == "string" and hasCjk(index) then
            local translated = repairLiveString(
                "LanguageData.StringDB_CN_Data_" .. tostring(tag or ""),
                index,
                "RawText",
                index
            )
            if translated ~= index then
                return translated
            end
            logUnresolvedText("split-key", index, tostring(tag) .. ":" .. tostring(index))
        end

        local missingKey = tostring(tag) .. ":" .. tostring(index)
        if not hasCjk(index) and not missingLogged[missingKey] then
            missingLogged[missingKey] = true
            report("unresolved split localization key " .. missingKey)
        end
        return nil
    end

    if type(originalGetRow) == "function" then
        function manager:GetRow(tableName, rowKey, priority)
            local languagePrefix = "LanguageData.StringDB_CN_Data"
            if type(tableName) == "string" and tableName:sub(1, #languagePrefix) == languagePrefix then
                local suffix = tableName:sub(#languagePrefix + 1)
                local tag = suffix:sub(1, 1) == "_" and suffix:sub(2) or nil
                if tag == "" then
                    tag = nil
                end
                local translated = explicitLookup(rowKey, tag) or directLookup(rowKey, tag)
                if translated ~= nil then
                    return translateVisibleText(translated)
                end
                return translateVisibleText(originalGetRow(self, tableName, rowKey, priority))
            end

            local result = originalGetRow(self, tableName, rowKey, priority)
            if type(tableName) == "string" and tableName:sub(1, 13) == "LanguageData." then
                return result
            end
            return repairLiveValue(tableName, rowKey, "", result, 0, {})
        end
    end

    if type(originalGetAttr) == "function" then
        function manager:GetAttr(tableName, attrKey)
            local result = originalGetAttr(self, tableName, attrKey)
            return repairLiveValue(tableName, attrKey, "", result, 0, {})
        end
    end

    report("installed translated localization and live-row fallback")
    return value
end, 1000000, "cpdd.runtime-fix.localization")

local function wrapGeneratedRowHelper(helperName, original)
    return function(...)
        local rowKey = select(1, ...)
        local row = original(...)
        if helperName == "GetSkillDataNewRow" then
            row = repairMarionetteSkillRow(row, rowKey)
        elseif helperName == "GetBuffDataNewRow" and rowKey == 82071030 and type(row) == "table" then
            fillLocalizedField(row, "BuffName", 211107038233344, "buffdata")
            fillLocalizedField(row, "BuffName1", 211107038233344, "buffappear")
            fillLocalizedField(row, "BuffDisc", 211107843539712, nil)
        end
        return repairLiveValue(helperName, rowKey, "", row, 0, {})
    end
end

local function installTableDataRowRepair(tableData, source)
    if type(tableData) ~= "table" then
        return false
    end

    local wrappers = tableData.__cpddRuntimeFixGeneratedRowWrappers
    if type(wrappers) ~= "table" then
        wrappers = {}
    end

    local wrapped = 0
    for helperName, member in pairs(tableData) do
        if type(helperName) == "string"
            and type(member) == "function"
            and helperName:match("^Get.+Row$")
            and wrappers[helperName] ~= member
        then
            local original = member
            local wrapper = wrapGeneratedRowHelper(helperName, original)
            tableData[helperName] = wrapper
            wrappers[helperName] = wrapper
            wrapped = wrapped + 1
        end
    end

    tableData.__cpddRuntimeFixGeneratedRowWrappers = wrappers
    tableData.__cpddRuntimeFixRows = VERSION
    if wrapped > 0 then
        report(
            "installed generated TableData row repair on " .. tostring(source)
            .. " helpers=" .. tostring(wrapped)
        )
    end
    return wrapped > 0
end

local tableDataProbesLogged = {}
local function ensureGameTableDataRowRepair(source)
    local tableData = Game and Game.TableData
    local installed = installTableDataRowRepair(tableData, source)
    if not tableDataProbesLogged[source] then
        tableDataProbesLogged[source] = true
        report(
            "probed Game.TableData from " .. tostring(source)
            .. " type=" .. type(tableData)
            .. " installed=" .. tostring(installed)
            .. " target=" .. tostring(tableData)
        )
    end
    return installed
end

local function tableDataFrom(value, environment)
    if type(value) == "table" and type(value.GetSkillDataNewRow) == "function" then
        return value
    end
    if type(value) == "table" and type(value.TableData) == "table" then
        return value.TableData
    end
    if type(environment) == "table" and type(environment.TableData) == "table" then
        return environment.TableData
    end
    return Game and Game.TableData
end

Loader.AfterLoad("Data.Excel.TableData", function(value, environment)
    local tableData = tableDataFrom(value, environment)
    installTableDataRowRepair(tableData, "Data.Excel.TableData")
    ensureGameTableDataRowRepair("Data.Excel.TableData callback")
    return value
end, 1000000, "cpdd.runtime-fix.table-rows")

for _, moduleName in ipairs({
    "Gameplay.LogicSystem.SkillCustomizer.Main.Skill_Fight_Item",
    "Gameplay.LogicSystem.SecretPartner.Base.SecretPartnerSkill",
}) do
    Loader.AfterLoad(moduleName, function(value)
        installTableDataRowRepair(Game and Game.TableData, moduleName)
        return value
    end, 1000000, "cpdd.runtime-fix.table-rows-late." .. moduleName:gsub("[^%w]", "-"))
end

Loader.AfterLoad("Gameplay.Const.StringConst.StringConst", function(value, environment)
    local stringConst = getSymbol(value, environment, "StringConst")
    if type(stringConst) ~= "table" or stringConst.__cpddRuntimeFixV1 then
        return value
    end

    stringConst.__cpddRuntimeFixV1 = true
    local originalGet = assert(stringConst.Get)

    stringConst.Get = function(key, ...)
        local replacement = stringConstOverrides[key]
        if replacement ~= nil then
            if select("#", ...) > 0 then
                return string.format(replacement, ...)
            end
            return replacement
        end
        return translateVisibleText(originalGet(key, ...))
    end

    return value
end, 1000000, "cpdd.runtime-fix.string-const")

local numberWordsUnderTwenty = {
    "Zero", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine",
    "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen",
    "Seventeen", "Eighteen", "Nineteen",
}
local numberWordsTens = {
    [2] = "Twenty",
    [3] = "Thirty",
    [4] = "Forty",
    [5] = "Fifty",
    [6] = "Sixty",
    [7] = "Seventy",
    [8] = "Eighty",
    [9] = "Ninety",
}

local function englishNumberUnderHundred(num)
    if num < 20 then
        return numberWordsUnderTwenty[num + 1]
    end

    local tens = math.floor(num / 10)
    local ones = num % 10
    local result = numberWordsTens[tens]
    if ones ~= 0 then
        result = result .. " " .. numberWordsUnderTwenty[ones + 1]
    end
    return result
end

local function englishNumberUnderThousand(num)
    if num < 100 then
        return englishNumberUnderHundred(num)
    end

    local hundreds = math.floor(num / 100)
    local remainder = num % 100
    local result = numberWordsUnderTwenty[hundreds + 1] .. " Hundred"
    if remainder ~= 0 then
        result = result .. " " .. englishNumberUnderHundred(remainder)
    end
    return result
end

local function englishNumber(num)
    if type(num) ~= "number" or num < 0 or num >= 10000 or math.floor(num) ~= num then
        return num
    end
    if num < 1000 then
        return englishNumberUnderThousand(num)
    end

    local thousands = math.floor(num / 1000)
    local remainder = num % 1000
    local result = englishNumberUnderThousand(thousands) .. " Thousand"
    if remainder ~= 0 then
        result = result .. " " .. englishNumberUnderThousand(remainder)
    end
    return result
end

Loader.AfterLoad("Gameplay.LogicSystem.Utils.HUDUtils", function(value, environment)
    ensureGameTableDataRowRepair("HUDUtils")
    local hudUtils = getSymbol(value, environment, "HUDUtils")
    if type(hudUtils) ~= "table" or hudUtils.__cpddRuntimeFixV1 then
        return value
    end

    hudUtils.__cpddRuntimeFixV1 = true
    hudUtils.NumberToChinese = englishNumber
    report("installed English HUD number formatter")
    return value
end, 1000000, "cpdd.runtime-fix.hud-number-format")

Loader.AfterLoad("Gameplay.LogicSystem.Reminder.PlayerInfo.PowerItemSpecial", function(value, environment)
    ensureGameTableDataRowRepair("PowerItemSpecial")
    local powerItem = getSymbol(value, environment, "PowerItemSpecial")
    if type(powerItem) ~= "table" or powerItem.__cpddRuntimeFixV1 then
        return value
    end

    powerItem.__cpddRuntimeFixV1 = true
    local originalRefresh = assert(powerItem.Refresh)

    function powerItem:Refresh(...)
        local results = { originalRefresh(self, ...) }
        translateViewTextWidgets(self.view, self.userWidget)
        return unpack(results)
    end

    report("installed Beyonder Rating reminder label fix")
    return value
end, 1000000, "cpdd.runtime-fix.power-rating-label")

Loader.AfterLoad("Gameplay.LogicSystem.NewHeadInfo.HeadInfoUI.HeadInfoName", function(value, environment)
    ensureGameTableDataRowRepair("HeadInfoName")
    local headInfoName = getSymbol(value, environment, "HeadInfoName")
    if type(headInfoName) ~= "table" or headInfoName.__cpddRuntimeFixV1 then
        return value
    end

    headInfoName.__cpddRuntimeFixV1 = true
    local originalGetEntityName = assert(headInfoName.getEntityName)
    local originalOnHeadNameChanged = assert(headInfoName.OnHeadNameChanged)

    function headInfoName:getEntityName(entity)
        return translateVisibleText(originalGetEntityName(self, entity))
    end

    function headInfoName:OnHeadNameChanged(name)
        return originalOnHeadNameChanged(self, translateVisibleText(name))
    end

    report("installed translated overhead NPC names")
    return value
end, 1000000, "cpdd.runtime-fix.head-info-name")

Loader.AfterLoad("Gameplay.LogicSystem.Race.WorldWidget.RaceTrace_Widget", function(value, environment)
    local raceWidget = getSymbol(value, environment, "RaceTrace_Widget")
    if type(raceWidget) ~= "table" or raceWidget.__cpddRuntimeFixV1 then
        return value
    end

    local mathLibrary = getSymbol(value, environment, "KismetMathLibrary")
    if type(mathLibrary) ~= "table" then
        local ok, imported = pcall(import, "KismetMathLibrary")
        if ok then
            mathLibrary = imported
        end
    end
    if type(mathLibrary) ~= "table" or type(mathLibrary.Vector_Distance) ~= "function" then
        report("could not install RaceTrace meter fix: KismetMathLibrary unavailable")
        return value
    end

    raceWidget.__cpddRuntimeFixV1 = true
    function raceWidget:UpdateDistance()
        if not Game or not Game.me or not self.checkpointPos then
            return
        end

        local playerPos = Game.me.CppEntity:KAPI_GetLocation()
        local dist = mathLibrary.Vector_Distance(playerPos, self.checkpointPos)
        local distMeter = math.floor(dist / 100)
        if self.view and self.view.Text_Distance then
            self.view.Text_Distance:SetText(tostring(distMeter) .. "m")
        end
    end

    report("installed RaceTrace meter fix")
    return value
end, 1000000, "cpdd.runtime-fix.racetrace-meter")

Loader.AfterLoad("Gameplay.LogicSystem.Tips.TipsSystem", function(value, environment)
    local tipsSystem = getSymbol(value, environment, "TipsSystem")
    if type(tipsSystem) ~= "table" or tipsSystem.__cpddRuntimeFixV1 then
        return value
    end

    tipsSystem.__cpddRuntimeFixV1 = true
    local originalParse = assert(tipsSystem._parseTipsDataSections)

    function tipsSystem:_parseTipsDataSections(tipsId)
        if tipsId == CIRCUIT_BREAKER_TIPS_ID then
            return {
                {
                    Content = { CIRCUIT_BREAKER_TEXT },
                },
            }
        end
        return originalParse(self, tipsId)
    end

    return value
end, 1000000, "cpdd.runtime-fix.circuit-breaker-content")

Loader.AfterLoad("Gameplay.LogicSystem.Login.LoginServerSelect_Panel", function(value, environment)
    local panel = getSymbol(value, environment, "LoginServerSelect_Panel")
    if type(panel) ~= "table" or panel.__cpddRuntimeFixV1 then
        return value
    end

    panel.__cpddRuntimeFixV1 = true
    function panel:on_Btn_Info_Clicked()
        Game.TipsSystem:ShowTips(CIRCUIT_BREAKER_TIPS_ID, self.view.Btn_Info:GetCachedGeometry())
    end

    return value
end, 1000000, "cpdd.runtime-fix.circuit-breaker-button")

Loader.AfterLoad("Gameplay.LogicSystem.SkillCustomizer.SkillBuffDescUtils", function(value, environment)
    local utils = getSymbol(value, environment, "SkillBuffDescUtils")
    if type(utils) ~= "table" or utils.__cpddRuntimeFixV1 then
        return value
    end

    utils.__cpddRuntimeFixV1 = true
    local originalPostProcessingString = assert(utils.PostProcessingString)

    function utils:PostProcessingString(inString, rtbOverWrite, id, level, descType, originalType, descContext)
        local result = originalPostProcessingString(self, inString, rtbOverWrite, id, level, descType, originalType, descContext)
        if id ~= 86071030 or type(result) ~= "string" then
            return result
        end

        local spellFieldIds = { 811710303, 811710304 }
        local replacementIndex = 0
        result = result:gsub("spellfielddisc%(%s*82071030%s*%)", function()
            replacementIndex = replacementIndex + 1
            local spellFieldId = spellFieldIds[replacementIndex] or spellFieldIds[#spellFieldIds]
            local helper = getSymbol(nil, environment, "DescFormulaHelper")
            if type(helper) == "table" and type(helper.GenerateDesc) == "function" then
                local ok, generated = pcall(helper.GenerateDesc, spellFieldId, level, utils.DescType.SpellField, originalType, descContext)
                if ok and generated ~= nil and generated ~= "" then
                    return tostring(generated)
                end
            end
            return "additional"
        end)
        result = result:gsub("NO_BUFF_NAME", "Star Sand Gathering")
        result = result:gsub("NO_SUCH_INFORMATION", "Each stack reduces Movement Speed.")
        return result
    end

    return value
end, 1000000, "cpdd.runtime-fix.star-sand-description")

local function installSkillDescriptionRepair(value, environment)
    local skillSystem = getSymbol(value, environment, "SkillCustomSystem")
    if type(skillSystem) ~= "table" or skillSystem.__cpddGeneratedTextRepair == VERSION then
        return false
    end

    local wrapped = 0
    for _, methodName in ipairs({
        "GenerateSkillDescNoRichText",
        "GenerateSkillBriefDesc",
        "GenerateSkillDecoText",
    }) do
        local original = skillSystem[methodName]
        if type(original) == "function" then
            skillSystem[methodName] = function(self, ...)
                local results = { original(self, ...) }
                if type(results[1]) == "string" then
                    results[1] = repairLiveString("SkillCustomSystem", select(1, ...), methodName, results[1])
                end
                return unpack(results)
            end
            wrapped = wrapped + 1
        end
    end

    skillSystem.__cpddGeneratedTextRepair = VERSION
    if wrapped > 0 then
        report("installed generated skill-description repair")
    end
    return wrapped > 0
end

Loader.AfterLoad(
    "Gameplay.LogicSystem.SkillCustomizer.SkillCustomSystem",
    function(value, environment)
        installSkillDescriptionRepair(value, environment)
        return value
    end,
    1000000,
    "cpdd.runtime-fix.generated-skill-description"
)

local function installViewMethodRepair(value, environment, symbolName, methodNames, source)
    local class = getSymbol(value, environment, symbolName)
    if type(class) ~= "table" then
        return false
    end

    local marker = "__cpddViewTextRepair_" .. VERSION
    if class[marker] then
        return true
    end

    local wrapped = 0
    for _, methodName in ipairs(methodNames) do
        local original = class[methodName]
        if type(original) == "function" then
            class[methodName] = function(self, ...)
                local results = { original(self, ...) }
                local rootWidget = self and (self.userWidget or self.widget)
                translateViewTextWidgets(self and self.view, rootWidget)
                return unpack(results)
            end
            wrapped = wrapped + 1
        end
    end

    class[marker] = true
    if wrapped > 0 then
        report("installed post-refresh widget repair for " .. source)
    end
    return wrapped > 0
end

local function installDataMethodRepair(value, environment, symbolName, methodNames, source)
    local class = getSymbol(value, environment, symbolName)
    if type(class) ~= "table" then
        return false
    end

    local marker = "__cpddDataTextRepair_" .. VERSION
    if class[marker] then
        return true
    end

    local wrapped = 0
    for _, methodName in ipairs(methodNames) do
        local original = class[methodName]
        if type(original) == "function" then
            class[methodName] = function(self, data, ...)
                if type(data) == "string" then
                    data = repairLiveString(source, methodName, "argument", data)
                elseif type(data) == "table" then
                    translateTableStrings(data)
                end
                local results = { original(self, data, ...) }
                local rootWidget = self and (self.userWidget or self.widget)
                translateViewTextWidgets(self and self.view, rootWidget)
                return unpack(results)
            end
            wrapped = wrapped + 1
        end
    end

    class[marker] = true
    if wrapped > 0 then
        report("installed rendered data repair for " .. source)
    end
    return wrapped > 0
end

local function installGuildRoleRepair(value, environment)
    local guildSystem = getSymbol(value, environment, "GuildSystem")
    if type(guildSystem) ~= "table" or guildSystem.__cpddRoleTextRepair == VERSION then
        return false
    end

    local wrapped = 0
    for _, methodName in ipairs({ "RoleIDToRoleName", "GetOccupationText" }) do
        local original = guildSystem[methodName]
        if type(original) == "function" then
            guildSystem[methodName] = function(self, ...)
                local results = { original(self, ...) }
                if type(results[1]) == "string" then
                    results[1] = repairLiveString("GuildSystem", select(1, ...), methodName, results[1])
                end
                return unpack(results)
            end
            wrapped = wrapped + 1
        end
    end

    guildSystem.__cpddRoleTextRepair = VERSION
    if wrapped > 0 then
        report("installed translated club-role names")
    end
    return wrapped > 0
end

local DIALOGUE_LINE_MAX = 42
local DIALOGUE_ROW_HEIGHT = 58
local DIALOGUE_VISIBLE = 4
do
    local ok, visibility = pcall(function()
        return import("ESlateVisibility")
    end)
    if ok and visibility ~= nil then
        DIALOGUE_VISIBLE = visibility.SelfHitTestInvisible or visibility.Visible or DIALOGUE_VISIBLE
    end
end

local function scheduleRepairNextTick(self, repair)
    if self == nil or type(repair) ~= "function" then
        return false
    end
    local ok, addTimer = pcall(function()
        return self.AddTimerWithFunction
    end)
    if not ok or type(addTimer) ~= "function" then
        return false
    end
    return pcall(addTimer, self, 0.01, 1, function()
        pcall(repair, self)
    end)
end

local function scheduleRepairAfter(self, delay, repair)
    if self == nil or type(repair) ~= "function" then
        return false
    end
    local ok, addTimer = pcall(function()
        return self.AddTimerWithFunction
    end)
    if not ok or type(addTimer) ~= "function" then
        return false
    end
    return pcall(addTimer, self, delay, 1, function()
        pcall(repair, self)
    end)
end

local function normalizeDialogueWhitespace(value)
    if type(value) ~= "string" then
        return value
    end
    value = value:gsub("%s*\r?\n%s*", " ")
    value = value:gsub("[ \t]+", " ")
    return value:match("^%s*(.-)%s*$")
end

local function dialogueVisibleLength(value)
    if type(value) ~= "string" then
        return 0
    end
    local plain = value:gsub("<.->", "")
    local ok, length = pcall(function()
        return utf8.len(plain)
    end)
    return ok and length or #plain
end

local function revealDialogueRows(self)
    local talkWidget = self and self.userWidget
    if talkWidget == nil then
        return false
    end
    local changed = false
    for _, widgetName in ipairs({
        "RTB_TalkContent_Back_lua", "RTB_TalkContent_lua",
        "RTB_TalkContent2_Back_lua", "RTB_TalkContent2_lua",
        "RTB_TalkContent3_Back_lua", "RTB_TalkContent3_lua",
    }) do
        pcall(function()
            local widget = getNamedWidget(talkWidget, widgetName)
            if widget ~= nil then
                if widget.SetAutoWrapText ~= nil then
                    widget:SetAutoWrapText(false)
                end
                changed = true
            end
        end)
    end
    if self.__cpddDialogueHasThirdLine then
        for _, widgetName in ipairs({
            "RTB_TalkContent3_Back_lua", "RTB_TalkContent3_lua",
        }) do
            pcall(function()
                local widget = getNamedWidget(talkWidget, widgetName)
                if widget ~= nil then
                    widget:SetVisibility(DIALOGUE_VISIBLE)
                    if widget.SetRenderOpacity ~= nil then
                        widget:SetRenderOpacity(1)
                    end
                end
            end)
        end

        pcall(function()
            local canvasRow = getNamedWidget(talkWidget, "Canvas_Content03")
            local sizeRow = nil
            if canvasRow ~= nil then
                canvasRow:SetVisibility(DIALOGUE_VISIBLE)
                if canvasRow.SetRenderOpacity ~= nil then
                    canvasRow:SetRenderOpacity(1)
                end
                sizeRow = getNamedWidget(talkWidget, "SizeBox_3")
            else
                sizeRow = getNamedWidget(talkWidget, "SizeBox_2")
            end
            if sizeRow ~= nil then
                sizeRow:SetVisibility(DIALOGUE_VISIBLE)
                if sizeRow.SetRenderOpacity ~= nil then
                    sizeRow:SetRenderOpacity(1)
                end
                if sizeRow.SetHeightOverride ~= nil then
                    sizeRow:SetHeightOverride(DIALOGUE_ROW_HEIGHT)
                end
            end
        end)
    end
    return changed
end

local function reportDialogueThirdRowState(self)
    if self == nil or self.__cpddDialogueThirdRowReported == VERSION then
        return
    end
    self.__cpddDialogueThirdRowReported = VERSION
    local talkWidget = self.userWidget
    if talkWidget == nil then
        return
    end
    local states = {}
    for _, widgetName in ipairs({
        "Canvas_Content03", "SizeBox_2", "SizeBox_3",
        "RTB_TalkContent3_Back_lua", "RTB_TalkContent3_lua",
    }) do
        pcall(function()
            local widget = getNamedWidget(talkWidget, widgetName)
            if widget ~= nil then
                local visibility = widget.GetVisibility and tostring(widget:GetVisibility()) or "?"
                local opacity = widget.GetRenderOpacity and tostring(widget:GetRenderOpacity()) or "?"
                states[#states + 1] = widgetName .. "=" .. visibility .. "/" .. opacity
            end
        end)
    end
    report("dialogue third-row live state " .. table.concat(states, ","))
end

local function bindDialogueRows(self)
    local talkWidget = self and self.userWidget
    local printer = self and self.ContentPrinter
    if talkWidget == nil or printer == nil then
        return false
    end

    local widgetNames = {
        "RTB_TalkContent_Back_lua",
        "RTB_TalkContent_lua",
        "RTB_TalkContent2_Back_lua",
        "RTB_TalkContent2_lua",
        "RTB_TalkContent3_Back_lua",
        "RTB_TalkContent3_lua",
    }
    local widgets = {}
    local missing = {}
    for index, widgetName in ipairs(widgetNames) do
        widgets[index] = getNamedWidget(talkWidget, widgetName)
        if widgets[index] == nil then
            missing[#missing + 1] = widgetName
        end
    end

    local hasCoreRows = widgets[1] ~= nil and widgets[2] ~= nil
        and widgets[3] ~= nil and widgets[4] ~= nil
    local hasThirdLine = widgets[5] ~= nil and widgets[6] ~= nil
    self.__cpddDialogueHasThirdLine = hasThirdLine

    local ok = hasCoreRows and pcall(function()
        printer:BindWidget(
            widgets[1], widgets[2], widgets[3],
            widgets[4], widgets[5], widgets[6]
        )
        printer.LineMaxCharCount = DIALOGUE_LINE_MAX
        printer:SetEnableTwoLinePrinter(true)
    end)
    if #missing > 0 and self.__cpddDialogueWidgetLookupReported ~= VERSION then
        self.__cpddDialogueWidgetLookupReported = VERSION
        report("dialogue widget lookup missing " .. table.concat(missing, ","))
    elseif #missing == 0 and self.__cpddDialogueWidgetLookupReported ~= VERSION then
        self.__cpddDialogueWidgetLookupReported = VERSION
        report("dialogue third row bound from the live widget tree")
    end
    revealDialogueRows(self)
    return ok and hasThirdLine
end

local function configureDialogueLineCapacity(self, content)
    local printer = self and self.ContentPrinter
    if printer == nil then
        return DIALOGUE_LINE_MAX
    end
    local rows = self.__cpddDialogueHasThirdLine and 3 or 2
    local visibleLength = math.max(1, dialogueVisibleLength(content))
    local lineCapacity = math.max(DIALOGUE_LINE_MAX, math.ceil(visibleLength / rows))
    printer.LineMaxCharCount = lineCapacity
    return lineCapacity
end

local function installDialogueTalkRepair(value, environment)
    local dialogueTalk = getSymbol(value, environment, "DialogueTalk")
    if type(dialogueTalk) ~= "table" or dialogueTalk.__cpddEnglishLayoutRepair == VERSION then
        return false
    end

    local originalInitUIData = dialogueTalk.InitUIData
    local originalShowContent = dialogueTalk.ShowContent
    if type(originalInitUIData) ~= "function" or type(originalShowContent) ~= "function" then
        return false
    end

    dialogueTalk.InitUIData = function(self, ...)
        local results = { originalInitUIData(self, ...) }
        bindDialogueRows(self)
        return unpack(results)
    end

    dialogueTalk.ShowContent = function(self, content, ...)
        bindDialogueRows(self)
        local normalizedContent = normalizeDialogueWhitespace(content)
        self.__cpddDialogueWrappedContent = normalizedContent
        configureDialogueLineCapacity(self, normalizedContent)
        local results = { originalShowContent(self, normalizedContent, ...) }
        revealDialogueRows(self)
        scheduleRepairNextTick(self, revealDialogueRows)
        scheduleRepairAfter(self, 0.10, revealDialogueRows)
        scheduleRepairAfter(self, 0.50, revealDialogueRows)
        scheduleRepairAfter(self, 0.55, reportDialogueThirdRowState)
        translateViewTextWidgets(self and self.view, self and self.userWidget)
        return unpack(results)
    end

    dialogueTalk.__cpddEnglishLayoutRepair = VERSION
    report("installed dynamic multi-row English dialogue layout")
    return true
end

local function setLayeredDialogueLabel(owner, text)
    if owner == nil then
        return false
    end

    local changed = false
    local ok = pcall(function()
        owner:SetText(text)
    end)
    changed = changed or ok

    for _, fieldName in ipairs({ "Text_lua", "Text2_lua" }) do
        local fieldOk = pcall(function()
            local widget = owner[fieldName]
            if widget ~= nil then
                widget:SetText(text)
                changed = true
            end
        end)
        changed = changed or fieldOk
    end
    translateViewTextWidgets(nil, owner)
    return changed
end

local function setNamedWidgetText(owner, widgetName, text)
    if owner == nil then
        return false
    end

    local widget = getNamedWidget(owner, widgetName)
    if widget == nil then
        return false
    end

    local changed = false
    local setOk = pcall(function()
        widget:SetText(text)
    end)
    changed = changed or setOk
    local propertyOk = pcall(function()
        widget.Text = text
    end)
    changed = changed or propertyOk
    pcall(function()
        if widget.SynchronizeProperties ~= nil then
            widget:SynchronizeProperties()
        end
    end)
    pcall(function()
        if widget.InvalidateLayoutAndVolatility ~= nil then
            widget:InvalidateLayoutAndVolatility()
        end
    end)
    return changed
end

local function setPanelWidgetText(self, widgetName, text)
    local changed = false
    local view = self and self.view
    if view ~= nil then
        local widget = getNamedWidget(view, widgetName)
        if widget ~= nil then
            changed = pcall(function()
                widget:SetText(text)
            end) or changed
        end
    end
    return setNamedWidgetText(self and (self.userWidget or self.widget), widgetName, text) or changed
end

local function translateNamedContainers(view, root, names)
    local repaired = 0
    local seen = setmetatable({}, { __mode = "k" })
    for _, name in ipairs(names) do
        local container = getNamedWidget(view, name) or getNamedWidget(root, name)
        if container ~= nil and not seen[container] then
            seen[container] = true
            repaired = repaired + translateViewTextWidgets(nil, container)
        end
    end
    return repaired
end

local function repairSkillHeaderWidget(widget)
    if widget == nil then
        return false
    end
    local changed = false
    changed = setNamedWidgetText(widget, "Text_Recommend", "Recommended Builds") or changed
    changed = setNamedWidgetText(widget, "Text_Extra", "My Builds") or changed
    changed = setNamedWidgetText(widget, "Text_BeStrong", "Improve") or changed
    changed = setNamedWidgetText(widget, "KGTextBlock_54", "Recommended Builds") or changed
    translateNamedContainers(nil, widget, {
        "Canvas_BeStrong", "Canvas_Extraordinarily", "Canvas_Recommend", "HB_Btn",
    })
    translateViewTextWidgets(nil, widget)
    return changed
end

local skillImproveRepairLogged = false

local function reportSkillImproveRepair(self)
    if skillImproveRepairLogged then
        return
    end
    skillImproveRepairLogged = true

    local view = self and self.view
    local root = self and (self.userWidget or self.widget)
    local widget = getNamedWidget(view, "Text_BeStrong")
        or getNamedWidget(root, "Text_BeStrong")
    if widget == nil then
        local visited = setmetatable({}, { __mode = "k" })
        local function inspect(candidate)
            walkWidgetDescendants(candidate, visited, function(descendant)
                if widget ~= nil then
                    return
                end
                local ok, value = pcall(function()
                    return tostring(descendant:GetText())
                end)
                if ok and (value == "Improve" or value == "我要变强" or value == "要变强") then
                    widget = descendant
                end
            end)
        end
        inspect(getNamedWidget(view, "Canvas_BeStrong"))
        inspect(getNamedWidget(root, "Canvas_BeStrong"))
        if type(view) == "table" then
            for _, candidate in pairs(view) do
                inspect(candidate)
            end
        end
    end
    local value = "<not found>"
    if widget ~= nil then
        value = "<unreadable>"
        pcall(function()
            value = tostring(widget:GetText())
        end)
    end
    report("Improve caption verification found=" .. tostring(widget ~= nil) .. " value=" .. tostring(value))
end

local function repairSkillHeaderLabels(self)
    local view = self and self.view
    local root = self and (self.userWidget or self.widget)
    setPanelWidgetText(self, "Text_Recommend", "Recommended Builds")
    setPanelWidgetText(self, "Text_Extra", "My Builds")
    setPanelWidgetText(self, "Text_BeStrong", "Improve")
    translateNamedContainers(view, root, {
        "Canvas_BeStrong", "Canvas_Extraordinarily", "Canvas_Recommend", "HB_Btn",
    })
    translateViewTextWidgets(view, root)
    repairSkillHeaderWidget(root)
    scheduleRepairAfter(self, 3.00, reportSkillImproveRepair)
end

local function repairEmbeddedSkillHeaderLabels(self)
    if self == nil then
        return
    end
    local view = self.view
    local root = self.userWidget or self.widget
    local header = getNamedWidget(view, "WBP_Skill_BeStrong_Btn")
        or getNamedWidget(view, "WBP_Skill_BeStrong_Btn_lua")
        or getNamedWidget(root, "WBP_Skill_BeStrong_Btn")
        or getNamedWidget(root, "WBP_Skill_BeStrong_Btn_lua")
    translateNamedContainers(view, header or root, {
        "Canvas_BeStrong", "Canvas_Extraordinarily", "Canvas_Recommend", "HB_Btn",
    })
    repairSkillHeaderWidget(header)
end

local function repairSkillCommonLabels(self)
    local view = self and self.view
    if view == nil then
        return
    end
    setNamedWidgetText(view, "Text_WoodenPost", "Training Dummy")
    local oneClickPage = nil
    pcall(function()
        oneClickPage = view.WBP_Skill_OneClick_Page
    end)
    setNamedWidgetText(oneClickPage, "Text_Content", "One-Click Assist")
    repairEmbeddedSkillHeaderLabels(self)
    repairSkillHeaderLabels(self and self.WBP_Skill_BeStrong_BtnCom)
end

local function repairTalentLabels(self)
    setPanelWidgetText(self, "Text_Reset", "Reset All")
    repairEmbeddedSkillHeaderLabels(self)
end

local function repairEquipmentLabels(self)
    setPanelWidgetText(self, "Text_Equip", "Equipment Builds")
end

local function repairBagLabels(self)
    local autoDecomposeButton = self and self.view and self.view.AutoDecomposeBtn
    setNamedWidgetText(autoDecomposeButton, "TB_Word", "Auto-Dismantle")
end

local function repairSchemePlanItemLabels(self)
    setPanelWidgetText(self, "Text_Tips", "In Use")
end

local function repairSchemeUseLabels(self)
    setPanelWidgetText(self, "Text_BtnName", "Use")
    setPanelWidgetText(self, "Text_Tips", "In Use")
    setPanelWidgetText(self, "Text_Use", "Use")
    setPanelWidgetText(self, "Text_Using", "In Use")
end

local function repairScreenshotLabel(self)
    setPanelWidgetText(self, "Text_Name", "Screenshot")
end

local function repairLoginActivityLabels(self)
    local view = self and self.view
    local root = self and (self.userWidget or self.widget)
    setPanelWidgetText(self, "Text_FashionTitleDec_1", "Reward Preview")
    translateNamedContainers(view, root, {
        "Canvas_Reward", "Canvas_Title", "VB_MainTitle",
    })
    translateViewTextWidgets(view, root)
end

local function repairItemReceivedLabels(self)
    local view = self and self.view
    local root = self and (self.userWidget or self.widget)
    setPanelWidgetText(self, "text_center_lua", "Claimed")
    translateNamedContainers(view, root, { "Canvas_Received" })
    translateViewTextWidgets(view, root)
end

local function repairDiceResultLabels(self)
    local view = self and self.view
    local root = self and (self.userWidget or self.widget)
    translateNamedContainers(view, root, {
        "Canvas_ResultRoot", "Canvas_Content", "Canvas_GUI",
        "Canvas_SuccessText", "Canvas_BigSuccessText",
    })
    translateViewTextWidgets(view, root)
end

local function repairSkillUpgradeTipsLabels(self)
    local view = self and self.view
    local root = self and (self.userWidget or self.widget)
    setPanelWidgetText(self, "Text_Title_2", "Next-Level Effect")
    translateNamedContainers(view, root, {
        "VB_Content", "SizeBox_Content", "ScrollBox_Content",
    })
    translateViewTextWidgets(view, root)
end

local function repairSecretPartnerLabels(self)
    local view = self and self.view
    local root = self and (self.userWidget or self.widget)
    translateNamedContainers(view, root, {
        "PanelSlot", "Canvas_BaseAttribute", "Canvas_Content", "Canvas_Main",
    })
    translateViewTextWidgets(view, root)
end

local lastHuntLabelVerificationLogged = false

local function repairLastHuntMyDataLabels(self)
    setPanelWidgetText(self, "Text_Debris01", "Submit to earn Hunt Progress")
    setPanelWidgetText(self, "Text_Debris01_1", "Submit to earn Hunt Progress")
    setPanelWidgetText(self, "Text_Schedule", "Current Progress:")
    setPanelWidgetText(self, "Text_Title01", "Kills")
    setPanelWidgetText(self, "Text_Title02", "Assists")
    setPanelWidgetText(self, "Text_Rank", "Leaderboard")
    local view = self and self.view
    local root = self and (self.userWidget or self.widget)
    local containerNames = {
        "Canvas_MyData", "Canvas_Record", "Canvas_Task", "Canvas_RankBtn",
        "HB_MyData", "HB_Schedule", "HB_Task", "VB_MyData", "VB_Task",
        "VB_Tetx01", "VB_Tetx02", "VB_Tetx03",
    }
    translateNamedContainers(view, root, containerNames)
    translateViewTextWidgets(view, root)

    if not lastHuntLabelVerificationLogged then
        local expected = {
            ["Submit to earn Hunt Progress"] = true,
            ["Current Progress:"] = true,
            ["Kills"] = true,
            ["Assists"] = true,
            ["Leaderboard"] = true,
        }
        local observed = {}
        local unresolved = 0
        local visited = setmetatable({}, { __mode = "k" })
        local function inspect(widget)
            local ok, text = pcall(function()
                return tostring(widget:GetText())
            end)
            if not ok then
                return
            end
            if expected[text] then
                observed[text] = true
            elseif hasCjk and hasCjk(text) then
                unresolved = unresolved + 1
            end
        end
        for _, name in ipairs(containerNames) do
            walkWidgetDescendants(getNamedWidget(view, name) or getNamedWidget(root, name), visited, inspect)
        end
        local englishCount = 0
        for _ in pairs(observed) do
            englishCount = englishCount + 1
        end
        if englishCount == 5 then
            lastHuntLabelVerificationLogged = true
            report("Last Hunt painted-caption verification english=5 unresolvedChinese=" .. tostring(unresolved))
        end
    end
end

local function formatGroupedInteger(value)
    local number = tonumber(value)
    if number == nil then
        return tostring(value or "")
    end
    number = math.floor(number + 0.5)
    local sign = number < 0 and "-" or ""
    local grouped = tostring(math.abs(number))
    while true do
        local nextValue, replacements = grouped:gsub("^(%d+)(%d%d%d)", "%1,%2")
        grouped = nextValue
        if replacements == 0 then
            break
        end
    end
    return sign .. grouped
end

local function installLastHuntScoreFormatting(value, environment)
    local class = getSymbol(value, environment, "PVPLastHunt_Details_MyData")
    if type(class) ~= "table" or class.__cpddFullScoreFormatting == VERSION then
        return false
    end
    if type(class.FormatScoreTip) ~= "function" then
        return false
    end

    class.FormatScoreTip = function(_, number)
        return formatGroupedInteger(number)
    end
    class.__cpddFullScoreFormatting = VERSION
    report("installed full-number Last Hunt score formatting")
    return true
end

local function installCurrencyFormatting(value, environment)
    local class = getSymbol(value, environment, "CurrencyUtils")
    if type(class) ~= "table" or class.__cpddFullCurrencyFormatting == VERSION then
        return false
    end
    if type(class.GetGameMoneyFormat) ~= "function" then
        return false
    end
    local verificationReported = false
    class.GetGameMoneyFormat = function(number)
        assert(type(number) == "number", "Num not a number")
        if number < 100000 then
            return number
        end
        local formatted = formatGroupedInteger(number)
        if not verificationReported then
            verificationReported = true
            report("shared currency formatting verification output=" .. formatted)
        end
        return formatted
    end
    class.__cpddFullCurrencyFormatting = VERSION
    report("installed full-number shared currency formatting")
    return true
end

local function repairDialoguePanelLabels(self)
    local view = self and self.view
    if type(view) ~= "table" then
        return
    end

    setLayeredDialogueLabel(view.WBP_NPCReviewBtn, "Review")

    local skipOwner = view.WBP_Skip
    if skipOwner ~= nil then
        local ok, nested = pcall(function()
            return skipOwner.WBP_NPCBtnText_lua
        end)
        setLayeredDialogueLabel(ok and nested or skipOwner, "Skip")
    end
end

local function repairDialogueSkipLabels(self)
    local view = self and self.view
    if type(view) ~= "table" then
        return
    end
    setLayeredDialogueLabel(view.WBP_NPCBtnText_lua, "Skip")
end

local function installDialogueControlRepair(value, environment, symbolName, methodNames, repair, source)
    local class = getSymbol(value, environment, symbolName)
    if type(class) ~= "table" then
        return false
    end

    local marker = "__cpddDialogueControlRepair_" .. VERSION
    if class[marker] then
        return true
    end

    local wrapped = 0
    for _, methodName in ipairs(methodNames) do
        local original = class[methodName]
        if type(original) == "function" then
            class[methodName] = function(self, ...)
                local results = { original(self, ...) }
                repair(self)
                scheduleRepairNextTick(self, repair)
                scheduleRepairAfter(self, 0.05, repair)
                scheduleRepairAfter(self, 0.20, repair)
                scheduleRepairAfter(self, 0.75, repair)
                return unpack(results)
            end
            wrapped = wrapped + 1
        end
    end

    class[marker] = true
    if wrapped > 0 then
        report("installed exact English dialogue controls for " .. source)
    end
    return wrapped > 0
end

local function installExactWidgetRepair(value, environment, symbolName, methodNames, repair, source)
    local class = getSymbol(value, environment, symbolName)
    if type(class) ~= "table" then
        return false
    end

    local marker = "__cpddExactWidgetRepair_" .. VERSION
    if class[marker] then
        return true
    end

    local wrapped = 0
    for _, methodName in ipairs(methodNames) do
        local original = class[methodName]
        if type(original) == "function" then
            class[methodName] = function(self, ...)
                local results = { original(self, ...) }
                repair(self)
                scheduleRepairNextTick(self, repair)
                scheduleRepairAfter(self, 0.05, repair)
                scheduleRepairAfter(self, 0.20, repair)
                scheduleRepairAfter(self, 0.75, repair)
                scheduleRepairAfter(self, 1.50, repair)
                return unpack(results)
            end
            wrapped = wrapped + 1
        end
    end

    class[marker] = true
    if wrapped > 0 then
        report("installed exact English widget labels for " .. source)
    end
    return wrapped > 0
end
local creatorChoiceLabels = {
    [1] = { "Madness", "Sanity" },
    [2] = { "Wisdom", "Power" },
    [3] = { "Glory", "Emotion" },
}

local function promoteCreatorChoiceLabel(container, firstName, secondName, promotedName, text)
    if container == nil then
        return false
    end

    local first = getNamedWidget(container, firstName)
    local second = getNamedWidget(container, secondName)
    local promoted = getNamedWidget(container, promotedName)
    if promoted == nil then
        return false
    end
    setNamedWidgetText(container, firstName, "")
    setNamedWidgetText(container, secondName, "")
    setNamedWidgetText(container, promotedName, text)
    local font = nil
    local color = nil
    pcall(function()
        if first ~= nil and first.GetFont ~= nil then
            font = first:GetFont()
        elseif first ~= nil then
            font = first.Font
        end
    end)
    pcall(function()
        if first ~= nil and first.GetColorAndOpacity ~= nil then
            color = first:GetColorAndOpacity()
        elseif first ~= nil then
            color = first.ColorAndOpacity
        end
    end)
    if font ~= nil then
        pcall(function() promoted.Font = font end)
        pcall(function()
            if promoted.SetFont ~= nil then promoted:SetFont(font) end
        end)
    end
    if color ~= nil then
        pcall(function() promoted.ColorAndOpacity = color end)
        pcall(function()
            if promoted.SetColorAndOpacity ~= nil then promoted:SetColorAndOpacity(color) end
        end)
    end

    pcall(function()
        if promoted.SetRenderOpacity ~= nil then promoted:SetRenderOpacity(1) end
    end)
    pcall(function()
        if promoted.SetLetterSpacing ~= nil then promoted:SetLetterSpacing(0) end
    end)
    pcall(function()
        if promoted.SetRenderTranslation ~= nil then
            promoted:SetRenderTranslation(FVector2D(-50, 0))
        end
    end)
    pcall(function()
        if promoted.Slot ~= nil and promoted.Slot.SetPadding ~= nil then
            promoted.Slot:SetPadding(FMargin(0, 0, 0, 0))
        end
    end)
    pcall(function()
        if promoted.SynchronizeProperties ~= nil then promoted:SynchronizeProperties() end
    end)
    pcall(function()
        if promoted.InvalidateLayoutAndVolatility ~= nil then
            promoted:InvalidateLayoutAndVolatility()
        end
    end)
    return true
end

local function repairCreateRoleChoiceLabels(self)
    local labels = creatorChoiceLabels[tonumber(self and self.nowIndex)]
    local view = self and self.view
    if labels == nil or view == nil then
        return false
    end

    local left = getNamedWidget(view, "WBP_CreateRole_Answer_Sub01")
    local right = getNamedWidget(view, "WBP_CreateRole_Answer_Sub02")
    local changed = promoteCreatorChoiceLabel(
        left,
        "Text_Answer_Text01_L",
        "Text_Answer_Text02_L",
        "Text_Answer_TheLeon01_L",
        labels[1]
    )
    changed = promoteCreatorChoiceLabel(
        right,
        "Text_Answer_Text01_R",
        "Text_Answer_Text02_R",
        "Text_Answer_TheLeon01_R",
        labels[2]
    ) or changed
    return changed
end

local function compactOverallGraphicsChoices(self)
    if self == nil or type(self.ChoiceListData) ~= "table" then
        return false
    end
    local overallConst = nil
    pcall(function()
        overallConst = Enum.ESettingConstData.OVERALL_SCALABILITY_LEVEL
    end)
    if overallConst == nil or self.MetaData == nil or self.MetaData.Const_1 ~= overallConst then
        return false
    end

    self.bTextLengthExceed = false
    for _, choice in pairs(self.ChoiceListData) do
        if type(choice) == "table" then
            choice.bTextLengthExceed = false
        end
    end

    local list = self.Hori_ChoiceCom
    if list ~= nil and type(list.Refresh) == "function" then
        pcall(list.Refresh, list, self.ChoiceListData)
        if type(self.UpdateData) == "function" then
            pcall(self.UpdateData, self, false)
        end
        return true
    end
    return false
end

local function installSettingsPresetLayoutRepair(value, environment)
    local class = getSymbol(value, environment, "Settings_Option_Item")
    if type(class) ~= "table" or class.__cpddCompactGraphicsPresets == VERSION then
        return false
    end
    local originalRefresh = class.Refresh
    if type(originalRefresh) ~= "function" then
        return false
    end

    class.Refresh = function(self, ...)
        local results = { originalRefresh(self, ...) }
        compactOverallGraphicsChoices(self)
        return unpack(results)
    end
    class.__cpddCompactGraphicsPresets = VERSION
    report("installed compact overall graphics preset row")
    return true
end

local viewRepairSpecs = {
    {
        "Gameplay.LogicSystem.SkillCustomizer.Main.SkillCommon_Panel",
        "SkillCommon_Panel",
        { "OnRefresh", "RefreshBeStrongArea" },
    },
    {
        "Gameplay.LogicSystem.SkillCustomizer.Main.Skill_BeStrong_Btn",
        "Skill_BeStrong_Btn",
        { "Refresh", "UpdateState" },
    },
    {
        "Gameplay.LogicSystem.SkillCustomizer.Main.Secret.Skill_Secret_Detail",
        "Skill_Secret_Detail",
        { "Refresh", "RefreshSkillInfo", "IShowSkillDesc" },
    },
    {
        "Gameplay.LogicSystem.Guild.GuildInside.Members.GuildInside_Permission_Panel.GuildInside_Permission_Panel",
        "GuildInside_Permission_Panel",
        { "OnRefresh", "OnReceiveGuildRights", "RefreshRightsData" },
    },
    {
        "Gameplay.LogicSystem.Task.New.Task_Main_Panel",
        "Task_Main_Panel",
        { "OnRefresh", "refreshTabList" },
    },
}

local exactWidgetRepairSpecs = {
    {
        "Gameplay.LogicSystem.CreateRole.CreateRoleAnswer_Panel",
        "CreateRoleAnswer_Panel",
        { "setChooseInfo" },
        repairCreateRoleChoiceLabels,
    },
    {
        "Gameplay.LogicSystem.NPC.NPCBtnCut",
        "NPCBtnCut",
        { "InitUIView", "Refresh" },
        repairScreenshotLabel,
    },
    {
        "Gameplay.LogicSystem.LoginPopUp.LoginActivityPopUp_Panel",
        "LoginActivityPopUp_Panel",
        { "InitUIView", "OnRefresh", "on_KGListViewCom_ItemSelected", "ShowTitle" },
        repairLoginActivityLabels,
    },
    {
        "Gameplay.LogicSystem.Item.NewUI.ItemTagCenter",
        "ItemTagCenter",
        { "SetData" },
        repairItemReceivedLabels,
    },
    {
        "Gameplay.LogicSystem.DiceRollV2.Panels.DiceRollV2_Result_Succ_Panel",
        "DiceRollV2_Result_Succ_Panel",
        { "InitUIView", "OnRefresh", "PlaySuccessAnim" },
        repairDiceResultLabels,
    },
    {
        "Gameplay.LogicSystem.DiceRollV2.Panels.DiceRollV2_Result_SuccessDefault",
        "DiceRollV2_Result_SuccessDefault",
        { "InitUIView", "Refresh" },
        repairDiceResultLabels,
    },
    {
        "Gameplay.LogicSystem.SkillCustomizer.Main.SkillUpgradeTips_Panel",
        "SkillUpgradeTips_Panel",
        { "InitUIView", "OnRefresh", "SetContent" },
        repairSkillUpgradeTipsLabels,
    },
    {
        "Gameplay.LogicSystem.SecretPartner.SecretPartner_Panel",
        "SecretPartner_Panel",
        {
            "InitUIView", "OnRefresh", "OnShow", "RefreshMainTab",
            "on_WBP_SecretPuppetTabListCom_ItemSelected",
        },
        repairSecretPartnerLabels,
    },
    {
        "Gameplay.LogicSystem.SecretPartner.Base.SecretPartnerBase_Sub",
        "SecretPartnerBase_Sub",
        {
            "InitUIView", "Refresh", "RefreshPartnerItemListPanel",
            "RefreshPartnerItemList", "RefreshSecretPartnerSelectedState",
        },
        repairSecretPartnerLabels,
    },
    {
        "Gameplay.LogicSystem.SkillCustomizer.Main.Skill_BeStrong_Btn",
        "Skill_BeStrong_Btn",
        { "InitUIView", "Refresh", "UpdateState" },
        repairSkillHeaderLabels,
    },
    {
        "Gameplay.LogicSystem.SkillCustomizer.Main.SkillCommon_Panel",
        "SkillCommon_Panel",
        { "InitUIView", "OnRefresh", "InitSkillCustomizer", "RefreshBeStrongArea" },
        repairSkillCommonLabels,
    },
    {
        "Gameplay.LogicSystem.Talent.Talent_Panel",
        "Talent_Panel",
        {
            "InitUIView", "OnRefresh", "OnOpen", "OnShow", "Refresh",
            "RefreshView", "refreshOneClickStatus", "refreshEnableStatus",
        },
        repairTalentLabels,
    },
    {
        "Gameplay.LogicSystem.Equipment.Reform.EquipmentForging_Plan_Panel",
        "EquipmentForging_Plan_Panel",
        { "InitUIView", "OnRefresh", "OnOpen", "OnShow", "Refresh", "RefreshView", "UpdateUI" },
        repairEmbeddedSkillHeaderLabels,
    },
    {
        "Gameplay.LogicSystem.PlayerDetails.ExtraordinaryScore.ExtraordinaryScore_Panel",
        "ExtraordinaryScore_Panel",
        { "InitUIView", "OnRefresh", "OnOpen", "OnShow", "Refresh", "RefreshView", "UpdateUI" },
        repairEmbeddedSkillHeaderLabels,
    },
    {
        "Gameplay.LogicSystem.PlayerDetails.PlayerTotal_Panel",
        "PlayerTotal_Panel",
        { "InitUIView", "OnRefresh", "OnOpen", "OnShow", "Refresh", "RefreshView", "UpdateUI" },
        repairEmbeddedSkillHeaderLabels,
    },
    {
        "Gameplay.LogicSystem.Sealed_2.Sealed_Main_Panel",
        "Sealed_Main_Panel",
        { "InitUIView", "OnRefresh", "OnOpen", "OnShow", "Refresh", "RefreshView", "UpdateUI" },
        repairEmbeddedSkillHeaderLabels,
    },
    {
        "Gameplay.LogicSystem.Equipment.Equipment_Panel",
        "Equipment_Panel",
        { "InitUIView", "OnRefresh", "RefreshCurrentTabPage" },
        repairEquipmentLabels,
    },
    {
        "Gameplay.LogicSystem.Bag.MainBag.Bag_Panel",
        "Bag_Panel",
        { "InitUIView", "OnRefresh", "UpdateAutoDecomposeBtn", "UpdateAutoDecomposeOpenSwitch" },
        repairBagLabels,
    },
    {
        "Gameplay.LogicSystem.SkillCustomizer.SchemePlan.Scheme_Plan_Item",
        "Scheme_Plan_Item",
        { "InitUIView", "OnRefresh" },
        repairSchemePlanItemLabels,
    },
    {
        "Gameplay.LogicSystem.SkillCustomizer.OneClick.OneClick_Plan_Item",
        "OneClick_Plan_Item",
        { "InitUIView", "OnRefresh", "SetAsDefault", "UpdateEquip" },
        repairSchemePlanItemLabels,
    },
    {
        "Gameplay.LogicSystem.SkillCustomizer.OneClick.OneClick_PlanType_Tab_Item",
        "OneClick_PlanType_Tab_Item",
        { "InitUIView", "OnRefresh", "Refresh", "UpdateEquip", "UpdateUse" },
        repairSchemeUseLabels,
    },
    {
        "Gameplay.LogicSystem.SkillCustomizer.SchemeAssembly.Scheme_CustomPlan_Item",
        "Scheme_CustomPlan_Item",
        { "InitUIView", "OnRefresh", "SetAsAddPlan", "UpdateSelectionState" },
        repairSchemeUseLabels,
    },
    {
        "Gameplay.LogicSystem.SkillCustomizer.SchemeAssembly.Scheme_CustomPlan_Equipment_Item",
        "Scheme_CustomPlan_Equipment_Item",
        { "InitUIView", "OnRefresh", "SetAsAddPlan", "UpdateSelectionState" },
        repairSchemeUseLabels,
    },
    {
        "Gameplay.LogicSystem.Equipment.Wear.Equipment_Wear_Attribute_Item",
        "Equipment_Wear_Attribute_Item",
        { "InitUIView", "OnRefresh", "Refresh", "UpdateUse", "SetUse" },
        repairSchemeUseLabels,
    },
    {
        "Gameplay.LogicSystem.Equipment.Wear.Equipment_Wear_Suit_Item",
        "Equipment_Wear_Suit_Item",
        { "InitUIView", "OnRefresh", "Refresh", "UpdateUse", "SetUse" },
        repairSchemeUseLabels,
    },
    {
        "Gameplay.LogicSystem.HUD.HUD_PVPLastHunt.PVPLastHunt_Details_MyData",
        "PVPLastHunt_Details_MyData",
        { "InitUIView", "OnRefresh", "RefreshBasicInfo", "RefreshRewardInfo" },
        repairLastHuntMyDataLabels,
    },
}

local dataRepairSpecs = {
    {
        "Framework.KGFramework.KGUI.Component.Select.UIComDropDown",
        "UIComDropDown",
        { "Refresh", "refreshOptionsList", "refreshOptionBtn" },
    },
    {
        "Framework.KGFramework.KGUI.Component.Select.UIComDropDownItem",
        "UIComDropDownItem",
        { "OnRefresh", "SetName" },
    },
    {
        "Framework.KGFramework.KGUI.Component.Tab.UIComTabList",
        "UIComTabList",
        { "Refresh" },
    },
    {
        "Framework.KGFramework.KGUI.Component.Tab.UIComSimpleTabList",
        "UIComSimpleTabList",
        { "Refresh" },
    },
    {
        "Framework.KGFramework.KGUI.Component.Tab.UIComTabItem",
        "UIComTabItem",
        { "OnRefresh" },
    },
}

local function registerViewRepair(spec)
    local moduleName, symbolName, methodNames = spec[1], spec[2], spec[3]
    Loader.AfterLoad(moduleName, function(value, environment)
        installViewMethodRepair(value, environment, symbolName, methodNames, moduleName)
        return value
    end, 1000000, "cpdd.runtime-fix.view." .. moduleName:gsub("[^%w]", "-"))
end

local function registerDataRepair(spec)
    local moduleName, symbolName, methodNames = spec[1], spec[2], spec[3]
    Loader.AfterLoad(moduleName, function(value, environment)
        installDataMethodRepair(value, environment, symbolName, methodNames, moduleName)
        return value
    end, 1000000, "cpdd.runtime-fix.data." .. moduleName:gsub("[^%w]", "-"))
end


local function registerExactWidgetRepair(spec)
    local moduleName, symbolName, methodNames, repair = spec[1], spec[2], spec[3], spec[4]
    Loader.AfterLoad(moduleName, function(value, environment)
        installExactWidgetRepair(value, environment, symbolName, methodNames, repair, moduleName)
        return value
    end, 1000000, "cpdd.runtime-fix.exact-widget." .. moduleName:gsub("[^%w]", "-"))
end

for _, spec in ipairs(viewRepairSpecs) do
    registerViewRepair(spec)
end
for _, spec in ipairs(dataRepairSpecs) do
    registerDataRepair(spec)
end
for _, spec in ipairs(exactWidgetRepairSpecs) do
    registerExactWidgetRepair(spec)
end

Loader.AfterLoad("Gameplay.LogicSystem.Guild.GuildSystem", function(value, environment)
    installGuildRoleRepair(value, environment)
    return value
end, 1000000, "cpdd.runtime-fix.guild-role-names")

Loader.AfterLoad("Gameplay.LogicSystem.Settings.Settings_Option_Item", function(value, environment)
    installSettingsPresetLayoutRepair(value, environment)
    return value
end, 1000000, "cpdd.runtime-fix.compact-graphics-presets")

Loader.AfterLoad("Gameplay.LogicSystem.HUD.HUD_PVPLastHunt.PVPLastHunt_Details_MyData", function(value, environment)
    installLastHuntScoreFormatting(value, environment)
    return value
end, 1000000, "cpdd.runtime-fix.last-hunt-score-format")

Loader.AfterLoad("Gameplay.LogicSystem.Utils.CurrencyUtils", function(value, environment)
    installCurrencyFormatting(value, environment)
    return value
end, 1000000, "cpdd.runtime-fix.currency-number-format")

Loader.AfterLoad("Gameplay.LogicSystem.NPC.Dialogue.DialogueTalk", function(value, environment)
    installDialogueTalkRepair(value, environment)
    return value
end, 1000000, "cpdd.runtime-fix.dialogue-layout")

Loader.AfterLoad("Gameplay.LogicSystem.NPC.Dialogue.Dialogue_Panel", function(value, environment)
    installDialogueControlRepair(
        value,
        environment,
        "Dialogue_Panel",
        {
            "InitUIView", "OnRefresh", "OnOpen", "RefreshPCModeKeyPrompt",
            "SetReviewButtonVisible", "SetSkipButtonVisible",
        },
        repairDialoguePanelLabels,
        "Dialogue_Panel"
    )
    return value
end, 1000000, "cpdd.runtime-fix.dialogue-panel-controls")

Loader.AfterLoad("Gameplay.LogicSystem.NPC.Dialogue.Dialogue_NPCBtnSkip", function(value, environment)
    installDialogueControlRepair(
        value,
        environment,
        "Dialogue_NPCBtnSkip",
        { "InitUIView", "Refresh" },
        repairDialogueSkipLabels,
        "Dialogue_NPCBtnSkip"
    )
    return value
end, 1000000, "cpdd.runtime-fix.dialogue-skip-controls")

local function installLateRenderedTextRepairs()
    local ok, module = pcall(kg_require, "Data.Excel.WidgetBlueprintTextData")
    if ok then
        repairWidgetBlueprintTextData(module, nil, "cached module")
    end

    ok, module = pcall(kg_require, "Gameplay.LogicSystem.SkillCustomizer.SkillCustomSystem")
    if ok then
        installSkillDescriptionRepair(module)
    end

    ok, module = pcall(kg_require, "Gameplay.LogicSystem.Guild.GuildSystem")
    if ok then
        installGuildRoleRepair(module)
    end

    ok, module = pcall(kg_require, "Gameplay.LogicSystem.Settings.Settings_Option_Item")
    if ok then
        installSettingsPresetLayoutRepair(module)
    end

    ok, module = pcall(kg_require, "Gameplay.LogicSystem.HUD.HUD_PVPLastHunt.PVPLastHunt_Details_MyData")
    if ok then
        installLastHuntScoreFormatting(module)
    end

    ok, module = pcall(kg_require, "Gameplay.LogicSystem.Utils.CurrencyUtils")
    if ok then
        installCurrencyFormatting(module)
    end

    ok, module = pcall(kg_require, "Gameplay.LogicSystem.NPC.Dialogue.DialogueTalk")
    if ok then
        installDialogueTalkRepair(module)
    end

    ok, module = pcall(kg_require, "Gameplay.LogicSystem.NPC.Dialogue.Dialogue_Panel")
    if ok then
        installDialogueControlRepair(
            module,
            nil,
            "Dialogue_Panel",
            {
                "InitUIView", "OnRefresh", "OnOpen", "RefreshPCModeKeyPrompt",
                "SetReviewButtonVisible", "SetSkipButtonVisible",
            },
            repairDialoguePanelLabels,
            "Dialogue_Panel"
        )
    end

    ok, module = pcall(kg_require, "Gameplay.LogicSystem.NPC.Dialogue.Dialogue_NPCBtnSkip")
    if ok then
        installDialogueControlRepair(
            module,
            nil,
            "Dialogue_NPCBtnSkip",
            { "InitUIView", "Refresh" },
            repairDialogueSkipLabels,
            "Dialogue_NPCBtnSkip"
        )
    end

    for _, spec in ipairs(viewRepairSpecs) do
        ok, module = pcall(kg_require, spec[1])
        if ok then
            installViewMethodRepair(module, nil, spec[2], spec[3], spec[1])
        end
    end
    for _, spec in ipairs(dataRepairSpecs) do
        ok, module = pcall(kg_require, spec[1])
        if ok then
            installDataMethodRepair(module, nil, spec[2], spec[3], spec[1])
        end
    end
    for _, spec in ipairs(exactWidgetRepairSpecs) do
        ok, module = pcall(kg_require, spec[1])
        if ok then
            installExactWidgetRepair(module, nil, spec[2], spec[3], spec[4], spec[1])
        end
    end
end

local function installShortMenuLabels()
    local ok, module = pcall(kg_require, "Gameplay.LogicSystem.Menu.MenuBtn_Item")
    local class = ok and module and module.MenuBtn_Item or nil
    if type(class) ~= "table" or type(class.OnRefresh) ~= "function" then
        report("short menu labels are waiting for MenuBtn_Item")
        return false
    end
    if class.__cpddShortMenuLabels then
        return true
    end

    local originalRefresh = class.OnRefresh
    class.OnRefresh = function(self, params)
        local results = { originalRefresh(self, params) }
        local menuId = self.MenuID
        local menuData = menuId and Game and Game.TableData and Game.TableData.GetMenuDataRow(menuId)
        local label = menuData and shortMenuLabels[menuData.ButtonEnum]
        if label and self.view and self.view.Text_Name then
            self.view.Text_Name:SetText(label)
        end
        return unpack(results)
    end
    class.__cpddShortMenuLabels = true
    report("installed compact English menu labels")
    return true
end

local function statisticsEverywhereEnabled()
    local loader = rawget(_G, "LOMModLoader")
    local features = loader and loader.Features
    if type(features) ~= "table" then
        return true
    end
    return features.StatisticsEverywhere ~= false
end

local function installStatisticsEverywhereTarget(target, label)
    if type(target) ~= "table" then
        return false
    end
    if rawget(target, "__cpddStatisticsEverywhereVersion") == VERSION then
        return true
    end

    local original = rawget(target, "CheckSwitchMapStats")
    if type(original) ~= "function" then
        return false
    end

    target.CheckSwitchMapStats = function(...)
        if statisticsEverywhereEnabled() then
            return true
        end
        return original(...)
    end
    target.__cpddStatisticsEverywhereVersion = VERSION
    report("installed Statistics button everywhere hook for " .. tostring(label))
    return true
end

local function installStatisticsEverywhere(value, environment)
    local installed = false
    if type(value) == "table" then
        installed = installStatisticsEverywhereTarget(value, "module") or installed
        installed = installStatisticsEverywhereTarget(rawget(value, "HUDMiddleMenuCheck"), "module.HUDMiddleMenuCheck") or installed
    end
    if type(environment) == "table" and environment ~= value then
        installed = installStatisticsEverywhereTarget(environment, "environment") or installed
        installed = installStatisticsEverywhereTarget(rawget(environment, "HUDMiddleMenuCheck"), "environment.HUDMiddleMenuCheck") or installed
    end
    return value
end

local function setStatisticsEverywhere(enabled)
    local loader = rawget(_G, "LOMModLoader")
    if loader == nil then
        loader = { Features = {} }
        rawset(_G, "LOMModLoader", loader)
    elseif type(loader.Features) ~= "table" then
        loader.Features = {}
    end
    loader.Features.StatisticsEverywhere = enabled == true

    pcall(function()
        if Game and Game.HUDMiddleMenuSystem and Enum and Enum.EHUD_MiddleMenu then
            Game.HUDMiddleMenuSystem:UpdateMiddleMenuBtn(Enum.EHUD_MiddleMenu.SwitchMapStats)
        end
    end)
    return loader.Features.StatisticsEverywhere
end

Loader.AfterLoad(
    "Gameplay.LogicSystem.HUD.HUD_MiddleBtnContent.HUDMiddleMenuCheck",
    installStatisticsEverywhere,
    1000000,
    "cpdd.runtime-fix.statistics-everywhere"
)

Loader.On("after_main", function()
    installShortMenuLabels()
    installLateRenderedTextRepairs()
    local ok, module = pcall(kg_require, "Gameplay.LogicSystem.HUD.HUD_MiddleBtnContent.HUDMiddleMenuCheck")
    if ok then
        installStatisticsEverywhere(module)
    end
    end, 1500, "cpdd.runtime-fix.translation-layout")

do
    local ok, registerAudit = pcall(require, "mods.cpdd_runtime_fixes.RuntimeStaticAudit")
    if ok and type(registerAudit) == "function" then
        local registered, auditError = pcall(
            registerAudit,
            Loader,
            repairLiveString,
            hasCjk,
            report,
            VERSION,
            STATIC_AUDIT_ID
        )
        if not registered then
            report("static translation audit registration failed: " .. tostring(auditError))
        end
    else
        report("static translation audit module unavailable: " .. tostring(registerAudit))
    end
end

do
    local ok, registerAudit = pcall(require, "mods.cpdd_runtime_fixes.RuntimeFullCorpusAudit")
    if ok and type(registerAudit) == "function" then
        local registered, auditError = pcall(
            registerAudit,
            Loader,
            hasCjk,
            report,
            VERSION,
            STATIC_AUDIT_ID
        )
        if not registered then
            report("full corpus audit registration failed: " .. tostring(auditError))
        end
    else
        report("full corpus audit module unavailable: " .. tostring(registerAudit))
    end
end

report("registered v" .. VERSION)
return {
    Version = VERSION,
    RepairLiveText = repairLiveString,
    SetStatisticsEverywhere = setStatisticsEverywhere,
    IsStatisticsEverywhereEnabled = statisticsEverywhereEnabled,
    }
