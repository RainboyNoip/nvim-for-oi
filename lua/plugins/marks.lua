return {
    "chentoast/marks.nvim",
    event = "VeryLazy",
    opts = {
        -- marks.nvim allows you to configure up to 10 bookmark groups, each with its own
        -- sign/virttext. Bookmarks can be used to group together positions and quickly move
        -- across multiple buffers. default sign is '!@#$%^&*()' (from 0 to 9), and
        -- default virt_text is "".
        bookmark_0 = {
            sign = "⚑",
            virt_text = "hello world",
            -- explicitly prompt for a virtual line annotation when setting a bookmark from this group.
            -- defaults to false.
            annotate = false,
        },
    },
}
