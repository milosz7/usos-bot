import asyncio
import time

from backend.models import ChunkResponse


class StreamEntity:
    def __init__(self, stream: asyncio.Queue[ChunkResponse]):
        self.stream = stream
        self.last_access = time.time()

    def _update_time(self):
        self.last_access = time.time()

    async def put(self, chunk: ChunkResponse):
        self._update_time()
        await self.stream.put(chunk)

    async def get(self):
        self._update_time()
        return await self.stream.get()

    def __del__(self):
        self.stream.task_done()
        self.stream.join()


class StreamHandler:
    def __init__(self):
        self.stream_ttl_in_s = 10
        self.remote_streams = dict()
        self.streams = dict()
        asyncio.create_task(self.consume_dangling())

    async def consume_dangling(self):
        sleep_time_in_s = 1
        while True:
            await asyncio.sleep(sleep_time_in_s)
            print("pre", len(self.streams))
            # TODO: self.streams is a dict, change iteration
            for stream in self.streams:
                current_time = time.time()
                last_access = current_time - stream.last_access
                if last_access > self.stream_ttl_in_s:
                    self.delete_stream(stream)

            print("post", len(self.streams))

    async def _consume(self, thread_id):
        remote_stream = self.remote_streams[thread_id]
        try:
            # first message is always empty
            _ = next(remote_stream)
            while True:
                msg, _ = next(remote_stream)
                await self.streams[thread_id].put(
                    ChunkResponse(chunk=msg.content, is_finished=False)
                )

                if "finish_reason" in msg.response_metadata:
                    for msg, _ in remote_stream:
                        pass

                    await self.streams[thread_id].put(
                        ChunkResponse(chunk="", is_finished=True)
                    )
        except StopIteration:
            pass

    def consume_remote_stream(self, thread_id):
        asyncio.create_task(self._consume(thread_id))

    async def get_next_chunk(self, thread_id):
        return await self.streams[thread_id].get()

    def add_stream(self, stream, thread_id):
        self.remote_streams[thread_id] = stream
        self.streams[thread_id] = StreamEntity(asyncio.Queue())
        self.consume_remote_stream(thread_id)

    def delete_stream(self, thread_id):
        del self.streams[thread_id]
