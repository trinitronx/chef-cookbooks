# omnibus_updater_windows-cookbook

This cookbook is intended to be a complement to the omnibus_updater cookbook and provide support for upgrading chef-client on Windows systems.

## Supported Platforms

TODO: List your supported platforms.

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['omnibus_updater_windows']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
  </tr>
</table>

## Usage

### omnibus_updater_windows::default

Include `omnibus_updater_windows` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[omnibus_updater_windows::default]"
  ]
}
```

## Contributing

1. Fork the repository on Github
2. Create a named feature branch (i.e. `add-new-recipe`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request

## License and Authors

Author:: Biola University (<jared.king@biola.edu>)
