from fastapi import FastAPI

app = FastAPI(title="ModaViva API")


@app.get("/")
def root():
    return {
        "application": "ModaViva",
        "status": "running"
    }


@app.get("/health")
def health():
    return {
        "status": "healthy"
    }