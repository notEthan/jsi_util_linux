#!/usr/bin/env ruby

module JSIUtilLinux
  losetup_schema_content = JSI::Util.deep_stringify_symbol_keys({
    "$schema": "http://json-schema.org/draft-07/schema#",
    "type": "object",
    "properties": {
      "loopdevices": {
        "type": "array",
        "items": {"$ref": "#/definitions/loopdevice"}
      }
    },
    "definitions": {
      "loopdevice": {
        "type": "object",
        "properties": {
          "name": {"type": "string"},
          "autoclear": {"type": "boolean"},
          "back-file": {"type": "string"},
          "back-ino": {},
          "back-maj:min": {},
          "maj:min": {"type": "string"},
          "offset": {"type": "integer"},
          "partscan": {"type": "boolean"},
          "ro": {"type": "boolean"},
          "sizelimit": {"type": "integer"},
          "dio": {"type": "boolean"},
          "log-sec": {"type": "integer"},
        }
      }
    }
  })

  losetup_help_outputs = {
            "NAME" => "loop device name",
       "AUTOCLEAR" => "autoclear flag set",
       "BACK-FILE" => "device backing file",
        "BACK-INO" => "backing file inode number",
    "BACK-MAJ:MIN" => "backing file major:minor device number",
         "MAJ:MIN" => "loop device major:minor number",
          "OFFSET" => "offset from the beginning",
        "PARTSCAN" => "partscan flag set",
              "RO" => "read-only device",
       "SIZELIMIT" => "size limit of the file in bytes",
             "DIO" => "access backing file with direct-io",
         "LOG-SEC" => "logical sector size in bytes",
  }

  losetup_help_outputs.each do |k, v|
    lp = losetup_schema_content['definitions']['loopdevice']['properties'][k.downcase] || raise(k)
    lp['description'] = v
  end


  LoSetup = JSI.new_schema_module(losetup_schema_content)
  LoopDev = LoSetup.definitions['loopdevice']


  module LoSetup
    EMPTY_CONTENT = {"loopdevices" => [].freeze}.freeze
  end

  module LoopDev
  end
end
