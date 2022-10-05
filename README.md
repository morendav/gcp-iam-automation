# GCP_autoPolicyPush
Project aimed to automate the fulfillment of Google Cloud Platform permission escalation requests

>Language: Linux Shell, automated solution to reconcile current GCP permissions set with PR, merge, and push new permissions to GCP production

## Description
Problem Statement: Our IAM enterprise solution addresses account creation in GSUITE and the assignment of users to usergroups. Permissions are handled at the group level and assigned by either custom or public Google Cloud permission sets (Google Roles). A group admin may request permission escalation through a github PR wherein they add their group to the appropriate Google role in the .yml corresponding to the development env they would need the elevated permissions in (ie Google Project = Dev, Test, Prod, etc).

The Repo is our auditable record of access held by groups. However; because this is a static representation, the service accounts that Google adds as feature enhancements or fixes would not be in our repo and therefore when the next escalation was fulfilled the service account would be overwritten and functionality would be comprimized.

### Prerequisites

origin git repos on local holding copies of the most recent GCP IAM policy deployments

##  Notes

Project Mapping Text
>    The project names (name in yml file) & the corresponding project ID in Google CP were not always exact matches - therefore a text file mapping was created to manage this mapping and ensure pushes to GCP did not unintentionally overwrite other Projects

Google Service Account reconcile
>   This script will assume that any google service account not in the repo should be added into our repo

Escalations made out of band
>   sometimes users and user groups add themselves directly to permission sets, this is out of band with our enterprise solution and therefore this script automatically takes these permissions away.
