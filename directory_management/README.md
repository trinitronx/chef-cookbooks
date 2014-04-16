Description
===========

This is a very simple cookbook which contains recipes for directory management. It is intended for use along other cookbooks which require directories to be in place, have certain permissions, etc.

Usage
=====

directory_management::win_shares
--------------------------------

Configure attributes like the following on your node, and include directory\_management in your node's run\_list:

```json
"windows": {
  "shares": {
    "MyShareName": {
      "grants": {
        "ENCOM\\Domain Admins": "full",
        "ENCOM\\CatFactsSubcribers": "read"
      },
      "path": "E:\\Folder\\Cat Pics"
    }
  }
}
```
