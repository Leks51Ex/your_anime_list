from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List
from pathlib import Path
import json

DATA_FILE = Path("data.json")


app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)





class Item(BaseModel):
  id: int
  title: str
  isChecked: bool


class ListModel(BaseModel):
  id: int
  title: str
  items: List[Item] = []

class ListUpdate(BaseModel):
    title: str

def load_data():
  if not DATA_FILE.exists():
    return {"lists": []}
  return json.loads(DATA_FILE.read_text(encoding="utf-8"))


def save_data(data):
  DATA_FILE.write_text(
      json.dumps(data, ensure_ascii=False, indent=2),
      encoding="utf-8",
  )


@app.get("/lists", response_model=List[ListModel])
def get_lists():
  data = load_data()
  return data["lists"]


@app.post("/lists", response_model=ListModel)
def create_list(list_in: ListModel):
  data = load_data()
  data["lists"].append(list_in.dict())
  save_data(data)
  return list_in


@app.delete("/lists/{list_id}")
def delete_list(list_id: int):
  data = load_data()
  before = len(data["lists"])
  data["lists"] = [l for l in data["lists"] if l["id"] != list_id]
  if len(data["lists"]) == before:
    raise HTTPException(status_code=404, detail="List not found")
  save_data(data)
  return {"ok": True}


@app.post("/lists/{list_id}/items", response_model=Item)
def add_item(list_id: int, item: Item):
  data = load_data()
  for l in data["lists"]:
    if l["id"] == list_id:
      l["items"].append(item.dict())
      save_data(data)
      return item
  raise HTTPException(status_code=404, detail="List not found")


@app.put("/lists/{list_id}/items/{item_id}")
def update_item(list_id: int, item_id: int, item: Item):
  data = load_data()
  for l in data["lists"]:
    if l["id"] == list_id:
      for i, it in enumerate(l["items"]):
        if it["id"] == item_id:
          l["items"][i] = item.dict()
          save_data(data)
          return {"ok": True}
  raise HTTPException(status_code=404, detail="Item not found")



@app.put("/lists/{list_id}")
def update_list(list_id: int, payload: ListUpdate):
    data = load_data()

    for l in data["lists"]:
        if l["id"] == list_id:
            l["title"] = payload.title
            save_data(data)
            return {"ok": True}

    raise HTTPException(status_code=404, detail="List not found")


@app.delete("/lists/{list_id}/items/{item_id}")
def delete_item(list_id: int, item_id: int):
  data = load_data()
  for l in data["lists"]:
    if l["id"] == list_id:
      before = len(l["items"])
      l["items"] = [it for it in l["items"] if it["id"] != item_id]
      if len(l["items"]) == before:
        raise HTTPException(status_code=404, detail="Item not found")
      save_data(data)
      return {"ok": True}
  raise HTTPException(status_code=404, detail="List not found")

