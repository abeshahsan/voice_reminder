import asyncio
from rasa.model import get_latest_model
from rasa.nlu.model import Interpreter

async def load_interpreter():
    model_path = get_latest_model()
    return Interpreter.load(model_path)

async def main():
    interpreter = await load_interpreter()

    test_texts = [
        "Add buy groceries to my list",
        "Remind me to call dad at 7 PM",
        "What's on my list for today?",
        "Delete the laundry task"
    ]

    for text in test_texts:
        result = interpreter.parse(text)
        print(f"\nInput: {text}")
        print("Intent:", result["intent"]["name"])
        print("Entities:", result["entities"])

asyncio.run(main())
