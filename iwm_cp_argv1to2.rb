#!/usr/bin/ruby
#coding:utf-8

VERSION = "iwm20230923"
TITLE = "ファイル１から２へ上書きコピー"

require "io/console"
require "fileutils"

class ClassTerm
	def clear()
		print "\033[2J\033[H"
	end

	def reset()
		print "\033[0m"
	end
end
Term = ClassTerm.new()

Signal.trap(:INT) do
	Term.reset()
	exit
end

def SubBgn()
	puts(
		"\n" +
		"\033[97;104m #{TITLE} \033[0m"
	)
end

def SubEnd()
	Term.reset()
	puts "\n(END)"
	exit
end

def SubHelp()
	bn = File.basename($0)
	puts(
		"    \033[97m#{bn} \033[91m[input] [output]\n" +
		"\n" +
		" \033[93m(例)\n" +
		"    \033[97m#{bn} \033[91m\"./file1\" \"./file2\""
	)
	SubEnd()
end

SubBgn()

if ARGV.length < 2 || ARGV[0] == "--help" || ARGV[0] == "-h"
	SubHelp()
end

$iFn, $oFn = ARGV[0..1]

$flg = true

if ! File.exist?($iFn)
	puts "\033[91m[1] \"#{$iFn}\" は存在しない"
	$flg = false
end

if ! File.exist?($oFn)
	puts "\033[91m[2] \"#{$oFn}\" は存在しない"
	$flg = false
end

if ! $flg
	SubEnd()
end

FileUtils.cp($iFn, $oFn)
puts(
	"\033[92m#{$iFn}\n" +
	"\033[93m  ↓\n" +
	"\033[93m#{$oFn}"
)

SubEnd()
