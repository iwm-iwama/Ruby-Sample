#!/usr/bin/ruby
#coding:utf-8

VERSION = "iwm20230925"
TITLE = "ファイル１から２へ上書きコピー"

require "fileutils"
require "io/console"

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
		"    \033[97m#{bn} \033[91m[input] [output ...]\n" +
		"\n" +
		" \033[93m(例)\n" +
		"    \033[97m#{bn} \033[91m\"./file1\" \"./file2\" ..."
	)
	SubEnd()
end

SubBgn()

if ARGV.length < 2 || ARGV[0] == "--help" || ARGV[0] == "-h"
	SubHelp()
end

$flg = true

i1 = 0
ARGV.each do |_s1|
	i1 += 1
	if ! File.exist?(_s1)
		puts "\033[91m[#{i1}] \"#{_s1}\" は存在しない"
		$flg = false
	end
end

if ! $flg
	SubEnd()
end

puts(
	"\033[92m#{ARGV[0]}\n" +
	"\033[96m  ↓"
)
ARGV[1..].each do |_s1|
	puts "\033[96m#{_s1}"
end

print(
	"\n" +
	"\033[93m実行しますか ? [Y/n] \033[97m"
)
if ! (STDIN.getch =~ /Y/i)
	puts
	SubEnd()
end

ARGV[1..].each do |_s1|
	FileUtils.copy(ARGV[0], _s1)
end

puts
SubEnd()
