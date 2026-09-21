export default {
  id: "interrupt.command",
  tui: async (api) => {
    const dispose = api.keymap.registerLayer({
      commands: [
        {
          namespace: "palette",
          name: "interrupt.command",
          title: "Interrupt session",
          desc: "Stop the running agent",
          category: "Session",
          slashName: "interrupt",
          run: () => {
            const route = api.route.current
            const sessionID = route?.name === "session" ? route.params?.sessionID : undefined
            if (!sessionID) {
              api.ui.toast({ variant: "info", title: "Interrupt", message: "No active session" })
              return
            }
            const status = api.state.session.status(sessionID)
            if (!status || status.type === "idle") {
              api.ui.toast({ variant: "info", title: "Interrupt", message: "Agent is not running" })
              return
            }
            Promise.resolve(api.client.session.abort({ sessionID })).catch(() => {})
          },
        },
      ],
    })
    api.lifecycle.onDispose(() => {
      if (typeof dispose === "function") dispose()
    })
  },
}
