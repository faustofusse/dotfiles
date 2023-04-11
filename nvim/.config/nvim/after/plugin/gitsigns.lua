local status_ok, gitsigns = pcall(require, "gitsigns")
if status_ok then
    gitsigns.setup()
end
