#!/usr/bin/env ruby

module JSIUtilLinux
  lsblk_schema_content = JSI::Util.deep_stringify_symbol_keys({
    "$schema": "http://json-schema.org/draft-07/schema#",
    "type": "object",
    "properties": {
      "blockdevices": {
        "type": "array",
        "items": {"$ref": "#/definitions/blockdevice"}
      }
    },
    "definitions": {
      "blockdevice": {
        "type": "object",
        "properties": {
          "children": {
            "type": "array",
            "items": {"$ref": "#/definitions/blockdevice"}
          },
          "hctl": {"type": ["null","string"]},
          "log-sec": {"type": "integer"},
          "disc-max": {"type": "string"},
          "ptuuid": {"type": ["null","string"]},
          "pttype": {"type": ["null","string"]},
          "type": {"type": "string"},
          "disc-gran": {"type": "string"},
          "subsystems": {"type": "string"},
          "uuid": {"type": ["null","string"]},
          "mountpoint": {"type": ["null","string"]},
          "wwn": {"type": ["null","string"]},
          "mode": {"type": "string"},
          "rand": {"type": "boolean"},
          "path": {"type": "string"},
          "fsused": {"type": ["null","string"]},
          "dax": {"type": "boolean"},
          "model": {"type": ["null","string"]},
          "state": {"type": ["null","string"]},
          "tran": {"type": ["null","string"]},
          "fstype": {"type": ["null","string"]},
          "group": {"type": "string"},
          "wsame": {"type": "string"},
          "rev": {"type": ["null","string"]},
          "zone-omax": {"type": "integer"},
          "zone-wgran": {"type": "integer"},
          "ra": {"type": "integer"},
          "pkname": {"type": ["null","string"]},
          "sched": {"type": ["string","null"]},
          "size": {"type": "string"},
          "name": {"type": "string"},
          "partlabel": {"type": ["null","string"]},
          "rm": {"type": "boolean"},
          "alignment": {"type": "integer"},
          "ro": {"type": "boolean"},
          "disc-aln": {"type": "integer"},
          "mountpoints": {"type": "array","items": {"type": ["null","string"]}},
          "fsavail": {"type": ["null","string"]},
          "rq-size": {"type": "integer"},
          "disc-zero": {"type": "boolean"},
          "opt-io": {"type": "integer"},
          "zone-amax": {"type": "integer"},
          "parttype": {"type": ["null","string"]},
          "partuuid": {"type": ["null","string"]},
          "maj:min": {"type": "string"},
          "fsuse%": {"type": ["null","string"]},
          "hotplug": {"type": "boolean"},
          "zoned": {"type": "string"},
          "fssize": {"type": ["null","string"]},
          "vendor": {"type": ["null","string"]},
          "fsroots": {"type": "array","items": {"type": ["null","string"]}},
          "zone-nr": {"type": "integer"},
          "rota": {"type": "boolean"},
          "owner": {"type": "string"},
          "kname": {"type": "string"},
          "fsver": {"type": ["null","string"]},
          "start": {"type": ["null","integer"]},
          "parttypename": {"type": ["null","string"]},
          "label": {"type": ["null","string"]},
          "phy-sec": {"type": "integer"},
          "serial": {"type": ["null","string"]},
          "zone-sz": {"type": "integer"},
          "min-io": {"type": "integer"},
          "zone-app": {"type": "integer"},
          "partflags": {"type": "null"}
        }
      }
    }
  })
  lsblk_help_outputs = {
       "ALIGNMENT" => "alignment offset",
        "DISC-ALN" => "discard alignment offset",
             "DAX" => "dax-capable device",
       "DISC-GRAN" => "discard granularity",
        "DISC-MAX" => "discard max bytes",
       "DISC-ZERO" => "discard zeroes data",
         "FSAVAIL" => "filesystem size available",
         "FSROOTS" => "mounted filesystem roots",
          "FSSIZE" => "filesystem size",
          "FSTYPE" => "filesystem type",
          "FSUSED" => "filesystem size used",
          "FSUSE%" => "filesystem use percentage",
           "FSVER" => "filesystem version",
           "GROUP" => "group name",
            "HCTL" => "Host:Channel:Target:Lun for SCSI",
         "HOTPLUG" => "removable or hotplug device (usb, pcmcia, ...)",
           "KNAME" => "internal kernel device name",
           "LABEL" => "filesystem LABEL",
         "LOG-SEC" => "logical sector size",
         "MAJ:MIN" => "major:minor device number",
          "MIN-IO" => "minimum I/O size",
            "MODE" => "device node permissions",
           "MODEL" => "device identifier",
            "NAME" => "device name",
          "OPT-IO" => "optimal I/O size",
           "OWNER" => "user name",
       "PARTFLAGS" => "partition flags",
       "PARTLABEL" => "partition LABEL",
        "PARTTYPE" => "partition type code or UUID",
    "PARTTYPENAME" => "partition type name",
        "PARTUUID" => "partition UUID",
            "PATH" => "path to the device node",
         "PHY-SEC" => "physical sector size",
          "PKNAME" => "internal parent kernel device name",
          "PTTYPE" => "partition table type",
          "PTUUID" => "partition table identifier (usually UUID)",
              "RA" => "read-ahead of the device",
            "RAND" => "adds randomness",
             "REV" => "device revision",
              "RM" => "removable device",
              "RO" => "read-only device",
            "ROTA" => "rotational device",
         "RQ-SIZE" => "request queue size",
           "SCHED" => "I/O scheduler name",
          "SERIAL" => "disk serial number",
            "SIZE" => "size of the device",
           "START" => "partition start offset",
           "STATE" => "state of the device",
      "SUBSYSTEMS" => "de-duplicated chain of subsystems",
      "MOUNTPOINT" => "where the device is mounted",
     "MOUNTPOINTS" => "all locations where device is mounted",
            "TRAN" => "device transport type",
            "TYPE" => "device type",
            "UUID" => "filesystem UUID",
          "VENDOR" => "device vendor",
           "WSAME" => "write same max bytes",
             "WWN" => "unique storage identifier",
           "ZONED" => "zone model",
         "ZONE-SZ" => "zone size",
      "ZONE-WGRAN" => "zone write granularity",
        "ZONE-APP" => "zone append max bytes",
         "ZONE-NR" => "number of zones",
       "ZONE-OMAX" => "maximum number of open zones",
       "ZONE-AMAX" => "maximum number of active zones",
  }
  lsblk_help_outputs.each do |k, v|
    bp = lsblk_schema_content['definitions']['blockdevice']['properties'][k.downcase] || raise(k)
    bp['description'] = v
  end

  LsBlk = JSI.new_schema_module(lsblk_schema_content)
  BlockDev = LsBlk.definitions['blockdevice']


  module LsBlk
    # @yield [BlockDev]
    # @return [Enumerator, nil]
    def each_blockdev
      return to_enum(__method__) unless block_given?
      jsi_each_descendent_node do |n|
        yield n if n.is_a?(BlockDev)
      end
      nil
    end

    # @yield [BlockDev]
    # @return [Enumerator, nil]
    def each_disk
      return to_enum(__method__) unless block_given?
      each_blockdev { |d| yield d if d.type == 'disk' }
    end

    # @yield [BlockDev]
    # @return [Enumerator, nil]
    def each_crypt
      return to_enum(__method__) unless block_given?
      # veracrypt devices are type 'dm' (dev mapper)
      each_blockdev { |d| yield d if %w(crypt dm).include?(d.type) }
    end
  end

  module BlockDev
    # @return [BlockDev, nil]
    def parent_blockdev
      jsi_parent_nodes.detect { |n| n.is_a?(BlockDev) }
    end

    # @return [LoSetup]
    def losetup
      @losetup ||= JSIUtilLinux.losetup
    end

    # @return [LoopDev, nil]
    def loopdev
      losetup.loopdevices.detect do |ld|
        ld.name == path
      end
    end

    # @return [BlockDev, nil]
    def loop_backing_blockdev
      loopdev = self.loopdev
      if loopdev
        jsi_root_node.each_blockdev.detect { |bd| bd.path == loopdev["back-file"] }
      end
    end
  end
end
