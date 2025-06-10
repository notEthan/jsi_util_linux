# frozen_string_literal: true

require_relative "jsi_util_linux/version"
require 'jsi'
require 'shellwords'

module JSIUtilLinux
  autoload(:FindMnt, 'jsi_util_linux/findmnt')
  autoload(:Filesystem, 'jsi_util_linux/findmnt')
  autoload(:LoSetupList, 'jsi_util_linux/losetup')
  autoload(:LoopDev, 'jsi_util_linux/losetup')
  autoload(:LsBlk, 'jsi_util_linux/lsblk')
  autoload(:BlockDev, 'jsi_util_linux/lsblk')

  # Invokes [`findmnt`](https://linux.die.net/man/8/findmnt). Method arguments become CLI arguments via {args_to_argv}.
  # @return [FindMnt]
  def self.findmnt(*args, **kwargs)
    system_jsi(FindMnt, 'findmnt', args, kwargs, empty: FindMnt::EMPTY_CONTENT)
  end

  # invokes {findmnt} and returns the resulting filesystems
  # @return [Array<Filesystem>]
  def self.filesystems(*args, **kwargs)
    findmnt(*args, **kwargs).filesystems
  end

  # Invokes [`losetup --list`](https://linux.die.net/man/8/losetup). Method arguments become CLI arguments via {args_to_argv}.
  #
  # Other modes of `losetup` than `--list` are not supported.
  #
  # @return [LoSetupList]
  def self.losetup_ls(*args, **kwargs)
    system_jsi(LoSetupList, 'losetup', ['--list', *args], kwargs, empty: LoSetupList::EMPTY_CONTENT)
  end

  # invokes {losetup_ls} and returns the resulting loopdevices
  # @return [Array<LoopDev>]
  def self.loopdevices(*args, **kwargs)
    losetup_ls(*args, **kwargs).loopdevices
  end

  # Invokes [`lsblk`](https://linux.die.net/man/8/lsblk). Method arguments become CLI arguments via {args_to_argv}.
  # @return [LsBlk]
  def self.lsblk(*args, **kwargs)
    system_jsi(LsBlk, 'lsblk', args, kwargs, empty: LsBlk::EMPTY_CONTENT)
  end

  # invokes {lsblk} and returns the resulting blockdevices
  # @return [Array<BlockDev>]
  def self.blockdevices(*args, **kwargs)
    lsblk(*args, **kwargs).blockdevices
  end

  # Transforms arguments, taking what is convenient to write in Ruby and returning what will be passed as `argv` to a CLI utility.
  #
  # String arguments go into argv as-is.
  # Symbols are prefixed with '-' for single-character, '--' otherwise, and underscores become dashes.
  # Arrays are recursed - `%w()` syntax is convenient to express arguments roughly like in a shell.
  # Hashes are recursed - this would usually come from a keyword arguments hash.
  #
  #     (o: 'name') => ['-o', 'name']
  #     (:a, :b, I: '7') => ['-a', '-b', '-I', '7']
  #     (:bytes) => ['--bytes']
  #     (include: '7') => ['--include', '7']
  #     (%w(--include 7)) => ['--include', '7']
  #
  # @return [Array<String>]
  def self.args_to_argv(*args, **kwargs)
    argv = []
    args << kwargs
    args.each do |a|
      if a.is_a?(Symbol)
        argv << (a.size == 1 ? "-#{a}" : "--#{a.to_s.tr('_', '-')}")
      elsif a.is_a?(Array)
        argv += args_to_argv(*a)
      elsif a.is_a?(Hash)
        a.each do |k, v|
          argv += args_to_argv(k, v)
        end
      else
        argv << a.to_str
      end
    end
    argv
  end

  # @private
  def self.system_jsi(schema, util, args, kwargs, empty: nil)
    argv = args_to_argv('--json', *args, **kwargs)
    # TODO probably better to use an open3 method
    cmd = "#{util} #{argv.map { |a| Shellwords.escape(a) }.join(' ')}"
    json = Kernel.send(:`, cmd)
    raise("#{util} exited #{$?.exitstatus}\ncmd: #{cmd}\noutput: #{json}") unless $?.exitstatus == 0
    content = json.empty? ? empty.nil? ? raise("empty output from command: #{cmd}") : empty : begin
      JSON.parse(json)
    rescue JSON::ParserError => e
      raise("command did not output JSON.\ncommand: #{cmd}\noutput: #{json}\n#{e.class}: #{e.message}")
    end
    schema.new_jsi(content)
  end
end
