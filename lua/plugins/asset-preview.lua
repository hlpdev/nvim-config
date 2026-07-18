-- Asset preview: in the snacks explorer, <cr> on a game-dev asset opens the
-- respective external viewer instead of dumping binary into a buffer.
--
-- Konsole can't render inline (no Kitty graphics / Sixel), so each
-- type is routed to a detached external program:
--   images -> qimgv     audio -> mpv --no-video (tracked, stoppable)
--   video  -> mpv       models -> f3d
--
-- Keymaps:
--   <cr>        play / open the asset under the cursor (in the explorer)
--   <leader>s   stop the currently playing audio
--
-- Edit the `viewers` table to swap programs (e.g. qimgv -> gwenview).

-- ext -> { command, args... }  (path is appended as the final arg)
local viewers = {
  -- images
  png  = { "qimgv" }, jpg = { "qimgv" }, jpeg = { "qimgv" },
  webp = { "qimgv" }, bmp = { "qimgv" }, gif  = { "qimgv" },
  svg  = { "qimgv" }, tga = { "qimgv" }, tiff = { "qimgv" },

  -- audio (no window, just play) -- __audio marks it as trackable/stoppable
  wav  = { "mpv", "--no-video", __audio = true }, ogg  = { "mpv", "--no-video", __audio = true },
  mp3  = { "mpv", "--no-video", __audio = true }, flac = { "mpv", "--no-video", __audio = true },
  aac  = { "mpv", "--no-video", __audio = true }, m4a  = { "mpv", "--no-video", __audio = true },

  -- video
  mp4  = { "mpv" }, webm = { "mpv" }, mkv = { "mpv" },
  mov  = { "mpv" }, avi  = { "mpv" },

  -- 3d models
  obj  = { "f3d" }, fbx = { "f3d" }, glb = { "f3d" }, gltf = { "f3d" },
  stl  = { "f3d" }, ply = { "f3d" }, dae = { "f3d" }, ["3ds"] = { "f3d" },
}

-- Job id of the currently playing audio (nil if nothing playing).
local audio_job = nil

local function stop_audio()
  if audio_job then
    pcall(vim.fn.jobstop, audio_job)
    audio_job = nil
    vim.notify("audio stopped", vim.log.levels.INFO)
  else
    vim.notify("no audio playing", vim.log.levels.INFO)
  end
end

-- Returns true if it handled the file (launched a viewer), false otherwise.
local function open_asset(path)
  local ext = path:match("%.([^%.\\/]+)$")
  if not ext then return false end
  local spec = viewers[ext:lower()]
  if not spec then return false end

  if vim.fn.executable(spec[1]) ~= 1 then
    vim.notify(
      ("asset-preview: '%s' not found in PATH (for .%s)"):format(spec[1], ext),
      vim.log.levels.WARN
    )
    return true -- still "handled": don't fall through to a binary buffer
  end

  -- build argv (ipairs skips the __audio string-key marker), append the path
  local cmd = {}
  for _, v in ipairs(spec) do cmd[#cmd + 1] = v end
  cmd[#cmd + 1] = path

  if spec.__audio then
    -- stop whatever's already playing, then track the new job
    if audio_job then pcall(vim.fn.jobstop, audio_job) end
    audio_job = vim.fn.jobstart(cmd, {
      on_exit = function(id)
        if audio_job == id then audio_job = nil end
      end,
    })
  else
    -- detach so the viewer outlives / doesn't block nvim or Konsole
    vim.fn.jobstart(cmd, { detach = true })
  end
  return true
end

-- register the stop keymap once, on load
vim.keymap.set("n", "<leader>s", stop_audio, { desc = "Stop audio playback" })

return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        explorer = {
          actions = {
            confirm = function(picker, item)
              -- asset file: launch the external viewer, keep the explorer open
              if item and item.file and not item.dir and open_asset(item.file) then
                return
              end
              -- not an asset (or no viewer matched): default explorer confirm
              local ok, explorer_actions = pcall(require, "snacks.explorer.actions")
              if ok and explorer_actions.actions and explorer_actions.actions.confirm then
                explorer_actions.actions.confirm(picker, item)
              else
                require("snacks").picker.actions.jump(picker, item, { action = "jump" })
              end
            end,
          },
        },
      },
    },
  },
}
