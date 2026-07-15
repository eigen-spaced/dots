return {
  {
    "mason-org/mason.nvim",
    providers = {
      "mason.providers.registry-api",
      "mason.providers.client",
    },
    -- No `build`: mason 2.x registers :MasonUpdate only after setup() (no
    -- plugin/ dir), so it E492s at lazy's build step on a fresh install; the
    -- registry auto-fetches on demand anyway.
  },
}
