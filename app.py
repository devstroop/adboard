import asyncio
import subprocess
import aiohttp
import gi

gi.require_version('Gst', '1.0')
from gi.repository import Gst


async def fetch_ads(session):
    async with session.get("http://doohfy.com/odata/DOOHDB/Advertisements") as response:
        response.raise_for_status()
        return await response.json()


async def play_advertisement(session, advertisement, pipeline):
    uri = f"https://cdn.hallads.com/{advertisement['AttachmentKey']}"
    print(f"Playing advertisement: {uri}")
    pipeline.set_state(Gst.State.NULL)
    pipeline.get_by_name('playbin').set_property('uri', uri)
    pipeline.set_state(Gst.State.PLAYING)

    # Add a delay to give the pipeline time to start playing
    await asyncio.sleep(1)

    # Check pipeline state
    state = pipeline.get_state(Gst.CLOCK_TIME_NONE)
    print(f"Pipeline state after PLAYING: {state}")


async def main():
    Gst.init(None)
    async with aiohttp.ClientSession() as session:
        pipeline = Gst.Pipeline()
        if not pipeline:
            print("Error: Failed to create GStreamer pipeline.")
            return

        while True:
            try:
                ads = await fetch_ads(session)
                for ad in ads['value']:
                    await play_advertisement(session, ad, pipeline)
            except Exception as e:
                print(f"Error occurred: {e}")


if __name__ == "__main__":
    asyncio.run(main())
