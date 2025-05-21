# frozen_string_literal: true

module JSIUtilLinux
  findmnt_schema_content = JSI::Util.deep_stringify_symbol_keys({
    "$schema": "http://json-schema.org/draft-07/schema#",
    "type": "object",
    "properties": {
      "filesystems": {
        "type": "array",
        "items": {"$ref": "#/definitions/filesystem"}
      }
    },
    "definitions": {
      "filesystem": {
        "type": "object",
        "properties": {
          "children": {
            "type": "array",
            "items": {"$ref": "#/definitions/filesystem"}
          },
          "action": {},
          "avail": {},
          "freq": {},
          # fsroot: just "/" for a lot of things (no relation to parent, seems like)
          #   btrfs: subvolume name e.g. "/@" (/), "/ethan" (/home/ethan)
          #   zfs: "/"
          "fsroot": {},
          "fstype": {},
          "fs-options": {},
          "id": {},
          "label": {},
          "maj:min": {},
          "old-options": {},
          "old-target": {},
          "options": {},
          "opt-fields": {},
          "parent": {},
          "partlabel": {},
          "partuuid": {},
          "passno": {},
          "propagation": {},
          "size": {},
          # source: this contains some information about a source (device or whatever) but I don't know the format
          # e.g. "selinuxfs" for target: "/sys/fs/selinux"
          #   btrfs: "/dev/mapper/luks-9583[/ethan]" where "ethan" is btrfs subvolume
          #     (or "/ethan" is fsroot, but no others include "[#{fsroot}]")
          #     no [] when subvolume is volume root
          #   zfs: zfs fs name (doesn't start with /; starts with pool name)
          "source": {},
          # I don't know when this contains anything other than source
          "sources": {
            "items": {},
          },
          # this exists in the root filesystem. is this always within its parent's target?
          "target": {},
          "tid": {},
          "used": {},
          "use%": {},
          # only seen this show up for btrfs. it is the root fs uuid, not subvol
          "uuid": {},
          "vfs-options": {},
        }
      }
    }
  })
  findmnt_help_outputs = {
         "ACTION" => "action detected by --poll",
          "AVAIL" => "filesystem size available",
           "FREQ" => "dump(8) period in days [fstab only]",
         "FSROOT" => "filesystem root",
         "FSTYPE" => "filesystem type",
     "FS-OPTIONS" => "FS specific mount options",
             "ID" => "mount ID",
          "LABEL" => "filesystem label",
        "MAJ:MIN" => "major:minor device number",
    "OLD-OPTIONS" => "old mount options saved by --poll",
     "OLD-TARGET" => "old mountpoint saved by --poll",
        "OPTIONS" => "all mount options",
     "OPT-FIELDS" => "optional mount fields",
         "PARENT" => "mount parent ID",
      "PARTLABEL" => "partition label",
       "PARTUUID" => "partition UUID",
         "PASSNO" => "pass number on parallel fsck(8) [fstab only]",
    "PROPAGATION" => "VFS propagation flags",
           "SIZE" => "filesystem size",
         "SOURCE" => "source device",
        "SOURCES" => "all possible source devices",
         "TARGET" => "mountpoint",
            "TID" => "task ID",
           "USED" => "filesystem size used",
           "USE%" => "filesystem use percentage",
           "UUID" => "filesystem UUID",
    "VFS-OPTIONS" => "VFS specific mount options",
  }
  findmnt_help_outputs.each do |k, v|
    (findmnt_schema_content['definitions']['filesystem']['properties'][k.downcase] || raise(k))['description'] = v
  end

  FindMnt = JSI.new_schema_module(findmnt_schema_content)
  Filesystem = FindMnt.definitions['filesystem']

  module FindMnt
    EMPTY_CONTENT = {"filesystems" => [].freeze}.freeze

    # @yield [Filesystem]
    # @return [Enumerator, nil]
    def each_filesystem(&block)
      return to_enum(__method__) unless block_given?
      # jsi_each_descendent_node do |n|
      #   yield n if n.is_a?(Filesystem)
      # end
      filesystems.each { |fs| fs.each_filesystem(&block) }
      nil
    end
  end

  module Filesystem
    def maj_min
      self['maj:min']
    end

    def dev_re_match
      (self['maj:min'] || raise("no maj:min present in #{inspect}")).match(/\A(\d+):(\d+)\z/)
    end

    # @return [Integer]
    def dev_major
      Integer(dev_re_match[1])
    end

    # @return [Integer]
    def dev_minor
      Integer(dev_re_match[2])
    end

    # @yield [Filesystem]
    # @return [Enumerator, nil]
    def each_filesystem(&block)
      return to_enum(__method__) unless block_given?
      yield self
      children && children.each { |fs| fs.each_filesystem(&block) }
      nil
    end

    # @return [Filesystem]
    def parent_filesystem
      #jsi_parent_nodes.detect { |n| n.is_a?(Filesystem) }
      jsi_root_node.each_filesystem.detect { |fs| fs.id == parent }
    end
  end
end
