import { describe, it, expect, vi } from "vitest";
import worker from "../src/index";

// The handler only touches message.forward / message.setReject and env.FORWARD_TO,
// so we exercise it with a lightweight fake message rather than a full workerd
// runtime — this keeps the unit test fast and dependency-free.
function fakeMessage() {
  return {
    forward: vi.fn().mockResolvedValue(undefined),
    setReject: vi.fn(),
  };
}
const ctx = {} as any;

describe("email-router fan-out", () => {
  it("forwards to every recipient in FORWARD_TO", async () => {
    const message = fakeMessage();
    await worker.email!(message as any, { FORWARD_TO: "a@example.de,b@example.de" }, ctx);

    expect(message.forward).toHaveBeenCalledTimes(2);
    expect(message.forward).toHaveBeenCalledWith("a@example.de");
    expect(message.forward).toHaveBeenCalledWith("b@example.de");
    expect(message.setReject).not.toHaveBeenCalled();
  });

  it("trims whitespace and skips empty entries", async () => {
    const message = fakeMessage();
    await worker.email!(message as any, { FORWARD_TO: " a@example.de , , b@example.de " }, ctx);

    expect(message.forward).toHaveBeenCalledTimes(2);
    expect(message.forward).toHaveBeenCalledWith("a@example.de");
    expect(message.forward).toHaveBeenCalledWith("b@example.de");
  });

  it("rejects the message when FORWARD_TO is unset", async () => {
    const message = fakeMessage();
    await worker.email!(message as any, {}, ctx);

    expect(message.setReject).toHaveBeenCalledOnce();
    expect(message.forward).not.toHaveBeenCalled();
  });

  it("rejects the message when FORWARD_TO is blank", async () => {
    const message = fakeMessage();
    await worker.email!(message as any, { FORWARD_TO: " , " }, ctx);

    expect(message.setReject).toHaveBeenCalledOnce();
    expect(message.forward).not.toHaveBeenCalled();
  });
});
