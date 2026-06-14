Implementing new feature.
1- remove the items in drawer.
2- add new 2 buttons
a. a button that navigates to home page unless we're on home page
b. a button that takes us to this new feature called ("Workflow", "سلسلة الموافقات"),

start with models and endpoints
1- workflows screen
get:
/api/Web/GetWorkflows
headers:
ServiceKey: 1111111
resonse:
{
  "success": true,
  "message": "Success",
  "dataCount": 1,
  "data": [
    {
      "ID": 1,
      "Name": "Vacation",
      "CreationDate": "2025-09-18T14:17:51.133",
      "StepsCount": 2
    }
  ],
  "body": null
}
we'll then show a list of workflows, also add the ability to search and sort those workflows by Name

2- workflow screen
when a workflow is tapped
endpoint:
/api/Web/GetWorkflowById?id=1
notice that we pass the id of the workflow that was tapped.
headers:
ServiceKey: 1111111
resonse:
{
  "success": true,
  "message": "Success",
  "dataCount": 1,
  "data": {
    "workflowId": 0,
    "name": "Vacation",
    "creationDate": "2025-09-18T14:17:51.133",
    "empCreatedID": null,
    "steps": [
      {
        "stepNo": 1,
        "empId": 6,
        "username": "{\"en\":\"ZAHER TAHA ZAHER TAHA YASSIN\",\"ar\":\"زاهر طه زاهر طه ياسين\"}"
      },
      {
        "stepNo": 2,
        "empId": 388,
        "username": "{\"en\":\"AMR ABDELGHAFFAR ELSAYED ELBRASHY\",\"ar\":\"عمرو  عبد الغفار السيد البراشي\"}"
      }
    ],
    "groupDetails": [
      {
        "groupId": 1,
        "requestTypeId": 1,
        "groupName": "Group 1",
        "requestTypeName": "{\"en\":\"Vacation Request - NC\",\"ar\":\"طلب إجازة - NC\"}"
      },
      {
        "groupId": 1,
        "requestTypeId": 2,
        "groupName": "Group 1",
        "requestTypeName": "{\"en\":\"Loan Request - NC\",\"ar\":\"طلب سلفة - NC\"}"
      },
      {
        "groupId": 2,
        "requestTypeId": 9,
        "groupName": "Group 2",
        "requestTypeName": "{\"en\":\"Financial Pledge Request - NC\",\"ar\":\"طلب عهدة مالية - NC\"}"
      },
      {
        "groupId": 3,
        "requestTypeId": 11,
        "groupName": "Group 3",
        "requestTypeName": "{\"en\":\"Support Request - NC\",\"ar\":\"طلب دعم فني - NC\"}"
      },
      {
        "groupId": 1,
        "requestTypeId": 13,
        "groupName": "Group 1",
        "requestTypeName": "{\"en\":\"Vacation Cancellation Request - NC\",\"ar\":\"طلب الغاء إجازة - NC\"}"
      },
      {
        "groupId": 1,
        "requestTypeId": 14,
        "groupName": "Group 1",
        "requestTypeName": "{\"en\":\"Early Vacation Cancellation Request - NC\",\"ar\":\"طلب حضور مبكر - NC\"}"
      },
      {
        "groupId": 1,
        "requestTypeId": 15,
        "groupName": "Group 1",
        "requestTypeName": "{\"en\":\"Extend Vacation Request - NC\",\"ar\":\"طلب مد إجازة - NC\"}"
      }
    ]
  },
  "body": null
}

in this screen we show the details of the workflow
basic data of the workflow:
    "workflowId": 0,
    "name": "Vacation",
    "creationDate": "2025-09-18T14:17:51.133",
    "empCreatedID": null,
steps of this workflow:
 "steps": [
      {
        "stepNo": 1,
        "empId": 6,
        "username": "{\"en\":\"ZAHER TAHA ZAHER TAHA YASSIN\",\"ar\":\"زاهر طه زاهر طه ياسين\"}"
      },
      {
        "stepNo": 2,
        "empId": 388,
        "username": "{\"en\":\"AMR ABDELGHAFFAR ELSAYED ELBRASHY\",\"ar\":\"عمرو  عبد الغفار السيد البراشي\"}"
      }
    ],
the groupDetails of which this workflow could work on:
    "groupDetails": [
      {
        "groupId": 1,
        "requestTypeId": 1,
        "groupName": "Group 1",
        "requestTypeName": "{\"en\":\"Vacation Request - NC\",\"ar\":\"طلب إجازة - NC\"}"
      },
      {
        "groupId": 1,
        "requestTypeId": 2,
        "groupName": "Group 1",
        "requestTypeName": "{\"en\":\"Loan Request - NC\",\"ar\":\"طلب سلفة - NC\"}"
      },
      {
        "groupId": 2,
        "requestTypeId": 9,
        "groupName": "Group 2",
        "requestTypeName": "{\"en\":\"Financial Pledge Request - NC\",\"ar\":\"طلب عهدة مالية - NC\"}"
      },
      {
        "groupId": 3,
        "requestTypeId": 11,
        "groupName": "Group 3",
        "requestTypeName": "{\"en\":\"Support Request - NC\",\"ar\":\"طلب دعم فني - NC\"}"
      },
      {
        "groupId": 1,
        "requestTypeId": 13,
        "groupName": "Group 1",
        "requestTypeName": "{\"en\":\"Vacation Cancellation Request - NC\",\"ar\":\"طلب الغاء إجازة - NC\"}"
      },
      {
        "groupId": 1,
        "requestTypeId": 14,
        "groupName": "Group 1",
        "requestTypeName": "{\"en\":\"Early Vacation Cancellation Request - NC\",\"ar\":\"طلب حضور مبكر - NC\"}"
      },
      {
        "groupId": 1,
        "requestTypeId": 15,
        "groupName": "Group 1",
        "requestTypeName": "{\"en\":\"Extend Vacation Request - NC\",\"ar\":\"طلب مد إجازة - NC\"}"
      }
    ]

    Continuation.
    here is an endpoint that returns 3 lists of different models.
    users list we shall call it something that doesn't conflict with our current names as it is new.
    groups this is a list of groups we will use later as well.
    requestTypes this is another list.
    those three lists will later be implemented as drop downs for users to choose from.
    for now create the models and and fetch data from api mount it in the lists for later use.
    the new feature we're working on is "create new workflow".

    /api/Web/GetWorkflowDropdowns?userGroupId=1
    {
  "success": true,
  "message": "Success",
  "dataCount": 1,
  "data": {
    "users": [
      {
        "id": 6,
        "name": "{\"en\":\"ZAHER TAHA ZAHER TAHA YASSIN\",\"ar\":\"زاهر طه زاهر طه ياسين\"}"
      },
      {
        "id": 388,
        "name": "{\"en\":\"AMR ABDELGHAFFAR ELSAYED ELBRASHY\",\"ar\":\"عمرو  عبد الغفار السيد البراشي\"}"
      }
    ],
    "groups": [
      {
        "id": 1,
        "name": "Group 1"
      },
      {
        "id": 2,
        "name": "Group 2"
      },
      {
        "id": 3,
        "name": "Group 3"
      },
      {
        "id": 4,
        "name": "Group 4"
      }
    ],
    "requestTypes": [
      {
        "id": 1,
        "name": "{\"en\":\"Vacation Request - NC\",\"ar\":\"طلب إجازة - NC\"}"
      },
      {
        "id": 1,
        "name": "{\"en\":\"Vacation Request - NC\",\"ar\":\"طلب إجازة - NC\"}"
      },
      {
        "id": 1,
        "name": "{\"en\":\"Vacation Request - NC\",\"ar\":\"طلب إجازة - NC\"}"
      },
      {
        "id": 1,
        "name": "{\"en\":\"Vacation Request - NC\",\"ar\":\"طلب إجازة - NC\"}"
      },
      {
        "id": 1,
        "name": "{\"en\":\"Vacation Request - NC\",\"ar\":\"طلب إجازة - NC\"}"
      },
      {
        "id": 1,
        "name": "{\"en\":\"Vacation Request - NC\",\"ar\":\"طلب إجازة - NC\"}"
      },
      {
        "id": 1,
        "name": "{\"en\":\"Vacation Request - NC\",\"ar\":\"طلب إجازة - NC\"}"
      },
      {
        "id": 1,
        "name": "{\"en\":\"Vacation Request - NC\",\"ar\":\"طلب إجازة - NC\"}"
      },
      {
        "id": 1,
        "name": "{\"en\":\"Vacation Request - NC\",\"ar\":\"طلب إجازة - NC\"}"
      },
      {
        "id": 1,
        "name": "{\"en\":\"Vacation Request - NC\",\"ar\":\"طلب إجازة - NC\"}"
      },
      {
        "id": 1,
        "name": "{\"en\":\"Vacation Request - NC\",\"ar\":\"طلب إجازة - NC\"}"
      },
      {
        "id": 1,
        "name": "{\"en\":\"Vacation Request - NC\",\"ar\":\"طلب إجازة - NC\"}"
      },
      {
        "id": 1,
        "name": "{\"en\":\"Vacation Request - NC\",\"ar\":\"طلب إجازة - NC\"}"
      },
      {
        "id": 1,
        "name": "{\"en\":\"Vacation Request - NC\",\"ar\":\"طلب إجازة - NC\"}"
      },
      {
        "id": 1,
        "name": "{\"en\":\"Vacation Request - NC\",\"ar\":\"طلب إجازة - NC\"}"
      },
      {
        "id": 1,
        "name": "{\"en\":\"Vacation Request - NC\",\"ar\":\"طلب إجازة - NC\"}"
      },
      {
        "id": 1,
        "name": "{\"en\":\"Vacation Request - NC\",\"ar\":\"طلب إجازة - NC\"}"
      },
      {
        "id": 1,
        "name": "{\"en\":\"Vacation Request - NC\",\"ar\":\"طلب إجازة - NC\"}"
      },
      {
        "id": 1,
        "name": "{\"en\":\"Vacation Request - NC\",\"ar\":\"طلب إجازة - NC\"}"
      },
      {
        "id": 1,
        "name": "{\"en\":\"Vacation Request - NC\",\"ar\":\"طلب إجازة - NC\"}"
      },
      {
        "id": 1,
        "name": "{\"en\":\"Vacation Request - NC\",\"ar\":\"طلب إجازة - NC\"}"
      },
      {
        "id": 1,
        "name": "{\"en\":\"Vacation Request - NC\",\"ar\":\"طلب إجازة - NC\"}"
      },
      {
        "id": 2,
        "name": "{\"en\":\"Loan Request - NC\",\"ar\":\"طلب سلفة - NC\"}"
      },
      {
        "id": 2,
        "name": "{\"en\":\"Loan Request - NC\",\"ar\":\"طلب سلفة - NC\"}"
      },
      {
        "id": 2,
        "name": "{\"en\":\"Loan Request - NC\",\"ar\":\"طلب سلفة - NC\"}"
      },
      {
        "id": 2,
        "name": "{\"en\":\"Loan Request - NC\",\"ar\":\"طلب سلفة - NC\"}"
      },
      {
        "id": 2,
        "name": "{\"en\":\"Loan Request - NC\",\"ar\":\"طلب سلفة - NC\"}"
      },
      {
        "id": 2,
        "name": "{\"en\":\"Loan Request - NC\",\"ar\":\"طلب سلفة - NC\"}"
      },
      {
        "id": 2,
        "name": "{\"en\":\"Loan Request - NC\",\"ar\":\"طلب سلفة - NC\"}"
      },
      {
        "id": 2,
        "name": "{\"en\":\"Loan Request - NC\",\"ar\":\"طلب سلفة - NC\"}"
      },
      {
        "id": 2,
        "name": "{\"en\":\"Loan Request - NC\",\"ar\":\"طلب سلفة - NC\"}"
      },
      {
        "id": 2,
        "name": "{\"en\":\"Loan Request - NC\",\"ar\":\"طلب سلفة - NC\"}"
      },
      {
        "id": 2,
        "name": "{\"en\":\"Loan Request - NC\",\"ar\":\"طلب سلفة - NC\"}"
      },
      {
        "id": 2,
        "name": "{\"en\":\"Loan Request - NC\",\"ar\":\"طلب سلفة - NC\"}"
      },
      {
        "id": 2,
        "name": "{\"en\":\"Loan Request - NC\",\"ar\":\"طلب سلفة - NC\"}"
      },
      {
        "id": 2,
        "name": "{\"en\":\"Loan Request - NC\",\"ar\":\"طلب سلفة - NC\"}"
      },
      {
        "id": 2,
        "name": "{\"en\":\"Loan Request - NC\",\"ar\":\"طلب سلفة - NC\"}"
      },
      {
        "id": 2,
        "name": "{\"en\":\"Loan Request - NC\",\"ar\":\"طلب سلفة - NC\"}"
      },
      {
        "id": 2,
        "name": "{\"en\":\"Loan Request - NC\",\"ar\":\"طلب سلفة - NC\"}"
      },
      {
        "id": 2,
        "name": "{\"en\":\"Loan Request - NC\",\"ar\":\"طلب سلفة - NC\"}"
      },
      {
        "id": 2,
        "name": "{\"en\":\"Loan Request - NC\",\"ar\":\"طلب سلفة - NC\"}"
      },
      {
        "id": 2,
        "name": "{\"en\":\"Loan Request - NC\",\"ar\":\"طلب سلفة - NC\"}"
      },
      {
        "id": 2,
        "name": "{\"en\":\"Loan Request - NC\",\"ar\":\"طلب سلفة - NC\"}"
      },
      {
        "id": 2,
        "name": "{\"en\":\"Loan Request - NC\",\"ar\":\"طلب سلفة - NC\"}"
      },
      {
        "id": 2,
        "name": "{\"en\":\"Loan Request - NC\",\"ar\":\"طلب سلفة - NC\"}"
      },
      {
        "id": 2,
        "name": "{\"en\":\"Loan Request - NC\",\"ar\":\"طلب سلفة - NC\"}"
      },
      {
        "id": 2,
        "name": "{\"en\":\"Loan Request - NC\",\"ar\":\"طلب سلفة - NC\"}"
      },
      {
        "id": 2,
        "name": "{\"en\":\"Loan Request - NC\",\"ar\":\"طلب سلفة - NC\"}"
      },
      {
        "id": 2,
        "name": "{\"en\":\"Loan Request - NC\",\"ar\":\"طلب سلفة - NC\"}"
      },
      {
        "id": 2,
        "name": "{\"en\":\"Loan Request - NC\",\"ar\":\"طلب سلفة - NC\"}"
      },
      {
        "id": 2,
        "name": "{\"en\":\"Loan Request - NC\",\"ar\":\"طلب سلفة - NC\"}"
      }
    ]
  },
  "body": null
}

where are we gonna include the New Workflow button?
in workflows_page.dart
              Text(
                l.workflows,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ), next to this widget

this will take us to a new screen.


this is an example of the save model and endpoint.
there shall be a textformfield mandatory for the name of workflow
a growable table with 2 columns, column a has the index starting at one, and column b has a dropdownsearch loaded with the users we cached before from the previous endpoint/users.
each time the user selects a user from this drop down a new record is revealed in the table prompting the user to add more users.
all of the users along with their indexes starting from one shall be cached in a list called workflowUsers.
current user can replace a user or delete a user from the list resetting the indexes.

another section which is to bind groups which we cached to request types which we also cached.

the user can add a new group, choose the group from a dropdown, then bind it to a requestType from dropdown as well.
/api/Web/SaveWorkflow
{
  "Name": "Test2", // there shall be a textformfield mandatory for the name
  "LoggedInUserId": 1, //this is current user Id
  
  "GroupDetails":
    {
      "GroupId": 1,
      "RequestTypeId": 1
    },
    {
      "GroupId": 1,
      "RequestTypeId": 2
    }
  ],
  "Steps": [ // we send the users from workflowUsers with their index starting at one
    {
      "StepNo": 1,
      "EmpId": 5
    },
    {
      "StepNo": 2,
      "EmpId": 6
    }
  ]
}
