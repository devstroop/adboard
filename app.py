import asyncio
import aiohttp
import gi

gi.require_version('Gst', '1.0')
from gi.repository import Gst

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

    # Monitor pipeline state until the advertisement finishes playing
    while True:
        state = pipeline.get_state(Gst.CLOCK_TIME_NONE)[1]
        if state == Gst.State.NULL or state == Gst.State.READY:
            break
        await asyncio.sleep(0.1)  # Check every 0.1 seconds

    # Cleanup pipeline
    pipeline.set_state(Gst.State.NULL)

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

if __name__ == "__main__":
    asyncio.run(main())
