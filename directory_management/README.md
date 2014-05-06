Description
===========

This is a very simple cookbook which contains recipes for directory management. It is intended for use along other cookbooks which require directories to be in place, have certain permissions, etc.

Usage
=====

directory_management::win_dir
--------------------------------

This recipe can be applied to all of your Windows nodes, and when attributes like the following are specified it will configure your specified ACLs on them.


```json
"windows": {
  "directories": {
    "E:\\Folder\\Cat Pics": {
      "rights": {
        "ENCOM\\Domain Admins": "full_control",
        "ENCOM\\CatFactsSubcribers": "read_execute"
      }
    },
    "E:\\Folder\\Cat Pics\Bit": {
      "rights": {
        "ENCOM\\Domain Admins": "full_control"
      },
      "disable_inherits": true
    },
    "E:\\Folder\\Cat Pics\Byte": {
      "rights": {
        "ENCOM\\Iso": "read_execute",
        "ENCOM\\Binary": [
          "read_execute",
          {
            "applies_to_children": false
          }
        ]
      }
    }
  }
}
```

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
