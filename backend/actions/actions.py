from typing import Text, List, Any, Dict

from rasa_sdk import Tracker, FormValidationAction, Action
from rasa_sdk.events import EventType
from rasa_sdk.executor import CollectingDispatcher
from rasa_sdk.types import DomainDict


# --- Custom Action for Task Submission ---
class ActionSubmitTask(Action):
    def name(self) -> Text:
        return "utter_submit"

    def run(
        self, dispatcher: CollectingDispatcher, tracker: Tracker, domain: DomainDict
    ) -> List[EventType]:
        from rasa_sdk.events import SlotSet
        task_name = tracker.get_slot("task_name")
        task_description = tracker.get_slot("task_description")
        due_date = tracker.get_slot("due_date")
        # Send response to frontend
        dispatcher.utter_message(text=f"I will add the task to your todo list.")
        # Print to console
        print(
            f"Task submitted: Name='{task_name}', Description='{task_description}', Due Date='{due_date}'"
        )
        return [
            SlotSet("task_name", task_name),
            SlotSet("task_description", task_description),
            SlotSet("due_date", due_date)
        ]


# --- Custom Action for Added Task Confirmation ---
class ActionAddedTask(Action):
    def name(self) -> Text:
        return "utter_added_task"

    def run(
        self, dispatcher: CollectingDispatcher, tracker: Tracker, domain: DomainDict
    ) -> List[EventType]:
        from rasa_sdk.events import SlotSet
        task_name = tracker.get_slot("task_name")
        task_description = tracker.get_slot("task_description")
        due_date = tracker.get_slot("due_date")
        # Send response to frontend
        dispatcher.utter_message(text=f"The task has been added successfully.")
        # Print to console
        print(
            f"Task added: Name='{task_name}', Description='{task_description}', Due Date='{due_date}'"
        )
        return [
            SlotSet("task_name", task_name),
            SlotSet("task_description", task_description),
            SlotSet("due_date", due_date)
        ]
