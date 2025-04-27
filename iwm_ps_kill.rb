#!/usr/bin/env ruby
#coding:utf-8

require "reline"

VERSION = "iwm20250423"
TITLE   = "検索プロセスをkill"

class Class_Terminal
	def clear()
		$stderr.print "\033[2J", "\033[1;1H", "\033[0m", "\033[0G"
	end

	def reset()
		$stderr.print "\033[0m"
	end

	def begin(sTitle = "")
		if sTitle.length == 0
			return
		end
		$stderr.print "\n", "\033[97;44m ", sTitle, " \033[49m", "\n"
	end

	def end(bInput = true)
		$stderr.print "\033[0m", "(END)"
		if bInput == true
			STDIN.gets
		end
		$stderr.print "\n\n"
		exit
	end

	def abort()
		$stderr.print "\033[0m", "\033[0G", "\n\n"
		exit
	end

	def cursorOn()
		$stderr.print "\033[?25h"
	end

	def cursorOff()
		$stderr.print "\033[?25l"
	end
end
Term = Class_Terminal.new

at_exit do
	Term.cursorOn()
end

Signal.trap(:INT) do
	Term.abort()
end

def SubHelp()
	print(
		"\033[2G", "\033[93m(例１) \033[96mconky を含むプロセスを検索",
		"\n",
		"\033[5G", "\033[97mconky",
		"\n",
		"\033[2G", "\033[93m(例２) \033[96mcon から始まるプロセスを検索",
		"\n",
		"\033[5G", "\033[97m^con",
		"\n",
		"\033[2G", "\033[93m(例３) \033[96mすべてのプロセスを検索",
		"\n",
		"\033[5G", "\033[97m.",
		"\n\n"
	)
end

class ClassProcess
	@aryProcess = []

	def get()
		return @aryProcess
	end

	def get_search(
		seachKey
	)
		@aryProcess = []
		if seachKey.length == 0
			return @aryProcess
		end
		i1 = 0
		%x(ps -Ao pid,comm).split("\n").each do |_s1|
			_a1 = _s1.split(" ")
			_cmd = _a1[1..].join(" ")
			# 大小区別しない
			if _cmd.match(/#{seachKey}/i)
				i1 += 1
				@aryProcess << [i1, _a1[0], _cmd]
			end
		end
		return @aryProcess
	end

	def list()
		if @aryProcess.length == 0
			return
		end
		print(
			"\033[93m",
			"\033[3G", "ID",
			"\033[8G", "PID",
			"\033[15G", "CMD",
			"\n"
		)
		@aryProcess.each do |_a1|
		print(
			"\033[97m", "\033[3G", _a1[0],
			"\033[37m", "\033[8G", _a1[1],
			"\033[96m", "\033[15G", _a1[2],
			"\n"
		)
		end
	end

	def readline()
		sKey = Reline.readline("\033[95m?\033[97m ", false).strip
		if sKey.length > 0
			# 重複データ 排除
			Reline::HISTORY.delete(sKey)
			Reline::HISTORY << sKey
		end
		return sKey
	end

	def kill(
		aryProcess = nil
	)
		if aryProcess == nil
			@aryProcess
		elsif aryProcess.length > 0
			@aryProcess = aryProcess
		else
			puts "該当 0 件"
			return
		end
		puts "該当 #{@aryProcess.length} 件"
		print "\033[95mkill \033[97m\033[45m Yes=1 \033[49m\n\033[95m?\033[97m "
		if STDIN.gets.strip == "1"
			print "\033[91m"
			@aryProcess.each do |_a1|
				##Kernel.p _a1
				system("kill #{_a1[1]}")
			end
		end
	end
end
Process = ClassProcess.new

Term.clear()
Term.begin(TITLE)
SubHelp()

$SeachKey = nil

while true
	puts "\033[97m\033[44m 検索=文字列 \033[49m"
	while true
		$SeachKey = Process.readline
		if Process.get_search($SeachKey).length > 0
			Process.list
			break
		end
	end

	puts "\033[95mkill \033[97m\033[41m 選択=ID1 ID2 ... \033[42m すべて選択=0 \033[44m 再検索=文字列 \033[49m"
	while true
		aKey = Process.readline.split(" ")
		if aKey.length == 0
			next
		else
			# すべて選択
			if aKey.length == 1 && aKey[0] == "0"
				Process.kill
				break
			# 選択
			elsif aKey[0] =~ /\d+/
				aryProcess = []
				Process.get.each do |_a1|
					aKey.each do |_s1|
						if _s1.to_i == _a1[0]
							aryProcess << _a1
						end
					end
				end
				Process.kill(aryProcess)
				break
			# 再検索
			elsif aKey[0] =~ /\S+/
				Process.get_search(aKey[0])
				Process.list
			end
		end
	end
end

Term.end(false)
