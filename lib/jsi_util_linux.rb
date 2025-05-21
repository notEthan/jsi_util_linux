# frozen_string_literal: true

require_relative "jsi_util_linux/version"
require 'jsi'
require 'shellwords'

module JSIUtilLinux
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
  def self.system_jsi(schema, util, args, kwargs)
    argv = args_to_argv('--json', *args, **kwargs)
    # TODO probably better to use an open3 method
    cmd = "#{util} #{argv.map { |a| Shellwords.escape(a) }.join(' ')}"
    json = Kernel.send(:`, cmd)
    raise("#{util} exited #{$?.exitstatus}\ncmd: #{cmd}\noutput: #{json}") unless $?.exitstatus == 0
    schema.new_jsi(JSON.parse(json))
  end
end
