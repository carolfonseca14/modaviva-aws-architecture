from fastapi import FastAPI
from fastapi.responses import StreamingResponse
from .database import get_connection
import boto3
import io

app = FastAPI(title="ModaViva API")

PRODUCT_IMAGES_BUCKET = "modaviva-product-images-436847501474"


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


@app.get("/health/db")
def health_db():
    with get_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
            result = cursor.fetchone()

    return {
        "status": "healthy",
        "database": result[0] == 1
    }

@app.get("/load-test")
def load_test():
    total = sum(i * i for i in range(20_000_000))

    return {
        "status": "ok",
        "result": total
    }

@app.get("/products/{filename}")
def get_product_image(filename: str):
    s3 = boto3.client("s3")
    
    response = s3.get_object(
        Bucket=PRODUCT_IMAGES_BUCKET,
        Key=f"products/{filename}"
    )

    return StreamingResponse(
        io.BytesIO(response["Body"].read()),
        media_type=response["ContentType"]
    )