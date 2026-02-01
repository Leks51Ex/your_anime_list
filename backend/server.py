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


from pydantic import BaseModel, Field
from typing import Optional


class Item(BaseModel):
    id: int
    title: str
    isChecked: bool
    comment: str = "" 


class ListModel(BaseModel):
    id: int
    title: str
    icon: str
    color: int
    items: List[Item] = []


from typing import Optional

class ListUpdate(BaseModel):
    title: Optional[str] = None
    icon: Optional[str] = None
    color: Optional[int] = None

def load_data():
    if not DATA_FILE.exists():
        return {"lists": []}

    text = DATA_FILE.read_text(encoding="utf-8").strip()
    if not text:
        return {"lists": []}

    return json.loads(text)



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
@app.put("/lists/{list_id}/items/{item_id}")
def update_item(list_id: int, item_id: int, item: Item):
    data = load_data()
    for l in data["lists"]:
        if l["id"] == list_id:
            for i, it in enumerate(l["items"]):
                if it["id"] == item_id:
                    # Ограничение на длину комментария
                    item.comment = item.comment[:40]
                    l["items"][i] = item.dict()
                    save_data(data)
                    return {"ok": True}
    raise HTTPException(status_code=404, detail="Item not found")




@app.put("/lists/{list_id}")
def update_list(list_id: int, payload: ListUpdate):
    data = load_data()

    for l in data["lists"]:
        if l["id"] == list_id:
            if payload.title is not None:
                l["title"] = payload.title
            if payload.icon is not None:
                l["icon"] = payload.icon
            if payload.color is not None:
                l["color"] = payload.color

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

