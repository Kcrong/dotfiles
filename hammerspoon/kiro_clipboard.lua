-- ~/.hammerspoon/kiro_clipboard.lua
-- 선택된 텍스트를 자동 복사 → kiro-cli 로 처리 → 결과를 클립보드에 덮어쓰기.
-- 여러 agent별로 각각 다른 hotkey를 바인딩할 수 있음.
--
-- 기본 바인딩:
--   Cmd+Shift+C  → translator  (번역)
--   Cmd+Opt+C    → tutor       (영어 첨삭)

local M = {}

local SCRIPT_PATH = os.getenv("HOME") .. "/bin/kiro-clipboard.sh"
local COPY_WAIT_MS = 500 -- Cmd+C 발송 후 클립보드 반영 대기
local MOD_TIMEOUT_MS = 1000 -- modifier release 대기 최대 시간

-- ──────────────────────────────────────────────────────────────────
-- UI helpers
-- ──────────────────────────────────────────────────────────────────
local function showHUD(text, opts, seconds)
	local base = {
		strokeColor = { white = 1, alpha = 0.3 },
		fillColor = { white = 0, alpha = 0.8 },
		textColor = { white = 1, alpha = 1 },
		textSize = 18,
		radius = 12,
	}
	for k, v in pairs(opts or {}) do
		base[k] = v
	end
	return hs.alert.show(text, base, seconds or 2)
end

local function notifyError(title, text)
	hs.notify
		.new({
			title = "Kiro CLI",
			subTitle = title,
			informativeText = text,
			soundName = "Basso",
			withdrawAfter = 0,
		})
		:send()
end

-- ──────────────────────────────────────────────────────────────────
-- 실제 물리 modifier 키가 모두 해제될 때까지 기다린 후 콜백 실행.
-- 글로벌 핫키 콜백 안에서 synthetic keyStroke를 발사할 때 필수.
-- ──────────────────────────────────────────────────────────────────
local function waitForModifierRelease(callback)
	local start = hs.timer.absoluteTime()
	local check
	check = function()
		local mods = hs.eventtap.checkKeyboardModifiers()
		local held = mods.cmd or mods.shift or mods.alt or mods.ctrl or mods.fn
		local elapsedMs = (hs.timer.absoluteTime() - start) / 1e6
		if not held or elapsedMs > MOD_TIMEOUT_MS then
			callback()
		else
			hs.timer.doAfter(0.02, check)
		end
	end
	check()
end

-- ──────────────────────────────────────────────────────────────────
-- 선택 텍스트를 Cmd+C로 복사하고 결과를 감지.
--   callback(true, content)   — 텍스트 복사 성공
--   callback(false, reason)   — "no-op" (선택 없음) / "non-text" (이미지 등)
-- 실패 시 원본 클립보드를 복원.
-- ──────────────────────────────────────────────────────────────────
local function copySelectionAsync(callback)
	local original = hs.pasteboard.getContents() or ""
	local sentinel = "__KIRO_SENTINEL_" .. tostring(hs.timer.absoluteTime()) .. "__"
	hs.pasteboard.setContents(sentinel)
	local countAfterSentinel = hs.pasteboard.changeCount()

	waitForModifierRelease(function()
		hs.eventtap.keyStroke({ "cmd" }, "c")

		hs.timer.doAfter(COPY_WAIT_MS / 1000, function()
			local content = hs.pasteboard.getContents() or ""
			local delta = hs.pasteboard.changeCount() - countAfterSentinel
			local isSentinel = (content == sentinel)

			if delta >= 1 and not isSentinel and content ~= "" then
				callback(true, content)
			elseif delta >= 1 and isSentinel then
				hs.pasteboard.setContents(original)
				callback(false, "non-text")
			else
				hs.pasteboard.setContents(original)
				callback(false, "no-op")
			end
		end)
	end)
end

-- ──────────────────────────────────────────────────────────────────
-- agent 이름별로 실행 함수를 만드는 팩토리.
-- ──────────────────────────────────────────────────────────────────
local function makeRunner(agent, displayName)
	return function()
		copySelectionAsync(function(copied, contentOrReason)
			if not copied then
				local msg = contentOrReason == "non-text" and "⚠️  Non-text selection" or "⚠️  No selection"
				showHUD(msg, {
					fillColor = { red = 0.5, green = 0.4, blue = 0.1, alpha = 0.85 },
				}, 1.5)
				return
			end

			local hudUUID = showHUD("🔄 Kiro " .. displayName .. "...", nil, 10)

			local task = hs.task.new(SCRIPT_PATH, function(exitCode, stdOut, stdErr)
				hs.alert.closeSpecific(hudUUID)
				if exitCode == 0 then
					showHUD("✅ " .. displayName .. " → clipboard", {
						textSize = 16,
						fillColor = { red = 0.1, green = 0.5, blue = 0.2, alpha = 0.85 },
						textColor = { white = 1 },
					}, 1.5)
				else
					local errMsg = ((stdErr ~= "" and stdErr) or stdOut or "Unknown"):sub(1, 200)
					notifyError("Failed ✗ (" .. agent .. ")", errMsg)
					showHUD("❌ Kiro " .. displayName .. " failed", {
						textSize = 16,
						fillColor = { red = 0.6, green = 0.1, blue = 0.1, alpha = 0.85 },
						textColor = { white = 1 },
					}, 2)
				end
			end, { agent }) -- 두 번째 인자: hs.task 에 전달할 argv

			if task then
				task:start()
			else
				hs.alert.closeSpecific(hudUUID)
				notifyError("Failed ✗", "Could not start " .. SCRIPT_PATH)
			end
		end)
	end
end

-- ──────────────────────────────────────────────────────────────────
-- 바인딩 테이블. 새 agent 추가 시 여기에 한 줄만 추가하면 됨.
-- ──────────────────────────────────────────────────────────────────
local bindings = {
	{ mods = { "cmd", "shift" }, key = "c", agent = "translator", label = "Translate" },
	{ mods = { "cmd", "alt" }, key = "c", agent = "tutorclipboard", label = "Tutor" },
}

M.hotkeys = {}
for _, b in ipairs(bindings) do
	table.insert(M.hotkeys, hs.hotkey.bind(b.mods, b.key, makeRunner(b.agent, b.label)))
end

return M
