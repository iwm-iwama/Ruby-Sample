#!/usr/bin/env ruby
#coding:utf-8

require "reline"

VERSION = "iwm20250423"

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

WIDTH = 60
LN = "-" * WIDTH

# \t区切り
HELP = <<EOD
#{LN}
	基本操作
		[Enter]	計算実行
		[↑／↓]	履歴
#{LN}
	コマンド
		.q	終了
		.r	再起動
		.rd	再起動／履歴消去
		.u	ユーザ設定　一覧
		.ud	〃　全消去
		.ud[NUM]	〃　[NUM]を消去
		.i	入力履歴　一覧
#{LN}
	数式
		*	3 * 2	=> 6
		/	3.0 / 2.0	=> 1.5
			3 / 2	=> 1
		%	3 % 2	=> 1
		+	3 + 2	=> 5
		-	3 - 2	=> 1
		**	3 ** 2 	=> 9
		Sqrt(n)	Sqrt(4)	=> 2.0
		Pi	3.141592653589793
		Rad	0.017453292519943
		Sin(n)	Sin(30 * Rad)	=> 0.5
		Cos(n)	Cos(60 * Rad)	=> 0.5
		Tan(n)	Tan(45 * Rad)	=> 1.0
#{LN}
	(例１)
		> i1 = Pi ↵
		> i2 = 180 ↵
		> i1 / i2 ↵
		    0.017453292519943

	(例２)
		> def foo() Pi / 180 end ↵
		> foo() ↵
		    0.017453292519943
#{LN}
EOD

def SubHelp()
	puts "\033[97;44m Ver.#{VERSION} \033[49m"
	_BG = " " * WIDTH
	HELP.split("\n").each do |_s1|
		print "\033[44m", _BG
		a1 = _s1.split("\t")
		if a1[0] then print "\033[1G",  "\033[97m", a1[0] end
		if a1[1] then print "\033[2G",  "\033[96m", a1[1] end
		if a1[2] then print "\033[5G",  "\033[93m", a1[2] end
		if a1[3] then print "\033[18G", "\033[97m", a1[3] end
		if a1[4] then print "\033[32G", "\033[95m", a1[4] end
		puts "\033[49m"
	end
	Term.reset()
end

# User Defined
$AryUserDefined = []

def main()
	Term.clear()
	Term.reset()
	SubHelp()

	while true
		# 空白データ 排除
		input = Reline.readline("> ", false).strip

		# 複数空白を集約
		input.gsub!(/\s{2,}/, " ")

		if input.length > 0
			# 重複データ 排除
			Reline::HISTORY.delete(input)
			Reline::HISTORY << input
		end

		case input
			# ""
			when ""
				print

			# .q
			when /\.q$/i
				Term.end(false)

			# .r
			when ".r"
				main()
				break

			# .rd
			when ".rd"
				$AryUserDefined.clear
				Reline::HISTORY.clear
				main()
				break

			# .u
			when ".u"
				puts "\033[37;41m User Defined \033[49m"
				print "\033[92m"
				if $AryUserDefined.length == 0
					puts "[]"
				else
					i1 = 1
					$AryUserDefined.each do |_s|
						puts "[#{i1}] #{_s}"
						i1 += 1
					end
				end

			# .ud
			when ".ud"
				$AryUserDefined = []

			# .ud[NUM]
			when /\.ud\d+/
				begin
					i1 = input[3].to_i
					$AryUserDefined.delete_at(i1 - 1)
				rescue => e
 				end

			# .i
			when /\.i$/i
				puts "\033[37;41m Input History \033[49m"
				print "\033[92m"
				Reline::HISTORY.each do |_s|
					print "  ", _s, "\n"
				end

			# def
			when /^(def)/
				if input =~ /^(def\s.+\send$)/
					# 関数 置換
					s1 = input.split(/\s*\(/)[0]
					$AryUserDefined.delete_if{ |_s| _s =~ /^#{s1}/ }
					$AryUserDefined << input
				else
					Reline::HISTORY.delete(input)
				end

			# =
			when /.+\=.*/
				# 変数 置換
				a1 = input.split(/\s*\=/)
				if a1[1]
					$AryUserDefined.delete_if{ |_s| _s =~ /^#{a1[0]}/ }
					$AryUserDefined << input
				else
					$AryUserDefined << input + "0"
				end

			# Calculate
			else
				s1 = ""
				$AryUserDefined.each do |_s|
					s1 << "  "
					s1 << _s
					s1 << "\n"
				end
				s1 << "  "
				s1 << input

				# Math 置換
				s1 = s1
					.gsub("Sqrt(", "Math::sqrt(")
					.gsub("Sin(",  "Math::sin(")
					.gsub("Cos(",  "Math::cos(")
					.gsub("Tan(",  "Math::tan(")
					.gsub("Rad",   "Math::PI/180")
					.gsub("Pi",    "Math::PI")

				puts "\033[96m#{s1}\033[93m"

				# Calculate
				begin
					print(
						"    ",
						eval(s1).round(15)
					)
				# Error
				rescue => e
					puts(
						"",
						"\033[91m[Err] #{e.to_s.strip}"
					)
				# Error: Syntax
				rescue Exception => e
					puts(
						"",
						"\033[91m[Err] #{e.to_s.strip}"
					)
 				end
				puts
		end

		Term.reset()
	end
end

main()
