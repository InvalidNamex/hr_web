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
    