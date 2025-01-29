from fastapi import FastAPI, File, Form, UploadFile, HTTPException, Depends
from fastapi.responses import JSONResponse
from typing import Optional
import uvicorn

app = FastAPI()

@app.post("/api/v1/sku")
async def add_sku(
    barcode: str = Form(...),
    sku_image: UploadFile = File(...),
    price: Optional[float] = Form(None),
    price_image: Optional[UploadFile] = File(None),
    store: Optional[str] = Form(None)
):
    # Validate input logic
    if price is None and price_image is None:
        raise HTTPException(status_code=400, detail="Either 'price' or 'price_image' must be provided.")

    # Debugging information for the uploaded images
    sku_image_info = {
        "filename": sku_image.filename,
        "content_type": sku_image.content_type,
        "size": len(await sku_image.read())
    }

    if price_image:
        price_image_info = {
            "filename": price_image.filename,
            "content_type": price_image.content_type,
            "size": len(await price_image.read())
        }
    else:
        price_image_info = "No image uploaded"

    # Mock processing and response
    result = {
        "barcode": barcode,
        "sku_image": sku_image_info,
        "price": price,
        "price_image": price_image_info,
        "store": store
    }

    return JSONResponse(content=result)


@app.post("/api/v1/login")
async def login(username: str = Form(...), password: str = Form(...)):
    status = "denied"
    if username == "" or password == "" or username is None or password is None :
        raise HTTPException(status_code=400, detail="Bad request - Missing credentials")
    elif username == password:
        status = "access granted"
    elif username != password:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    result = {
        "message": status,
    }
    return JSONResponse(content=result)


@app.post("/api/v1/logout")
async def logout():
    result = {
        "message": "success",
    }
    return JSONResponse(content=result)


@app.post("/api/v1/health")
async def health():
    result = {
        "status": "OK",
    }
    return JSONResponse(content=result)

if __name__ == "__main__":
    uvicorn.run("sku_image_server:app", host="0.0.0.0", port=8000, reload=True)
