# JSIUtilLinux

This library interacts with certain utilities of `util-linux` (see [Wikipedia](https://en.wikipedia.org/wiki/Util-linux), [kernel.org](https://git.kernel.org/pub/scm/utils/util-linux/util-linux.git), [Github](https://github.com/util-linux/util-linux)) and offers an object-oriented representation for their results. This uses the JSON output of those utilities, JSON Schemas describing that, and the [JSI gem](https://github.com/notEthan/jsi).

## Usage

Methods named after supported utilities are defined on {JSIUtilLinux}. Arguments passed to these are transformed from convenient Ruby expressions to CLI arguments - see {JSIUtilLinux.args_to_argv}; note that Symbols become hyphenated dash arguments.

What arguments are recognized, and their defaults, vary by system or utility version - see e.g. `lsblk --help` and `man lsblk` for more information.

Supported utilities are:

- {JSIUtilLinux.lsblk} for [`lsblk`](https://linux.die.net/man/8/lsblk)
- {JSIUtilLinux.findmnt} for [`findmnt`](https://linux.die.net/man/8/findmnt)
- {JSIUtilLinux.losetup_ls} for [`losetup --list`](https://linux.die.net/man/8/losetup) (other modes of `losetup` than `--list` are not supported)

### Examples

```ruby
JSIUtilLinux.lsblk
```

returns:

```
#{<JSI (JSIUtilLinux::LsBlk)>
  "blockdevices" => #[<JSI (JSIUtilLinux::LsBlk.properties["blockdevices"])>
    #{<JSI (JSIUtilLinux::BlockDev)>
      "name" => "sda",
      "maj:min" => "8:0",
      "size" => "119.2G",
      "type" => "disk",
      "mountpoint" => nil,
      "children" => #[<JSI (JSIUtilLinux::BlockDev.properties["children"])>
        #{<JSI (JSIUtilLinux::BlockDev)>
          "name" => "sda1",
          "maj:min" => "8:1",
          "size" => "1M",
          "type" => "part",
          "mountpoint" => nil
        },
        #{<JSI (JSIUtilLinux::BlockDev)>
          "name" => "sda2",
          "maj:min" => "8:2",
          "size" => "100G",
          "type" => "part",
          "mountpoint" => "/"
        }
      ]
    }
  ]
}
```

More examples, arguments:

```ruby
JSIUtilLinux.lsblk(output: 'name') # lsblk --output name
JSIUtilLinux.lsblk(:output_all)    # lsblk --output-all
JSIUtilLinux.findmnt
JSIUtilLinux.findmnt('/dev')
JSIUtilLinux.findmnt(target: 'path/file')
JSIUtilLinux.losetup_ls                         # losetup --list
JSIUtilLinux.losetup_ls(associated: 'file.img') # losetup --list --associated file.img
```
