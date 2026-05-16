from fastapi import FastAPI
from prometheus_fastapi_instrumentator import Instrumentator
import time
import math
import os

app = FastAPI(title="SRE Orders Service")

# Instrumentation for Prometheus metrics
Instrumentator().instrument(app).expose(app)

@app.get("/")
async def root():
    return {"message": "SRE Orders Service is running", "version": "1.0.0"}

@app.get("/health")
async def health():
    return {"status": "healthy"}

@app.get("/work")
async def work(n: int = 1000000):
    """
    Simulate CPU work to trigger HPA scaling.
    """
    start_time = time.time()
    # Artificial CPU load
    for i in range(n):
        math.sqrt(i)
    duration = time.time() - start_time
    return {"work_done": n, "duration_seconds": duration}

@app.get("/error")
async def error():
    """
    Simulate an error for monitoring alerts.
    """
    raise Exception("Simulated service error")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
