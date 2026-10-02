#!/usr/bin/env python3
"""Relay Moonlight on this Mac to a Sunshine host on the personal tailnet.

The personal tailnet runs as a userspace tailscaled, so apps here can only reach
its peers through tailscaled's SOCKS5 proxy. Moonlight has no proxy support, so
this listens on 127.0.0.1 with the host's own port numbers and forwards:
  TCP -> SOCKS5 CONNECT
  UDP -> SOCKS5 UDP ASSOCIATE (one association per local client address)
Point Moonlight at 127.0.0.1:<http port>.
"""
import asyncio
import socket
import struct
import sys
import time

TARGET = "100.115.34.49"            # m1-omarchy on the personal tailnet
SOCKS = ("127.0.0.1", 1055)         # personal tailscaled --socks5-server
TCP_PORTS = [48984, 48989, 49010]   # Sunshine https, http, rtsp (port base 48989)
UDP_PORTS = [48998, 48999, 49000]   # video, control, audio
UDP_IDLE_SECONDS = 600

TARGET_ADDR = b"\x01" + socket.inet_aton(TARGET)


def log(*a):
    print(time.strftime("%H:%M:%S"), *a, flush=True)


async def socks_handshake(reader, writer, cmd, port):
    writer.write(b"\x05\x01\x00")
    await writer.drain()
    if await reader.readexactly(2) != b"\x05\x00":
        raise ConnectionError("socks: no-auth refused")
    writer.write(b"\x05" + bytes([cmd]) + b"\x00" + TARGET_ADDR + struct.pack(">H", port))
    await writer.drain()
    rep = await reader.readexactly(10)
    if rep[1] != 0:
        raise ConnectionError(f"socks: reply code {rep[1]}")
    return socket.inet_ntoa(rep[4:8]), struct.unpack(">H", rep[8:10])[0]


async def pipe(r, w):
    try:
        while data := await r.read(65536):
            w.write(data)
            await w.drain()
    except (ConnectionError, asyncio.IncompleteReadError):
        pass
    finally:
        w.close()


def tcp_handler(port):
    async def handle(cr, cw):
        try:
            sr, sw = await asyncio.open_connection(*SOCKS)
            await socks_handshake(sr, sw, 1, port)
        except Exception as e:
            log(f"tcp {port}: connect failed: {e}")
            cw.close()
            return
        for s in (cw.get_extra_info("socket"), sw.get_extra_info("socket")):
            s.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
        await asyncio.gather(pipe(cr, sw), pipe(sr, cw))
    return handle


class ClientUdpAssociation(asyncio.DatagramProtocol):
    def __init__(self, front, client):
        self.front, self.client, self.last = front, client, time.monotonic()
        self.transport = None

    def connection_made(self, t):
        self.transport = t

    def datagram_received(self, data, _addr):
        # SOCKS5 UDP header: RSV(2) FRAG(1) ATYP(1) ADDR(4) PORT(2)
        if len(data) > 10 and data[3] == 1:
            self.last = time.monotonic()
            self.front.transport.sendto(data[10:], self.client)


class Front(asyncio.DatagramProtocol):
    def __init__(self, port):
        self.port, self.assocs, self.transport = port, {}, None
        self.header = b"\x00\x00\x00" + TARGET_ADDR + struct.pack(">H", port)

    def connection_made(self, t):
        self.transport = t

    def datagram_received(self, data, client):
        a = self.assocs.get(client)
        if a is None:
            asyncio.ensure_future(self.open(client, data))
            return
        a["proto"].last = time.monotonic()
        a["proto"].transport.sendto(self.header + data, a["relay"])

    async def open(self, client, first):
        if client in self.assocs:
            return
        try:
            sr, sw = await asyncio.open_connection(*SOCKS)
            rip, rport = await socks_handshake(sr, sw, 3, 0)
        except Exception as e:
            log(f"udp {self.port}: associate failed: {e}")
            return
        if rip == "0.0.0.0":
            rip = SOCKS[0]
        loop = asyncio.get_running_loop()
        t, proto = await loop.create_datagram_endpoint(
            lambda: ClientUdpAssociation(self, client), local_addr=("127.0.0.1", 0))
        self.assocs[client] = {"proto": proto, "relay": (rip, rport), "ctl": sw}
        log(f"udp {self.port}: new association for {client}")
        t.sendto(self.header + first, (rip, rport))

    async def reaper(self):
        while True:
            await asyncio.sleep(30)
            now = time.monotonic()
            for c, a in list(self.assocs.items()):
                if now - a["proto"].last > UDP_IDLE_SECONDS:
                    a["proto"].transport.close()
                    a["ctl"].close()
                    del self.assocs[c]
                    log(f"udp {self.port}: dropped idle association {c}")


async def main():
    loop = asyncio.get_running_loop()
    for p in TCP_PORTS:
        await asyncio.start_server(tcp_handler(p), "127.0.0.1", p)
    for p in UDP_PORTS:
        _, front = await loop.create_datagram_endpoint(
            lambda p=p: Front(p), local_addr=("127.0.0.1", p))
        asyncio.ensure_future(front.reaper())
    log(f"relaying 127.0.0.1 tcp {TCP_PORTS} udp {UDP_PORTS} -> {TARGET} via socks5 {SOCKS}")
    await asyncio.Event().wait()


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        sys.exit(0)
