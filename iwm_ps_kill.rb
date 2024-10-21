#!/usr/bin/env ruby
#coding:utf-8

require "reline"

VERSION = "iwm20241014"
TITLE   = "検索プロセスをkill"

class ClassTerminal
	def begin()
		print(
			"\n",
			"\033[97;104m ", TITLE, " \033[49m",
			"\n"
		)
	end

	def end()
		Term.reset
		print(
			"\n",
			"(END)",
			"\n\n"
		)
		exit
	end

	def clear()
		print "\033[2J\033[1;1H"
	end

	def reset()
		print "\033[0m"
	end
end
Term = ClassTerminal.new

def RtnHashDirFile(
	sIFn = ""
)
	a1 = /(.+[\\\/])*(.+?)$/.match(sIFn)[1..].to_a
	i1 = 0
	while i1 < a1.length
		if a1[i1] == nil
			a1[i1] = ""
		end
		i1 += 1
	end
	return { 'd' => a1[0], 'f' => a1[1] }
end

def SubHelp()
	bn = RtnHashDirFile($0)['f']
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
		return @aryProcess if seachKey.length == 0
		i1 = 0
		%x(ps -A).split("\n").map{|_s1| _s1.strip}.each do |_s1|
			_a1 = _s1.split(" ")
			if _a1[0] =~ /^[0-9]/
				sPname = _a1[3..].join(" ")
				# 大小区別しない
				if sPname.match(/#{seachKey}/i)
					i1 += 1
					@aryProcess << [i1, _a1[0], sPname]
				end
			end
		end
		return @aryProcess
	end

	def list()
		print(
			"\033[93m",
			"\033[8G", "PID",
			"\033[15G", "CMD",
			"\n"
		)
		@aryProcess.each do |_a1|
			printf(
				"\033[3G\033[93m%-4d \033[97m%-6s \033[96m%s\n",
				_a1[0],
				_a1[1],
				_a1[2],
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
		aryProcess = []
	)
		if aryProcess.length > 0
			@aryProcess = aryProcess
		end
		print "\033[95mkill \033[97m\033[45m Yes=1 \033[49m\n\033[95m?\033[97m "
		if STDIN.gets.strip == "1"
			print "\033[91m"
			@aryProcess.each do |_a1|
				##Kernel.puts _a1[1]
				system("kill #{_a1[1]}")
			end
		end
	end
end
Process = ClassProcess.new

Signal.trap(:INT) do
	Term.reset
	puts
	exit
end

Term.clear
Term.begin
SubHelp()

$SeachKey = nil

while true
	puts "\033[95mps -A | grep \033[97m\033[44m 検索=文字列 \033[49m"
	while true
		$SeachKey = Process.readline
		if Process.get_search($SeachKey).length > 0
			Process.list
			break
		end
	end

	while true
		puts "\033[95mkill \033[97m\033[41m 選択=n1 n2 ... \033[42m すべて選択=0 \033[44m 再検索=文字列 \033[49m"
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

Term.end
