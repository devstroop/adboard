import asyncio
import aiohttp
import gi

gi.require_version('Gst', '1.0')
from gi.repository import Gst, GLib

async def fetch_ads(session):
    async with session.get("http://doohfy.com/odata/DOOHDB/Advertisements") as response:
        response.raise_for_status()
        return await response.json()

async def play_advertisement(session, advertisement):
    pipeline = Gst.Pipeline()
    playbin = Gst.ElementFactory.make("playbin", "playbin")
    pipeline.add(playbin)

    uri = f"https://cdn.hallads.com/{advertisement['AttachmentKey']}"
    print(f"Playing advertisement: {uri}")

    playbin.set_property('uri', uri)
    pipeline.set_state(Gst.State.PLAYING)

    loop = asyncio.get_running_loop()
    bus = pipeline.get_bus()
    bus.add_signal_watch()
    bus.connect("message::eos", lambda bus, msg: loop.call_soon_threadsafe(on_eos, pipeline))
    bus.connect("message::error", lambda bus, msg: loop.call_soon_threadsafe(on_error, pipeline))

    # Monitor pipeline state until the advertisement finishes playing
    while True:
        state = pipeline.get_state(Gst.CLOCK_TIME_NONE)[1]
        if state == Gst.State.NULL or state == Gst.State.READY:
            break
        await asyncio.sleep(0.1)  # Check every 0.1 seconds

async def main():
    Gst.init(None)
    async with aiohttp.ClientSession() as session:
        while True:
            try:
                ads = await fetch_ads(session)
                for ad in ads['value']:
                    await play_advertisement(session, ad)
            except Exception as e:
                print(f"Error occurred: {e}")

def on_eos(pipeline):
    pipeline.set_state(Gst.State.NULL)

def on_error(pipeline):
    print("Error occurred:", pipeline.get_bus().poll(Gst.MessageType.ERROR, -1).parse_error())

if __name__ == "__main__":
    asyncio.run(main())
