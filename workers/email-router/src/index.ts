interface Env {
  FORWARD_TO?: string;
}

export default {
  async email(message, env, ctx): Promise<void> {
    const recipients = (env.FORWARD_TO ?? "")
      .split(",")
      .map((s) => s.trim())
      .filter(Boolean);

    if (recipients.length === 0) {
      message.setReject("No forwarding recipients configured.");
      return;
    }

    await Promise.all(recipients.map((addr) => message.forward(addr)));
  },
} satisfies ExportedHandler<Env>;
