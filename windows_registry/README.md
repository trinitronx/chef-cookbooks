Description
===========

This cookbook contains recipes for applying specific Windows registry changes.

Requirements
============

Windows Server 2008 and above is supported.

Recipes
=======

disable_uac
-------

This recipe updates the 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\EnableLUA' registry key with a value of 0, disabling UAC on the system. The default value is 1.

Usage
=====

Either add the specific recipe(s) to the run list of a node, or create a role.